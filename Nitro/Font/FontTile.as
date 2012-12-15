package Nitro.Font {
	
	import flash.utils.*;
	import flash.display.*;
	
	import HTools.ByteArrayBitStream;
	
	public class FontTile {
		
		public var pixels:ByteArray;
		
		public var start:uint;
		public var width:uint;
		public var length:uint;
		
		private var font:NFTR;

		public function FontTile(font) {
			this.font=font;
		}
		
		public function toBMD():BitmapData {
			var bmd:BitmapData=new BitmapData(font.tileWidth,font.tileHeight,true,0x00FF00FF);
			bmd.lock();
			
			var bits:ByteArrayBitStream=new ByteArrayBitStream(pixels);
			
			for(var y:uint=0;y<font.tileHeight;++y) {
				for(var x:uint=0;x<font.tileWidth;++x) {
					
					//read in Nbits
					var cv:uint;
					for(var d:uint=0;d<font.tileDepth;++d) {
						cv<<=1;
						cv|=uint(bits.readBit());
					}
					cv&=0xFF;
					
					//extend the fraction to full 8 bits
					var c:uint=0;
					for(d=0;d<7;d+=font.tileDepth) {
						c<<=font.tileDepth;
						c|=cv;
					}
					
					c&=0xFF;
					
					//invert the grayscale so that filled areas become black
					var ic:uint=255-c;
					
					//convert the grayscale to RGB
					var argb=ic | ic<< 8 | ic<<16;
					
					//and set the alpha
					argb|=c<<24;
					
					bmd.setPixel32(x,y,argb);
				}
			}
			
			bmd.unlock();
			return bmd;
		}
		
		public function getDebugView():DisplayObject {
			var o:Sprite=new Sprite();
			
			var b:Bitmap=new Bitmap(toBMD());
			o.addChild(b);
			
			var s:Shape=new Shape();
			o.addChild(s);
			
			s.graphics.lineStyle(1,0xFFFF0000);
			s.graphics.moveTo(start,0);
			s.graphics.lineTo(start,font.tileHeight);
			
			s.graphics.lineStyle(1,0xFFFFFF00);
			s.graphics.moveTo(width+start,0);
			s.graphics.lineTo(width+start,font.tileHeight);
			
			o.rotation=font.tileRotation;
			
			return o;
		}

	}
	
}
