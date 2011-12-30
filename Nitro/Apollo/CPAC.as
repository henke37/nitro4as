package Nitro.Apollo {
	import flash.utils.*;
	
	/** Reader for the CPAC files in Apollo Justice */
	public class CPAC {
		
		private var subfiles:Vector.<SubFileEntry>;
		private var data:ByteArray;

		public function CPAC() {
			// constructor code
		}
		
		/** Loads the archive from a ByteArray
		@param data The ByteArray to load from */
		public function parse(data:ByteArray):void {
			
			if(!data) throw new ArgumentError("data can not be null!");
			
			this.data=data;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			subfiles=new Vector.<SubFileEntry>();
			
			do {
				var entry:SubFileEntry=new SubFileEntry();
				entry.offset=data.readUnsignedInt();
				entry.size=data.readUnsignedInt();
				
				trace(entry);
				
				subfiles.push(entry);
			} while(data.position < subfiles[0].offset);
			
			subfiles.fixed=true;
		}
		
		/** The number of files in the archive */
		public function get length():uint { return subfiles.length; }
		
		/** Opens a file with a given id
		@param id The id of the file to open
		@return A new ByteArray holding the contents of the file
		@throws RangeError The id is larger than the number of files in the archive*/
		public function open(id:uint):ByteArray {
			
			if(id>=subfiles.length) throw new RangeError("Id is larger than the number of files in the archive!");
			
			var entry:SubFileEntry=subfiles[id];
			
			var out:ByteArray=new ByteArray();
			
			data.position=entry.offset;
			data.readBytes(out,0,entry.size);
			
			return out;
		}

	}
	
}

class SubFileEntry {
	public var offset:uint;
	public var size:uint;
	
	public function toString():String {
		return "[SubFileEntry offset="+offset+" size="+size+"]";
	}
}