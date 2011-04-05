package Nitro.SDAT {
	import flash.utils.*;
	
	public class PAC {
		
		private var pac:ByteArray;
		
		public var fileCount:uint;

		public function PAC(_pac:ByteArray) {
			
			if(!_pac) throw new ArgumentError("pac must be a real bytearray");
			
			pac=_pac;
			
			pac.endian=Endian.LITTLE_ENDIAN;
			
			fileCount=pac.readUnsignedInt();
		}
		
		public function openFile(fid:uint):ByteArray {
			pac.position=4+8*fid;
			var offset:uint=pac.readUnsignedInt();
			var size:uint=pac.readUnsignedInt();
			
			var out:ByteArray=new ByteArray();
			
			pac.position=offset;
			
			pac.readBytes(out,0,size);
			
			return out;
		}

	}
	
}
