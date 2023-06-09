﻿package Nitro.Graphics {
	import flash.utils.*;
	import flash.display.*;
	
	public class TileMappedScreen {
		
		/** The width of the screen data, measured in tiles. */
		public var cols:uint;
		/** The height of the screen data, measured in tiles. */
		public var rows:uint;
		
		/** The tiles that composes the screen. */
		public var entries:Vector.<TileEntry>;

		public function TileMappedScreen() {
			// constructor code
		}
		
		/** The height of the screen data, measured in pixels. */
		public function get height():uint { return Tile.height*rows; }
		/** The width of the screen data, measured in pixels */
		public function get width():uint { return Tile.width*cols; }
		
		/** Loads tile entries from a ByteArray
		@param data The ByteArray to load entries from 
		@param cols The number of colums in the screen
		@param rows The number of rows in the screen
		@param advanced If the advanced tilemap fomat is used
		*/
		public function loadEntries(data:ByteArray,cols:uint,rows:uint,advanced:Boolean):void {
			this.cols=cols;
			this.rows=rows;
			
			entries=new Vector.<TileEntry>();
			entries.length=cols*rows;
			entries.fixed=true;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			if(advanced) {
				loadAdvancedEntries(data);
			} else {
				loadSimpleEntries(data);
			}
		}
		
		private function loadAdvancedEntries(data:ByteArray):void {
			
			for(var row:uint=0;row<rows;++row) {
				for(var col:uint=0;col<cols;++col) {
					var value:uint=data.readUnsignedShort();
					
					var entry:TileEntry=new TileEntry();
					
					entry.tile=value & 0x3FF;
					entry.xFlip=(value & 0x400) == 0x400;
					entry.yFlip=(value & 0x800) == 0x800;
					entry.palette=value >> 12;
					
					var index:uint=(cols)*(row)+col;
					
					entries[index]=entry;
				}
			}
		}
		
		private function loadSimpleEntries(data:ByteArray):void {
			
			for(var row:uint=0;row<rows;++row) {
				for(var col:uint=0;col<cols;++col) {
					var value:uint=data.readUnsignedByte();
					
					var entry:TileEntry=new TileEntry();
					
					entry.tile=value;
					
					var index:uint=(cols)*(row)+col;
					
					entries[index]=entry;
				}
			}
		}
		
		
		/** Renders the screen to a new Sprite
		@param tiles The GraphicsBank from which to read the tiles
		@param convertedPalette The palette to use when rendering the tiles, in RGB888 format
		@param useTransparency If the screen should be rendered using transparency
		@return A new Sprite with the tiles of the screen correctly laid out
		*/
		public function render(tiles:GraphicsBank,convertedPalette:Vector.<uint>,useTransparency:Boolean=true):Sprite {
			return renderViewport(tiles,convertedPalette,useTransparency);
		}
		
		public function renderViewport(tiles:GraphicsBank,convertedPalette:Vector.<uint>,useTransparency:Boolean=true,startX:uint=0,startY:uint=0,endX:uint=0xFFFFFFFF,endY:uint=0xFFFFFFFF):Sprite {
			var spr:Sprite=new Sprite();
			
			var paletteCache:Object={};
			
			if(endX==0xFFFFFFFF) endX=cols;
			if(endY==0xFFFFFFFF) endY=rows;
			
			//var hits:uint,misses:uint;
			
			for(var tileY:uint=0;tileY<endY;++tileY) {
				var y:Number=tileY*Tile.height;
				for(var tileX:uint=0;tileX<endX;++tileX) {
					
					var x:Number=tileX*Tile.width;
					
					var index:uint=tileX+tileY*cols;//not the endX value, but the width
					
					var entry:TileEntry=entries[index];
					
					var tileCache:Object;
					
					if(paletteCache[entry.palette]) {
						tileCache=paletteCache[entry.palette];
					} else {
						tileCache={};
						paletteCache[entry.palette]=tileCache;
					}
					
					var bmd:BitmapData;
					if(tileCache[entry.tile]) {
						bmd=tileCache[entry.tile];
						//hits++;
					} else {
						bmd=tiles.renderTile(entry.tile,convertedPalette,entry.palette,useTransparency);
						tileCache[entry.tile]=bmd;
						//misses++;
					}
					
					var bitmap:Bitmap=new Bitmap(bmd);
					bitmap.x=x;
					bitmap.y=y;
					
					if(entry.xFlip) {
						bitmap.scaleX=-1;
						bitmap.x+=Tile.width;
					}
					
					if(entry.yFlip) {
						bitmap.scaleY=-1;
						bitmap.y+=Tile.height;
					}
					
					spr.addChild(bitmap);
				}
			}
			
			//trace(hits,misses);
			
			return spr;
		}

	}
	
}
