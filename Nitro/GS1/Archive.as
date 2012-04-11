package Nitro.GS1 {
	import flash.utils.*;
	
	public class Archive {
		
		private var entries:Vector.<ArchiveEntry>;

		private var data:ByteArray;
		
		private var baseOffset:uint;

		public function Archive() {
			// constructor code
		}
		
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
		
		public function get length():uint { return entries.length }
		
		public function open(id:uint):ByteArray {
			var entry:ArchiveEntry=entries[id];
			
			var ob:ByteArray=new ByteArray();
			ob.writeBytes(data,entry.offset+baseOffset,entry.size);
			
			ob.position=0;
			return ob;
		}

	}
	
}

class ArchiveEntry {
	public var offset:uint;
	public var size:uint;
}