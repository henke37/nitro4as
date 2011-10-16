package Nitro.Graphics {
	import flash.display.*;
	import flash.text.*;
	
	/** A tile group that can be displayed as an OAM */
	
	public class CellOam extends OamTile {
		
		public var y:int;
		public var x:int;
		public var hide:Boolean;
		public var doubleSize:Boolean;
		
		public var xFlip:Boolean;
		public var yFlip:Boolean;
		
		public var priority:uint;
		
		public function CellOam() {
			// constructor code
		}
		
		/** Rends the tile group accordingly to the settings
		@param palette The RGB888 palette to use when rendering the tiles
		@param tiles The tiles pixel data to use
		@param useSubImages If sub image addressing should be used
		@param useTransparency If the tiles should be rendered using transparency
		@return A DisplayObject that represents the tile group
		*/
		public override function rend(palette:Vector.<uint>,tiles:NCGR,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var oamR:DisplayObject=super.rend(palette,tiles,useSubImages,useTranparency);
				
			oamR.x=x;
			oamR.y=y;
			
			if(xFlip) {
				oamR.x+=width;
				oamR.scaleX=-1;
			}
			
			if(yFlip) {
				oamR.y+=height;
				oamR.scaleY=-1;
			}
			
			return oamR;
		}
		
		/** Draws a rectangle that represents the OAM
		@param boxColor The stroke color for the rectangle
		@param useFill If the rectangle should be filled
		@param tileNumbers If the tile number should be displayed
		@return A DisplayObject that contains the drawn rectangle*/
		public override function drawBox(boxColor:uint=0,useFill:Boolean=true,tileNumbers:Boolean=true):DisplayObject {
			
			var spr:DisplayObject=super.drawBox(boxColor,useFill,tileNumbers);
			spr.x=x;
			spr.y=y;
			
			return spr;
		}
		
		protected override function addTileNumber(spr:Sprite):void {
			var tf:TextField=new TextField();
			tf.autoSize=TextFieldAutoSize.LEFT;
			tf.selectable=false;
			tf.text=String(tileIndex);
			
			if(xFlip) tf.appendText("XF");
			if(yFlip) tf.appendText("YF");
			
			spr.addChild(tf);
		}
		
		
	}
	
}
