﻿package Nitro.Compression {
	
	import flash.utils.*;
	
	public class ExtendedLZ77decoder {

		public function ExtendedLZ77decoder() {
			// constructor code
		}
		
		public static function decode(compressed:ByteArray,decodedLength:uint,longLengths:Boolean):ByteArray {
			
			compressed.endian=Endian.LITTLE_ENDIAN;
			
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
					
					var length:uint;
					var distance:uint;
					
					var readByte:uint;
					
					if(longLengths) {
						readByte=compressed.readUnsignedByte();
						
						switch(readByte>>4) {
							case 0:
								length=readByte<<4;
								
								readByte=compressed.readUnsignedByte();
								
								length|=readByte>>4;
								length+=0x11;
								
								distance=(readByte & 0x0F) << 8;
								readByte=compressed.readUnsignedByte();
								distance|=readByte;
							break;
							
							case 1:
								length=(readByte & 0xF) << 12;
								readByte=compressed.readUnsignedByte();
								length|=readByte << 4;
								readByte=compressed.readUnsignedByte();
								length|=readByte >> 4;
								length+=0x111;
								distance=(readByte & 0x0F) << 8;
								readByte=compressed.readUnsignedByte();
								distance|=readByte;
							break;
							
							default:
								length=(readByte >> 4) + 1;
								distance=(readByte & 0x0F) << 8;
								readByte=compressed.readUnsignedByte();
								distance|=readByte;
							break;
						}
						
					} else {
						length=readByte>>4;
						length+=3;
						distance=(readByte & 0x0F) << 8;
						distance|=readByte;
					}
					
					
					if(distance>decoded.length) throw new ArgumentError("Hit seek past the start of the data");
					
					var offset:uint=decoded.length-distance-1;
					
					var readPos:uint=offset;
						
					for(var copyIttr:uint=0;copyIttr<length;++copyIttr) {
						decoded.position=readPos++;
						readByte=decoded.readUnsignedByte();
						decoded.position=decoded.length;
						decoded.writeByte(readByte);
					}
				} else {
					decoded.writeByte(compressed.readUnsignedByte());
				}
			}
			
			return decoded;
		}

	}
	
}
