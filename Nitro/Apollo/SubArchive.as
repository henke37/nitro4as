package Nitro.Apollo {
	import flash.utils.*;
	
	import Nitro.Compression.*;
	
	/** Parser for the sub archives found in Apollo Justice */
	
	public class SubArchive {
		
		private var subfiles:Vector.<SubFileEntry>;
		
		private var data:ByteArray;

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
			
			data.position=20;
			const dataBaseOffset:uint=data.readUnsignedInt();
			
			subfiles=new Vector.<SubFileEntry>();
			
			data.position=32;
			
			do {
				var entry:SubFileEntry=new SubFileEntry();
				entry.offset=data.readUnsignedInt()+dataBaseOffset;
				
				var mixed:uint=data.readUnsignedInt();
				
				entry.compressed=Boolean(mixed & 0x80000000);
				entry.size=mixed & ~0x80000000;
				
				//trace(entry);
				
				subfiles.push(entry);				
			} while(data.position<subfiles[0].offset);
			
			subfiles.fixed=true;
		}
		
		/** Opens a file with a given id
		@param id The id of the file to open
		@return A new ByteArray holding the contents of the file
		@throws RangeError The id is larger than the number of files in the subarchive*/
		public function open(id:uint):ByteArray {
			if(id>=subfiles.length) throw new RangeError("Id is larger than the number of subfiles!");
			
			var entry:SubFileEntry=subfiles[id];
			
			var out:ByteArray=new ByteArray();
			
			data.position=entry.offset;
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

	}
	
}

class SubFileEntry {
	public var offset:uint;
	public var size:uint;
	public var compressed:Boolean;
	
	public function toString():String {
		return "[SubFileEntry size="+size+" offset="+offset+" compressed="+(compressed?"yes":"no")+"]";
	}
}
