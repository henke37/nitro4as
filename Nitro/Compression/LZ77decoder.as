package Nitro.Compression {
	
	import flash.utils.*;
	
	public class LZ77decoder {

		public function LZ77decoder() {
			// constructor code
		}
		
		public static function decode(compressed:ByteArray):ByteArray {
			
			var decoded:ByteArray=new ByteArray();
			
			while(compressed.position<compressed.length) {
				var flags:uint=compressed.readUnsignedByte();
				
				for(var flagIttr:uint=0;flagIttr<8;++flagIttr) {
					
					if(flags & (1 << flagIttr) ) {
						var data:uint= compressed.readUnsignedShort();
						var length:uint = (data >> 12) + 3;
						var offset:uint = (data & 0x0FFF);
						
						offset=decoded.length-offset-1;
						
						var readPos:uint=offset;
						
						for(var copyIttr:uint;copyIttr<length;++copyIttr) {
							decoded.position=readPos++;
							var readByte:uint=decoded.readUnsignedByte();
							decoded.position=decoded.length;
							decoded.writeByte(readByte);
						}
					} else {
						compressed.readBytes(decoded,decoded.length,1);
					}
					
				}
			}
			
			return decoded;
		}

	}
	
}
