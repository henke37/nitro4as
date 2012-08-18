package Nitro.Graphics {
	
	import flash.display.*;
	import flash.utils.*;
	
	/** Utility class that converts a BitmapData into a palette and NCGR file */
	public class NCGRCreator {
		
		private var picture:BitmapData;
		
		/** The palette used for encoding the picture, in RGB555 */
		public var palette:Vector.<uint>;
		
		/** The NCGR where the tiles are stored */
		public var ncgr:NCGR;
		
		/** Creates a NCGR file from a BitmapData */

		public function NCGRCreator() {
			ncgr=new NCGR();
		}
		
		/** Sets the picture to build from
		@param p The BitmapData to work on */
		public function set pic(p:BitmapData):void {
			
			if(!p) throw new ArgumentError("Pic can not be null!");
			if(p.width%Tile.width!=0) throw new ArgumentError("Pic must be evenly divideable with the tile width ("+Tile.width+")!");
			if(p.height%Tile.height!=0) throw new ArgumentError("Pic must be evenly divideable with the tile height ("+Tile.height+")!");
			
			picture=p;
		}
		
		/** Computes the optimal palette for the current picture
		@throws ArgumentError The picture has too many colors*/
		public function findPalette(useTransparency:Boolean=true):void {
			
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
			
			var paletteMaxLen:uint=256;
			
			if(colorOccurances[colorOrder[paletteMaxLen]]>0) throw new ArgumentError("Picture has more colors than fits in the palette!");
			
			for(i=0;i<256;++i) {
				if(colorOccurances[colorOrder[i]]==0) {
					paletteMaxLen=i+1;
					break;
				}
			}
			
			palette=new Vector.<uint>();
			palette.length=paletteMaxLen;
			palette.fixed=true;
			
			if(useTransparency) {
				palette[0]=RGB555.toRGB555(0xFFAA00);//transparency is orange
			}
			
			for(i=0;i<paletteMaxLen-1;++i) {
				color=colorOrder[i];
				
				if(colorOccurances[color]==0) break;
				
				palette[i+1]=color;
			}
		}
		
		/** Builds the tiles for the current picture */
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
			ncgr.bitDepth=(palette.length<=16?4:8);
			ncgr.loadTiles(tiles,tilesX,tilesY);
			
		}
		
		

		
	}
	
}
