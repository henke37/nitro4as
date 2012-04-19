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
			
			inData.position=inData.length-5;
			var uncompressedLength:uint=inData.readUnsignedInt();
			
			if(uncompressedLength==0) {//uncompressed
				outData.writeBytes(inData,0,inData.length-4);
				return outData;
			}
			
			inData.position=inData.length-6;
			
			var headerSize:uint=inData.readUnsignedByte();
			inData.position=inData.length-9;
			var compressedLength:uint=read3ByteUint(inData);
			
			
			outData.length=compressedLength+uncompressedLength;
			
			outData.writeBytes(inData,0,uncompressedLength);
			
			var inPos:uint=inData.length-headerSize-1;
			var outPos:uint=outData.length-1;
			
			//todo: decompression loop
			var decompressed:uint=0;
			var bit:uint=0;
			var flags:uint=0;
			while(decompressed<compressedLength) {
				if(bit==0) {
					flags=inData[inPos--];
					bit=8;
				}
				bit--;
				
				var compressed:Boolean=Boolean(flags&1);
				flags>>=1;
				
				if(compressed) {
					var byte1:uint=inData[inPos--];
					var byte2:uint=inData[inPos--];
					
					var cloneLen:uint=byte1>>4;
					var displacement:uint=((byte1 & 0x0F) << 8) | byte2;

					cloneLen+=3;
					displacement+=3;
					
					if(displacement>decompressed) {
						//displacement=2;
					}
					
					for(var cloned:uint=0;cloned<cloneLen;++cloned) {
						outData[outPos]=outData[outPos+displacement];
						outPos--;
					}
					
					decompressed+=cloneLen;

				} else {
					outData[outPos--]=inData[inPos--];
					decompressed++;
				}
			}
			
			
			outData.position=0;
			return outData;
		}

	}
	
}
