package Nitro.Graphics {
	import flash.display.*;
	import flash.text.*;
	
	public class Cell {
		
		public var oams:Vector.<CellOam>;

		public function Cell() {
			// constructor code
		}
		
		public function rend(palette:Vector.<uint>,tiles:NCGR,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			for each(var oam:CellOam in oams) {
				
				var oamR:DisplayObject=oam.rend(palette,tiles,useTranparency);
				
				spr.addChildAt(oamR,0);
			}
			
			return spr;
		}
		
		public function rendBoxes(tileNumbers:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			
			
			for each(var oam:CellOam in oams) {
				spr.addChild(oam.drawBox());
			}
			
			return spr;
		}

	}
	
}
