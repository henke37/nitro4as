package Nitro.Compression {
	
	import flash.utils.*;
	
	public class ExtendedLZ77decoder {

		public function ExtendedLZ77decoder() {
			// constructor code
		}
		
		public static function decode(compressed:ByteArray):ByteArray {
			
			compressed.endian=Endian.LITTLE_ENDIAN;
			
			var flag:uint=compressed.readUnsignedByte();
			
			var decodedLength:uint=read3ByteUint(compressed);
			
			var longLengths:Boolean=Boolean(flag & 0xF);
			
			var decoded:ByteArray=new ByteArray();
			
			var flagByte:uint;
			var bit:uint = 0x0;
			while(decoded.length<decodedLength) {
				bit = bit >> 1;
				if(bit == 0)	{
					flagByte = compressed.readUnsignedByte();
					bit = 0x80;
				}
				
				if(flagByte & bit) {
					
					var length:uint=3;
					
					var lengthByte:uint=compressed.readUnsignedByte();
					
					if(longLengths) {
						
						if(lengthByte & 0xE0) {
							length=1;
						} else {
							
							if(lengthByte & 0x10) {
								length=0x111;
								length+=(lengthByte & 0xF) << 12;
								length+=compressed.readUnsignedByte()<< 4;
							} else {
								length=0x11;
								length+=(lengthByte & 0xF) << 4;
							}
							lengthByte=compressed.readUnsignedByte();
						}
					}
					
					length+=lengthByte >> 4;
					
					var distance:uint=(lengthByte & 0xF) << 8 | compressed.readUnsignedInt();
					distance+=1;
					
					var offset:uint=decoded.length-distance;
					
					var readPos:uint=offset;
						
					for(var copyIttr:uint;copyIttr<length;++copyIttr) {
						decoded.position=readPos++;
						var readByte:uint=decoded.readUnsignedByte();
						decoded.position=decoded.length;
						decoded.writeByte(readByte);
					}
				} else {
					decoded.writeByte(compressed.readUnsignedByte());
				}
			}
			
			return decoded;
		}
		
		private static function read3ByteUint(data:ByteArray):uint {
			var o:uint;
			
			o=data.readUnsignedByte();
			o|=data.readUnsignedByte() << 8;
			o|=data.readUnsignedByte() << 16;
			
			return o;
		}

	}
	
}
