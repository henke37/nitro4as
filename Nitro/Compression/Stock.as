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
			
			var o:ByteArray;
			
			switch(type& ~8) {
				
				case 0://Uncompressed
					o=new ByteArray();
					data.readBytes(o,0,length);
				break;
				
				case 1://LZ77
					o=ExtendedLZ77decoder.decode(data,length,variant==1);
				break;
				
				case 2://Huffman
					o=huffmanDecode(data,length,variant);
				break;
				
				case 3://RLE
					o=rleDecode(data,length);
				break;
				
				default:
					throw new ArgumentError("unsupported compression format");
				break;
			}
			
			o.position=0;
			
			if((type&8)==8) {//Delta coded
				diffUnFilter(o,8,length);
				o.position=0;
			}
			
			return o;
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
