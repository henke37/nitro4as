package Nitro.TouchDetective {
	import flash.utils.*;
	
	public class MasterArchive {
		
		private var fileEnts:Vector.<FileEnt>;
		private var data:ByteArray;

		public function MasterArchive() {
		}
		
		public function parse(data:ByteArray):void {
			data.endian=Endian.LITTLE_ENDIAN;
			this.data=data;
			
			var fileC:uint=data.readUnsignedInt();
			
			trace(fileC);
			
			fileEnts=new Vector.<FileEnt>(fileC);
			
			for(var i:uint=0;i<fileC;++i) {
				var fileEnt:FileEnt=new FileEnt();
				fileEnt.offset=data.readUnsignedInt()<<2;
				fileEnt.size=data.readUnsignedInt();
				fileEnts[i]=fileEnt;
			}
		}
		
		public function get length():uint { return fileEnts.length; }
		
		public function open(i:uint):ByteArray {
			var o:ByteArray=new ByteArray();
			
			var fileEnt:FileEnt=fileEnts[i];
			
			data.position=fileEnt.offset;
			data.readBytes(o,0,fileEnt.size);
			
			o.position=0;
			
			return o;
		}

	}
	
}

class FileEnt {
	public var size:uint;
	public var offset:uint;
}