package Nitro.Graphics {
	import flash.display.*;
	import flash.text.*;
	
	public class CellOam extends OamTile {
		
		public var y:int;
		public var x:int;
		public var hide:Boolean;
		public var doubleSize:Boolean;
		
		public var xFlip:Boolean;
		public var yFlip:Boolean;
		
		public function CellOam() {
			// constructor code
		}
		
		
		public function rend(palette:Vector.<uint>,tiles:NCGR,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var oamR:DisplayObject=tiles.renderOam(this,palette,useSubImages,useTranparency);
				
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
		
		public function drawBox(boxColor:uint=0,useFill:Boolean=true,tileNumbers:Boolean=true):DisplayObject {
			
			var spr:Sprite=new Sprite();
			spr.graphics.lineStyle(1,boxColor);
			
			if(useFill) {
				spr.graphics.beginFill(0xFFFFFF);
			}			
			spr.graphics.drawRect(x,y,width,height);
			if(useFill) {
				spr.graphics.endFill();
			}
			
			
			if(tileNumbers) {
				var tf:TextField=new TextField();
				tf.x=x;
				tf.y=y;
				tf.autoSize=TextFieldAutoSize.LEFT;
				tf.selectable=false;
				tf.text=String(tileIndex);
				
				if(xFlip) tf.appendText("XF");
				if(yFlip) tf.appendText("YF");
				
				spr.addChild(tf);
			}
			return spr;
		}
	}
	
}
