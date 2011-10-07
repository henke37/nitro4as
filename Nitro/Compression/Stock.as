package Nitro.Compression {
	import flash.utils.ByteArray;
	
	/** Processor for DS SDK stock compression blocks.
	
	<p>It will detect the compression type based on the block header.</p>*/
	
	public class Stock {

		/** @private */

		public function Stock() {
			// constructor code
		}
		
		public static function decompress(data:ByteArray):ByteArray {
			var type:uint=data.readUnsignedByte();
			var length:uint=read3ByteUint(data);
			
			switch(type) {
				
				case 0x10:
					return ExtendedLZ77decoder.decode(data,length,false);
				break;
				
				case 0x11:
					return ExtendedLZ77decoder.decode(data,length,true);
				break;
				
				case 0:
					var o:ByteArray=new ByteArray();
					data.readBytes(o,0,length);
					return o;
				break;
				
				default:
					throw new ArgumentError("unsupported compression format");
				break;
			}
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
