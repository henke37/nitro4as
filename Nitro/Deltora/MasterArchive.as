package Nitro.Deltora {
	import flash.utils.*;
	
	public class MasterArchive {
		
		private var entries:Vector.<ArchiveEntry>;
		
		private var blob:ByteArray;
		
		private static const offsetMultiplier:uint=4;

		public function MasterArchive() {
		}
		
		public function parse(bin:ByteArray):void {
			bin.endian=Endian.LITTLE_ENDIAN;
			
			this.blob=bin;
			
			var sig:uint=bin.readUnsignedInt();
			var dataStart:uint=bin.readUnsignedInt();
			var fileCount:uint=bin.readUnsignedInt();
			var unk:uint=bin.readUnsignedInt();
						
			entries=new Vector.<ArchiveEntry>(fileCount,true);
			
			for(var entryIndex:uint=0;entryIndex<fileCount;++entryIndex) {
				var entry:ArchiveEntry=new ArchiveEntry();
				entry.offset=bin.readUnsignedInt();
				entry.length=bin.readUnsignedInt();
				//if(entry.offset==0) break;
				entries[entryIndex]=entry;
			}
		}
		
		public function dumpEntries():String {
			var o:String="";
			for(var entryIndex:uint=0;entryIndex<120;++entryIndex) {
				var entry:ArchiveEntry=entries[entryIndex];
				
				o+=entry.offset.toString(10)+",";
				o+=entry.length.toString(10)+"\n";
			}
			
			return o;
		}
		
		public function open(entryIndex:uint):ByteArray {
			var o:ByteArray=new ByteArray();
			var entry:ArchiveEntry=entries[entryIndex];
			
			blob.position=entry.offset*offsetMultiplier;
			blob.readBytes(o,0,entry.length);
			
			return o;
		}
		
		public function get length():uint { return entries.length; }

	}
	
}

class ArchiveEntry {
	public var offset:uint,length:uint;
}