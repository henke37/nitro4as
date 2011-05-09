package Nitro.Graphics {
	
	import flash.display.*;
	import flash.utils.*;
	
	public class NCGRCreator {
		
		private var picture:BitmapData;
		
		public var palette:Vector.<uint>;
		
		private const paletteMaxLen:uint=256;
		
		public var ncgr:NCGR;

		public function NCGRCreator() {
			ncgr=new NCGR();
		}
		
		//load picture
		public function set pic(p:BitmapData):void {
			
			if(!p) throw new ArgumentError("Pic can not be null!");
			if(p.width%Tile.width!=0) throw new ArgumentError("Pic must be evenly divideable with the tile width ("+Tile.width+")!");
			if(p.height%Tile.height!=0) throw new ArgumentError("Pic must be evenly divideable with the tile height ("+Tile.height+")!");
			
			picture=p;
		}
		
		public function findPalette():void {
			
			var color:uint;
			
			//build palette
			var colorOccurances:Vector.<uint>=new Vector.<uint>;
			
			colorOccurances.length=(1 << 15);
			colorOccurances.fixed=true;
			
			for(var y:uint=0;y<picture.height;++y) {
				for(var x:uint=0;x<picture.width;++x) {
					color=picture.getPixel32(x,y);
					
					//if((color & 0xFF000000)!=0xFF000000) continue;
					
					color=RGB555.toRGB555(color);
					
					++colorOccurances[color];
				}
			}
			
			//var colorOrder:Vector.<uint>=colorOccurances.sort(Array.RETURNINDEXEDARRAY| Array.DESCENDING| Array.NUMERIC );
			
			
			
			function sortComp(a:uint,b:uint):int {
				return colorOccurances[b]-colorOccurances[a];
			}
			
			var colorOrder:Vector.<uint>=new Vector.<uint>();
			colorOrder.length=colorOccurances.length;
			colorOrder.fixed=true;
			for(var i:uint=0;i<colorOrder.length;++i) {
				colorOrder[i]=i;
			}
			colorOrder=colorOrder.sort(sortComp);
			
			if(colorOccurances[colorOrder[paletteMaxLen]]>0) throw new ArgumentError("Picture has more colors than fits in the palette!");
			
			
			
			palette=new Vector.<uint>();
			palette.length=paletteMaxLen;
			palette.fixed=true;
			
			palette[0]=RGB555.toRGB555(0xFFAA00);//transparency is orange
			
			for(i=0;i<paletteMaxLen-1;++i) {
				color=colorOrder[i];
				
				if(colorOccurances[color]==0) break;
				
				palette[i+1]=color;
			}
		}
		
		//save palette
		
		//build tiles
		public function buildTiles(useTransparency:Boolean):void {
			var colorIndexes:Object={};
			var i:uint;
			
			for each(var color:uint in palette) {
				colorIndexes[color]=i++;
			}
			
			const tilesY:uint=picture.height/Tile.height;
			const tilesX:uint=picture.width/Tile.width;
			
			var tiles:Vector.<Tile>=new Vector.<Tile>();
			tiles.length=tilesX*tilesY;
			tiles.fixed=true;
			
			for(var tileY:uint=0;tileY<tilesY;++tileY) {
				for(var tileX:uint=0;tileX<tilesX;++tileX) {
					var tile:Tile=Tile.fromBitmap(colorIndexes,useTransparency,picture,tileX*Tile.width,tileY*Tile.height);
					var tileIndex:uint=tileY*tilesX+tileX;
					tiles[tileIndex]=tile;
				}
			}
			
			//save tiles
			ncgr.loadTiles(tiles,tilesX,tilesY);
			
		}
		
		

		
	}
	
}
