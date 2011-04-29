package Nitro.Graphics {
	
	import flash.utils.*;
	
	public class RGB555 {
		
		public static const byteSize:uint=2;

		public function RGB555() {
			throw new Error("This is an utility class, don't instantiate it");
		}
		
		public static function read555Color(data:ByteArray):uint {
			var entry:uint=data.readUnsignedShort();
			return fromRGB555(entry);
		}
		
		public static function fromRGB555(entry:uint):uint {
			var r:uint=entry & 0x1F;
			var g:uint=(entry >> 5) & 0x1F;
			var b:uint=(entry >> 10) & 0x1F;
			
			r=colorScaleUp(r);
			g=colorScaleUp(g);
			b=colorScaleUp(b);
			
			return b | g << 8 | r << 16;
		}
		
		public static function toRGB555(c:uint):uint {
			var r:uint=(c>> 16) & 0xFF;
			var g:uint=(c>>8) & 0xFF;
			var b:uint=c &0xFF;
			
			r>>>=3;
			g>>>=3;
			b>>>=3;
			
			return (b << 10) | (g << 5) | r;
		}
		
		private static function colorScaleUp(x:uint):uint {
			var o:uint=x<<3;
			if(x & 1) {
				o+=7;
			}
			return o;
		}

	}
	
}
