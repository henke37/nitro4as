package Nitro.Graphics {
	import flash.display.*;
	
	public class Cell {
		
		public var oams:Vector.<CellOam>;
		
		public var label:String;

		public function Cell() {
			// constructor code
		}
		
		internal function rend(palette:NCLR,tiles:NCGR,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			for each(var oam:CellOam in oams) {
				
				var oamR:DisplayObject=oam.rend(palette.colors,tiles,useSubImages,useTranparency);
				
				
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

	}
	
}
