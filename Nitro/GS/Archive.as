package Nitro.GS {
	import flash.utils.*;
	
	/** A reader for the Ace Attorney game engine custom archive file format */
	public class Archive {
		
		private var entries:Vector.<ArchiveEntry>;

		private var data:ByteArray;
		
		private var baseOffset:uint;

		public function Archive() {
			// constructor code
		}
		
		/** Parses a ByteArray
		@argument d The ByteArray to parse
		*/
		public function parse(d:ByteArray):void {
			var fileCount:uint;
			
			data=d;
			data.endian=Endian.LITTLE_ENDIAN;
			
			baseOffset=d.position;
			
			fileCount=d.readUnsignedInt();
			
			entries=new Vector.<ArchiveEntry>();
			entries.length=fileCount;
			entries.fixed=true;
			
			for(var i:uint=0;i<fileCount;++i) {
				var entry:ArchiveEntry=new ArchiveEntry();
				entry.offset=d.readUnsignedInt();
				entry.size=d.readUnsignedInt();
				
				entries[i]=entry;
			}
		}
		
		/** The number of files in the archive */
		public function get length():uint { return entries.length }
		
		/** Opens a file in the archive
		@argument id The numerical id of the file to open
		@return A new ByteArray with the contents of the file*/
		public function open(id:uint):ByteArray {
			var entry:ArchiveEntry=entries[id];
			
			var ob:ByteArray=new ByteArray();
			data.position=entry.offset+baseOffset;
			data.readBytes(ob,0,entry.size);
			
			ob.position=0;
			return ob;
		}

	}
	
}

class ArchiveEntry {
	public var offset:uint;
	public var size:uint;
}