package Nitro.Graphics {
	import flash.utils.*;
	import flash.display.*;
	
	/** A single 8 by 8 tile. */
	
	public class Tile {
		
		/** The pixel data for the tile. Each element is a palette index. */
		public var pixels:Vector.<uint>;
		
		/** The width of a tile */
		public static const width:uint=8;
		/** The height of a tile */
		public static const height:uint=8;

		public function Tile() {
			pixels=new Vector.<uint>();
			pixels.length=width*height;
			pixels.fixed=true;
		}
		
		/** Reads a tile from a ByteArray
		@param bits The number of bits per pixel
		@throws ArgumentError The number of bits per pixel is not supported
		@param data The ByteArray to read from
		*/
		public function readTile(bits:uint,data:ByteArray):void {
			
			if(bits!=4 && bits!=8) throw new ArgumentError("Only 4 and 8 bit tiles are supported!");
			
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
		
		/** Draws a tile to a BitmapData object
		@param palette The palette to use when drawing, in RGB888 format
		@param paletteOffset The subpalette to use
		@param useTransparency If the tile should be drawn with palette index 0 as transparency
		@return A BitmapData of the tile. */
		public function toBMD(palette:Vector.<uint>,paletteOffset:uint=0,useTransparency:Boolean=true):BitmapData {
			
			if(rendered && renderedPalette==palette && renderedPaletteOffset==paletteOffset && renderedUseTransparency==useTransparency) {
				return rendered;
			}
			
			var bmd:BitmapData=new BitmapData(width,height,useTransparency);
			
			bmd.lock();
			
			var index:uint=0;
			
			for(var y:uint=0;y<height;++y) {
				for(var x:uint=0;x<width;++x) {
					var color:uint=pixels[index++];
					if(color==0 && useTransparency) {
						bmd.setPixel32(x,y,0x00FFFF00);
					} else {
						color=palette[color+paletteOffset*16];
						bmd.setPixel(x,y,color);
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
		
		/** Loads a tile from a BitmapData using a palette
		@param colorIndexes The palette to use, in RGB555 format
		@param useTransparency If the first palette index is transparency or not
		@param bmd The BitmapData to load from
		@param xStart The leftmost position of the tile in the BitmapData
		@param yStart The topmost position of the tile in the BitmapData
		@return A new Tile
		*/
		public static function fromBitmap(colorIndexes:Object,useTransparency:Boolean,bmd:BitmapData,xStart:uint,yStart:uint):Tile {
			var tile:Tile=new Tile();
			
			for(var y:uint=0;y<height;++y) {
				for(var x:uint=0;x<width;++x) {
					var index:uint=x+y*width;
					var color:uint=bmd.getPixel32(x+xStart,y+yStart);
					
					var alpha:uint=color >>> 24;
					
					if(alpha < 0x80 && useTransparency) {
						tile.pixels[index]=0;
						continue;
					}
					
					color=RGB555.toRGB555(color);
					
					if(color in colorIndexes) {
						tile.pixels[index]=colorIndexes[color];
					} else {
						tile.pixels[index]=0;
					}
				}
			}
			
			return tile;
		}
		
		/** Writes a tile to a ByteArray
		@param bits The number of bits per pixel
		@param data The ByteArray to write to
		@throws ArgumentError The number of bits per pixel is not supported
		*/
		public function writeTile(bits:uint,data:ByteArray):void {
			if(bits!=4 && bits!=8) throw new ArgumentError("Only 4 and 8 bit tiles are supported!");
			
			var x:uint,y:uint;
			var index:uint;
			
			if(bits==4) {
				
				for(y=0;y<height;++y) {
					for(x=0;x<width;) {
						var nibble:uint;
						
						index=(x++)+y*width;						
						nibble=pixels[index] & 0xF;
						
						index=(x++)+y*width;						
						nibble|=(pixels[index] & 0xF )<<4 ;
						data.writeByte(nibble);
					}
				}
			} else if(bits==8) {
				for(y=0;y<height;++y) {
					for(x=0;x<width;) {
						index=(x++)+y*width;
						data.writeByte(pixels[index]);
					}
				}
			}
		}
	}
	
}
