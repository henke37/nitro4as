package Nitro.Graphics {
	import flash.display.*;
	
	public class CellOam {
		
		public var y:int;
		public var x:int;
		public var hide:Boolean;
		public var doubleSize:Boolean;
		
		public var xFlip:Boolean;
		public var yFlip:Boolean;
		
		public var paletteIndex:uint;
		public var tileIndex:uint;
		
		public var width:uint;
		public var height:uint;

		public function CellOam() {
			// constructor code
		}
		
		internal function rend(palette:Vector.<uint>,tiles:NCGR,subImages:Boolean,useTransparency:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			
			const baseX:uint=tileIndex%tiles.tilesX;
			const baseY:uint=tileIndex/tiles.tilesX;
			
			const yTiles:uint=height/Tile.height;
			const xTiles:uint=width/Tile.width;
			
			for(var y:uint=0;y<yTiles;++y) {
				for(var x:uint=0;x<xTiles;++x) {
					
					var subTileIndex:uint;
					
					if(subImages) {
						var subTileYIndex:uint=baseY+y;
						var subTileXIndex:uint=baseX+x;
						
						subTileIndex=subTileXIndex+subTileYIndex*tiles.tilesX;
					} else {
						subTileIndex=tileIndex+x+y*xTiles;
					}
					
					var tileR:DisplayObject=tiles.renderTile(subTileIndex,palette,paletteIndex,useTransparency);
					
					tileR.x=Tile.width*x;
					tileR.y=Tile.height*y;
					
					spr.addChild(tileR);
				}
			} 
			
			
			
			return spr;
		}
		
		internal function setSize(size:uint,shape:uint) {
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

	}
	
}
