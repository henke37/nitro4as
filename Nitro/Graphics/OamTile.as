package Nitro.Graphics {
	
	import flash.display.*;
	import flash.text.*;
	
	/** A basic tile group that can be used for storing just the data about the tile in general */
	public class OamTile {
		
		public var paletteIndex:uint;
		public var tileIndex:uint;
		
		public var colorDepth:uint;
		
		public var width:uint;
		public var height:uint;

		public function OamTile() {
			// constructor code
		}
		
		/** Rends the tile group accordingly to the settings
		@param palette The RGB888 palette to use when rendering the tiles
		@param tiles The tiles pixel data to use
		@param useSubImages If sub image addressing should be used
		@param useTransparency If the tiles should be rendered using transparency
		@return A DisplayObject that represents the tile group
		*/
		public function rend(palette:Vector.<uint>,tiles:NCGR,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var oamR:DisplayObject=tiles.renderOam(this,palette,useSubImages,useTranparency);
			
			return oamR;
		}
		
		/** Draws a rectangle that represents the OAM
		@param boxColor The stroke color for the rectangle
		@param useFill If the rectangle should be filled
		@param tileNumbers If the tile number should be displayed
		@return A DisplayObject that contains the drawn rectangle*/
		public function drawBox(boxColor:uint=0,useFill:Boolean=true,tileNumbers:Boolean=true):DisplayObject {
			
			var spr:Sprite=new Sprite();
			spr.graphics.lineStyle(1,boxColor);
			
			if(useFill) {
				spr.graphics.beginFill(0xFFFFFF);
			}			
			spr.graphics.drawRect(0,0,width,height);
			if(useFill) {
				spr.graphics.endFill();
			}
			
			
			if(tileNumbers) {
				addTileNumber(spr);
			}
			return spr;
		}
		
		protected function addTileNumber(spr:Sprite):void {
			var tf:TextField=new TextField();
			tf.autoSize=TextFieldAutoSize.LEFT;
			tf.selectable=false;
			tf.text=String(tileIndex);
			
			spr.addChild(tf);
		}
		
		
		internal function setSize(size:uint,shape:uint):void {
			switch(shape) {
				case 0:
					width=height=8 << size;
				break;
				
				case 1:
					width=[16,32,32,64][size];
					height=[8,8,16,32][size];
				break;
				
				case 2:
					width=[8,8,16,32][size];
					height=[16,32,32,64][size];
				break;
			}
		}
		
		internal function getSize():uint {
			switch(width) {
				case 8:
					switch(height) {
						case 8: return 0;
						case 16: return 0;
						case 32: return 1;
					}
				break;
				
				case 16:
					switch(height) {
						case 16: return 1;
						case 8: return 0;
						case 32: return 2;
					}
				break;
				
				case 32:
				 	switch(height) {
						case 32: return 2;
						case 8: return 1;
						case 16: return 2;
						case 64: return 3;
					}
				break;
				
				case 64:
					switch(height) {
						case 64: return 3;
						case 32: return 3;
					}
				break;
			}
			throw new Error("invalid h/w combo");
		}
		
		public function cloneOamTile():OamTile {
			var o:OamTile=new OamTile();
			o.paletteIndex=paletteIndex;
			o.tileIndex=tileIndex;
			o.width=width;
			o.height=height;
			return o;
		}

	}
	
}
