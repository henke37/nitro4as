package Nitro.Graphics {
	import flash.display.*;
	import flash.text.*;
	
	public class Cell {
		
		public var oams:Vector.<CellOam>;

		public function Cell() {
			// constructor code
		}
		
		internal function rend(palette:Vector.<uint>,tiles:NCGR,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			for each(var oam:CellOam in oams) {
				
				var oamR:DisplayObject=tiles.renderOam(oam,palette,useSubImages,useTranparency);
				
				
				oamR.x=oam.x;
				oamR.y=oam.y;
				
				if(oam.xFlip) {
					oamR.x+=oam.width;
					oamR.scaleX=-1;
				}
				
				if(oam.yFlip) {
					oamR.y+=oam.height;
					oamR.scaleY=-1;
				}
				
				spr.addChildAt(oamR,0);
			}
			
			return spr;
		}
		
		public function rendBoxes(tileNumbers:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			spr.graphics.lineStyle(1);
			
			for each(var oam:CellOam in oams) {
				spr.graphics.drawRect(oam.x,oam.y,oam.width,oam.height);
				if(tileNumbers) {
					var tf:TextField=new TextField();
					tf.x=oam.x;
					tf.y=oam.y;
					tf.text=String(oam.tileIndex);
					
					if(oam.xFlip) tf.appendText("XF");
					if(oam.yFlip) tf.appendText("YF");
					
					spr.addChild(tf);
				}
			}
			
			return spr;
		}

	}
	
}
