package Nitro.Apollo {
	import flash.utils.*;
	
	import Nitro.Compression.*;
	
	/** Parser for the sub archives found in Apollo Justice */
	
	public class SubArchive {
		
		private var subfiles:Vector.<SubFileEntry>;
		
		private var data:ByteArray;
		
		private var dataBaseOffset:uint;

		public function SubArchive() {
			// constructor code
		}
		
		/** The number of files in the archive */
		public function get length():uint { return subfiles.length; }
		
		/** Loads the archive from a ByteArray
		@param data The ByteArray to load from */
		public function parse(data:ByteArray):void {
			
			if(!data) throw new ArgumentError("Data can not be null!");
			
			this.data=data;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			var sections:Object=readSectionTable(data);
			
			var tableStart:uint;
			
			if("TADB" in sections) {
				dataBaseOffset=sections["TADB"];
			} else if("TADP" in sections) {
				dataBaseOffset=sections["TADP"];
			} else throw new ArgumentError("File has no data base section!");			
			
			if("YEKB" in sections) {
				readYEKB(sections["YEKB"],dataBaseOffset);
			} else if("YEKP" in sections) {
				readYEKP(sections["YEKP"],dataBaseOffset);
			} else throw new ArgumentError("File has no table base section!");
			
			subfiles.fixed=true;
		}
		
		private function readYEKB(tableStart:uint,dataBaseOffset):void {
			subfiles=new Vector.<SubFileEntry>();
			
			data.position=tableStart;
			
			do {
				var entry:SubFileEntry=new SubFileEntry();
				var mixed1:uint=data.readUnsignedInt();
				var mixed2:uint=data.readUnsignedInt();
				
				entry.compressed=Boolean(mixed2 & 0x80000000);
				entry.unknownFlag=Boolean(mixed1 & 0x80000000);
				entry.size=mixed2 & ~0x80000000;
				entry.offset=mixed1 & ~0x80000000;
				
				//trace(entry);
				
				if(entry.size==0) {
					entry=null;
				}
				subfiles.push(entry);				
			} while(data.position<dataBaseOffset);
		}
		
		private function readYEKP(tableStart:uint,dataBaseOffset):void {
			subfiles=new Vector.<SubFileEntry>();
			
			data.position=tableStart+1;
			do {
				var entry:SubFileEntry=new SubFileEntry();
				var mixed:uint=data.readUnsignedInt();
				entry.compressed=Boolean(mixed & 0x80000000);
				entry.offset=mixed & ~0x80000000;
				
				subfiles.push(entry);		
				
			} while(data.position<dataBaseOffset);
			
			const stop:uint=subfiles.length-3;//skip last entry
			for(var i:uint=0;i<stop;++i) {
				var cur:SubFileEntry=subfiles[i];
				var next:SubFileEntry=subfiles[i+1];
				cur.size=next.offset-cur.offset;
				
				if(cur.size+cur.offset>=data.length) {
					throw new ArgumentError("borked parse");
				}
			}
		}
		
		/** Opens a file with a given id
		@param id The id of the file to open
		@return A new ByteArray holding the contents of the file
		@throws RangeError The id is larger than the number of files in the subarchive*/
		public function open(id:uint):ByteArray {
			if(id>=subfiles.length) throw new RangeError("Id is larger than the number of subfiles!");
			
			var entry:SubFileEntry=subfiles[id];
			
			if(!entry) return null;
			
			var out:ByteArray=new ByteArray();
			
			data.position=entry.offset+dataBaseOffset;
			data.readBytes(out,0,entry.size);
			
			out.endian=Endian.LITTLE_ENDIAN;
			out.position=0;
			
			if(entry.compressed){
				out=Stock.decompress(out);
				out.endian=Endian.LITTLE_ENDIAN;
				out.position=0;
			}
			
			return out;
		}


		private function readSectionTable(data:ByteArray):Object {
			var tbl:Object={};
			const tblSize:uint=data.readUnsignedInt();
			const sectionCount:uint=data.readUnsignedInt();
			
			for(var i:uint=0;i<sectionCount;++i) {
				var sectionName:String=data.readUTFBytes(4);
				var sectionPos:uint=data.readUnsignedInt();
				tbl[sectionName]=sectionPos;
			}
			
			return tbl;
		}
	}
	
}

class SubFileEntry {
	public var offset:uint;
	public var size:uint;
	public var compressed:Boolean;
	public var unknownFlag:Boolean;
	
	public function toString():String {
		return "[SubFileEntry size="+size+" offset="+offset+" compressed="+(compressed?"yes":"no")+"]";
	}
}
