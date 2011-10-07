package Nitro.Graphics {
	
	import flash.utils.*;
	
	/** Utility class to convert between the RGB555 format the Nitro uses and the RGB888 format that Flash uses. */
	
	public class RGB555 {
		
		/** The size of a single color entry in bytes. */
		public static const byteSize:uint=2;

		/** @private */
		public function RGB555() {
			throw new Error("This is an utility class, don't instantiate it");
		}
		
		/** Reads a single color entry from a ByteArray
		@param data The ByteArray to read from.
		@return The transformed color value. */
		public static function read555Color(data:ByteArray):uint {
			var entry:uint=data.readUnsignedShort();
			return fromRGB555(entry);
		}
		
		/** Transforms a color from RGB555 to RGB888
		@param entry The RGB555 color
		@return The RGB888 color*/
		public static function fromRGB555(entry:uint):uint {
			var r:uint=entry & 0x1F;
			var g:uint=(entry >> 5) & 0x1F;
			var b:uint=(entry >> 10) & 0x1F;
			
			r=colorScaleUp(r);
			g=colorScaleUp(g);
			b=colorScaleUp(b);
			
			return b | g << 8 | r << 16;
		}
		
		/** Transforms a color from RGB888 to RGB555
		@param entry The RGB888 color
		@return The RGB555 color*/
		public static function toRGB555(c:uint):uint {
			var r:uint=(c>> 16) & 0xFF;
			var g:uint=(c>>8) & 0xFF;
			var b:uint=c &0xFF;
			
			r>>>=3;
			g>>>=3;
			b>>>=3;
			
			return (b << 10) | (g << 5) | r;
		}
		
		/** Converts a full palette to RGB555 from RGB888
		@param The palette to convert.
		@return A new Vector holding the converted palette*/
		public static function paletteToRGB555(p:Vector.<uint>):Vector.<uint> {
			var np:Vector.<uint>=new Vector.<uint>();
			np.length=p.length;
			np.fixed=true;
			
			for(var i:uint=0;i<np.length;++i) {
				np[i]=toRGB555(p[i]);
			}
			
			return np;
		}
		
		/** Converts a full palette to RGB888 from RGB555
		@param The palette to convert.
		@return A new Vector holding the converted palette*/
		public static function paletteFromRGB555(p:Vector.<uint>):Vector.<uint> {
			var np:Vector.<uint>=new Vector.<uint>();
			np.length=p.length;
			np.fixed=true;
			
			for(var i:uint=0;i<np.length;++i) {
				np[i]=fromRGB555(p[i]);
			}
			
			return np;
		}
		
		private static function colorScaleUp(x:uint):uint {
			return x<<3 | x >>> 2;
		}

	}
	
}
