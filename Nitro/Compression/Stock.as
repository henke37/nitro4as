package Nitro.Compression {
	import flash.utils.ByteArray;
	
	/** Processor for DS SDK stock compression blocks.
	
	<p>It will detect the compression type based on the block header.</p>*/
	
	public class Stock {

		/** @private */

		public function Stock() {
			// constructor code
		}
		
		/** Decompresses a compressed block
		@param data The compressed block, including the compression header
		@return A new ByteArray containing the decompressed data*/
		public static function decompress(data:ByteArray):ByteArray {
			var type:uint=data.readUnsignedByte();
			var variant:uint=type & 0x0F;
			type>>=4;
			var length:uint=read3ByteUint(data);
			
			switch(type) {
				
				case 0://Uncompressed
					var o:ByteArray=new ByteArray();
					data.readBytes(o,0,length);
					return o;
				break;
				
				case 1://LZ77
					return ExtendedLZ77decoder.decode(data,length,variant==1);
				break;
				
				case 2://Huffman
				case 3://RLE
				case 8://Delta coded
				
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
