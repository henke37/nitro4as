package Nitro.Graphics {
	import flash.utils.*;
	import flash.display.*;
	
	public class Tile {
		
		public var pixels:Vector.<uint>;//palette indexes
		
		public static const width:uint=8;
		public static const height:uint=8;

		public function Tile() {
			// constructor code
		}
		
		public function readTile(bits:uint,data:ByteArray):void {
			
			if(bits!=4 && bits!=8) throw new ArgumentError("Only 4 and 8 bit tiles are supported!");
			
			pixels=new Vector.<uint>();
			pixels.length=width*height;
			pixels.fixed=true;
			
			var x:uint,y:uint;
			var index:uint;
			
			if(bits==4) {
				
				for(y=0;y<height;++y) {
					for(x=0;x<width;) {
						var nibble:uint=data.readUnsignedByte();
						
						index=(x++)+y*width;						
						pixels[index]=nibble & 0xF;
						
						index=(x++)+y*width;						
						pixels[index]=nibble >> 4 & 0xF;
					}
				}
			} else if(bits==8) {
				for(y=0;y<height;++y) {
					for(x=0;x<width;) {
						index=(x++)+y*width;
						pixels[index]=data.readUnsignedByte();
					}
				}
			}
		}
		
		private var rendered:BitmapData;
		private var renderedPalette:Vector.<uint>;
		private var renderedPaletteOffset:uint;
		private var renderedUseTransparency:Boolean;
		
		public function toBMD(palette:Vector.<uint>,paletteOffset:uint=0,useTransparency:Boolean=true):BitmapData {
			
			if(rendered && renderedPalette==palette && renderedPaletteOffset==paletteOffset && renderedUseTransparency==useTransparency) {
				return rendered;
			}
			
			var bmd:BitmapData=new BitmapData(width,height);
			
			bmd.lock();
			
			for(var y:uint=0;y<height;++y) {
				for(var x:uint=0;x<width;++x) {
					var index:uint=x+y*width;
					var color:uint=pixels[index];
					if(color==0 && useTransparency) {
						bmd.setPixel32(x,y,0x00FFFF00);
					} else {
						bmd.setPixel(x,y,palette[color+paletteOffset*16]);
					}
				}
			}
			
			bmd.unlock();
			
			rendered=bmd;
			renderedPalette=palette;
			renderedPaletteOffset=paletteOffset;
			renderedUseTransparency=useTransparency;
			
			return bmd;
		}
	}
	
}
