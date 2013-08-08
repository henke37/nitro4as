package HTools {
	
	import flash.utils.*;

	public class ByteArrayBitStream {
			
		public var ba:ByteArray;
		
		private var bytePos:uint;
		private var bitsLeft:uint;
		private var bits:uint;

		public function ByteArrayBitStream(ba:ByteArray) {
			this.ba=ba;
		}
		
		public function readBit():Boolean {
			if(bitsLeft==0) {
				bitsLeft=8;
				bits=ba.readUnsignedByte();
			}
			
			var bit:Boolean=Boolean(bits & 0x80);
			bits<<=1;
			bitsLeft--;
			
			return bit;
		}

	}

}