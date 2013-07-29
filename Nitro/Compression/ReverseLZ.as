package Nitro.Compression {
	import flash.utils.*;
	
	import Nitro.*;
	
	public class ReverseLZ {
		
		//http://code.google.com/p/dsdecmp/source/browse/trunk/CSharp/DSDecmp/Formats/LZOvl.cs

		/** @private */
		public function ReverseLZ() {
			throw new ArgumentError("You don't instantiate utility classes!");
		}
		
		public static function unpack(inData:ByteArray):ByteArray {
			
			var outData:ByteArray=new ByteArray();
			
			inData.position=inData.length-4;
			var extraLength:uint=inData.readUnsignedInt();
			
			//trace("extra len",extraLength);
			
			if(extraLength==0) {//uncompressed
				trace("no compressed part");
				inData.length-=4;
				return inData;
			}
			
			inData.position=inData.length-5;
			
			var headerSize:uint=inData.readUnsignedByte();
			//trace("header size",headerSize);
			
			if(headerSize<=7 || headerSize> 0x100) throw new ArgumentError("Bogus header size!");
			
			inData.position-=4;
			var compressedLength:uint=read3ByteUint(inData);
			//trace("compressed length",compressedLength);
			
			if(compressedLength + headerSize >= inData.length) {
				compressedLength = inData.length - headerSize;
			}
			
			var noncomplen:uint = inData.length - headerSize - compressedLength;
			
			if(noncomplen) {
				outData.writeBytes(inData,0,noncomplen);
			}
			
			var decmpLen:uint=compressedLength + headerSize + extraLength;
			var decmpOut:ByteArray=new ByteArray();
			decmpOut.length=decmpLen;
			
			//trace("decmplen",decmpLen);
			
			var inPos:uint=noncomplen + compressedLength -1 ;
			var outPos:uint=decmpLen-1;
			
			//todo: decompression loop
			var decompressed:uint=0;
			var bit:uint=8;
			var flags:uint=0;
			while(decompressed<decmpLen) {
				if(bit==8) {
					flags=inData[inPos--];
					bit=0;
				}
				bit++;
				
				var compressed:Boolean=Boolean(flags& 0x80);
				flags<<=1;
				
				//trace(compressed?"C":"P");
				
				if(compressed) {
					var byte1:uint=inData[inPos--];
					var byte2:uint=inData[inPos--];
					
					var cloneLen:uint=byte1>>4;
					var displacement:uint=((byte1 & 0x0F) << 8) | byte2;

					cloneLen+=3;
					displacement+=3;
					
					if(displacement>decompressed) {
						displacement=2;
					}
					
					for(var cloned:uint=0;cloned<cloneLen;++cloned) {
						decmpOut[outPos]=decmpOut[outPos+displacement];
						outPos--;
					}
					
					decompressed+=cloneLen;

				} else {
					decmpOut[outPos--]=inData[inPos--];
					decompressed++;
				}
			}
			
			outData.writeBytes(decmpOut,0);
			
			outData.position=0;
			//trace("final length",outData.length);
			return outData;
		}

	}
	
}
