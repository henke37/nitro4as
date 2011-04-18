package Nitro.Graphics {
	import flash.utils.*;
	import flash.display.*;
	
	public class Tile {
		
		public var width:uint;
		public var height:uint;
		
		public var pixels:Vector.<uint>;//palette indexes

		public function Tile() {
			// constructor code
		}
		
		public function readTile(w:uint,h:uint,bits:uint,data:ByteArray):void {
			
			if(bits!=4 && bits!=8) throw new ArgumentError("Only 4 and 8 bit tiles are supported!");
			
			width=w;
			height=h;
			
			pixels=new Vector.<uint>();
			pixels.length=w*h;
			pixels.fixed=true;
			
			var x:uint,y:uint;
			var index:uint;
			
			if(bits==4) {
				
				for(y=0;y<h;++y) {
					for(x=0;x<w;) {
						var nibble:uint=data.readUnsignedByte();
						
						index=(x++)+y*w;						
						pixels[index]=nibble & 0xF;
						
						index=(x++)+y*w;						
						pixels[index]=nibble >> 4 & 0xF;
					}
				}
			} else if(bits==8) {
				for(y=0;y<h;++y) {
					for(x=0;x<w;) {
						index=(x++)+y*w;
						pixels[index]=data.readUnsignedByte();
					}
				}
			}
		}
		
		public function toBMD(palette:Vector.<uint>,paletteOffset:uint=0):BitmapData {
			var bmd:BitmapData=new BitmapData(width,height);
			
			bmd.lock();
			
			for(var y:uint=0;y<height;++y) {
				for(var x:uint=0;x<width;++x) {
					var index:uint=x+y*width;
					bmd.setPixel(x,y,palette[pixels[index]+paletteOffset]);
				}
			}
			
			bmd.unlock();
			
			return bmd;
		}
	}
	
}
