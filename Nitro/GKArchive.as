package Nitro {
	import flash.utils.*;
	
	public class GKArchive {
		
		private var _data:ByteArray;
		
		public var fileList:Vector.<FileEntry>;

		public function GKArchive() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			
			_data=data;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			fileList=new Vector.<FileEntry>();
		
			for(;;) {
				var entry:FileEntry=new FileEntry();
				entry.offset=data.readUnsignedInt();
				entry.size=data.readUnsignedInt();
				
				entry.compressed=Boolean(entry.size & 0x80000000);
				entry.size&=0x00FFFFFF;
				
				if(entry.size==0) {
					break;
				}
				fileList.push(entry);
			}
			fileList.fixed=true;
		}
		
		public function get length():uint {	return fileList.length; }

		public function open(id:uint):ByteArray {
			if(id>=fileList.length) throw new ArgumentError("ID is higher than the filecount");
			
			var entry:FileEntry=fileList[id];
			
			var o:ByteArray;
			
			if(entry.compressed) {
				
			} else {
				o=new ByteArray();
				o.writeBytes(_data,entry.offset,entry.size);
			}
			
			return o;
		}

	}
	
}

class FileEntry {
	public var offset:uint;
	public var size:uint;
	public var compressed:Boolean;
}