package Nitro.GK {
	import flash.utils.*;
	
	import Nitro.Compression.*;
	
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
				
				if(entry.offset>data.length) throw new ArgumentError("Offset that points outside of the file found");
				
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
				_data.position=entry.offset;
				o=Stock.decompress(_data);
			} else {
				o=new ByteArray();
				o.writeBytes(_data,entry.offset,entry.size);
			}
			
			o.position=0;
			
			return o;
		}
		
		public function build(files:Vector.<ByteArray>):void {
			_data=new ByteArray();
			_data.endian=Endian.LITTLE_ENDIAN;
			
			var offset:uint=(files.length+1)*8;
			
			fileList=new Vector.<FileEntry>();
			
			for each(var file:ByteArray in files) {
				_data.writeUnsignedInt(offset);
				_data.writeUnsignedInt(file.length);
				
				var entry:FileEntry=new FileEntry();
				entry.offset=offset;
				entry.size=file.length;
				entry.compressed=false;
				fileList.push(entry);
				
				offset+=file.length;
			}
			
			_data.writeUnsignedInt(offset);
			_data.writeUnsignedInt(0);
			
			for each(file in files) {
				_data.writeBytes(file);
			}
		}
		
		public function get data():ByteArray { return _data; }

	}
	
}

class FileEntry {
	public var offset:uint;
	public var size:uint;
	public var compressed:Boolean;
}