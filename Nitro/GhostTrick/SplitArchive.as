package Nitro.GhostTrick {
	
	import flash.utils.*;
	
	import Nitro.Compression.Stock;
	
	public class SplitArchive {
		
		private var data:ByteArray;
		private var entries:Vector.<SubFileEntry>;

		public function SplitArchive() {
			// constructor code
		}
		
		public function parse(table:ByteArray,data:ByteArray):void {
			entries=new Vector.<SubFileEntry>();
			
			this.data=data;
			
			table.endian=Endian.LITTLE_ENDIAN;
			
			while(table.bytesAvailable) {
				var entry:SubFileEntry=new SubFileEntry();
				entry.offset=table.readUnsignedInt();
				entry.length=table.readUnsignedInt();
				entries.push(entry);
			}
		}
		
		public function get length():uint { return entries.length; }
		
		public function open(id:uint):ByteArray {
			var entry:SubFileEntry=entries[id];
			data.position=entry.offset;
			var unpacked:ByteArray=Stock.decompress(data);
			return unpacked;
		}

	}
	
}

class SubFileEntry {
	public var offset:uint;
	public var length:uint;
}