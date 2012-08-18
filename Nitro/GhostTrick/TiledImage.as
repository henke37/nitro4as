package Nitro.GhostTrick {
	import flash.utils.*;
	import flash.display.*;
	import flash.geom.*;
	
	import Nitro.Graphics.*;
	
	/** A reader for the tiled images found in cpac_2d.bin/4 */
	public class TiledImage {
		
		private var width:uint;
		private var height:uint;
		
		private var tiles:Vector.<Tile>;
		private var convertedPalette:Vector.<uint>;

		public function TiledImage() {
			// constructor code
		}
		
		/** Parses a tiled image
		@param data The ByteArray containing the tiled image
		*/
		public function parse(data:ByteArray):void {
			
			data.endian=Endian.LITTLE_ENDIAN;
			data.position=0;
			
			width=data.readUnsignedShort();
			var flags:uint=data.readUnsignedShort();
			height=flags & ~0x00008000;
			var nibbles:Boolean=Boolean(flags & 0x00008000);
			
			if(width%Tile.width!=0) throw new ArgumentError("The width has to be evenly divideable by the tile width!");
			if(height%Tile.height!=0) throw new ArgumentError("The height has to be evenly divideable by the tile height!");
			
			var bpp:uint=nibbles?4:8;
			
			data.position=512;
			
			convertedPalette=RGB555.readPalette(data,bpp);
			
			const tileCount:uint=width/8*height/8;
			
			tiles=new Vector.<Tile>();
			tiles.length=tileCount;
			tiles.fixed=true;
			
			for(var i:uint=0;i<tileCount;++i) {
				var tile:Tile=new Tile();
				tile.readTile(bpp,data);
				tiles[i]=tile;
			}
			
		}
		
		/** Converts the tiled image to a normal BitmapData object
		@param transparent If the image is transparent or not
		@return A new BitmapData object holding the converted image */
		public function toBMD(transparent:Boolean):BitmapData {
			var out:BitmapData=new BitmapData(width,height,transparent);
			
			out.lock();
			
			const xTiles:uint=width/Tile.width;
			const yTiles:uint=height/Tile.height;
			
			const srcRect:Rectangle=new Rectangle(0,0,Tile.width,Tile.height);
			var dstPnt:Point=new Point(0,0);
			
			const bigTileHeight:uint=2;
			const bigTileWidth:uint=2;
			const bigTileArea:uint=bigTileHeight*bigTileWidth;
			const bigXTiles:uint=xTiles/bigTileWidth;
			const bigYTiles:uint=yTiles/bigTileHeight;
			
			for(var bigYPos:uint=0;bigYPos<bigYTiles;++bigYPos) {
				for(var bigXPos:uint=0;bigXPos<bigXTiles;++bigXPos) {
					for(var smallYPos:uint=0;smallYPos<bigTileHeight;++smallYPos) {
						var totalYPos:uint=bigYPos*bigTileHeight+smallYPos;
						dstPnt.y=totalYPos*Tile.height;
						for(var smallXPos:uint=0;smallXPos<bigTileWidth;++smallXPos) {
							var totalXPos:uint=bigXPos*bigTileWidth+smallXPos;
							dstPnt.x=totalXPos*Tile.width;
							
							var tileIndex:uint=bigTileArea*(bigXPos+bigYPos*bigXTiles)+(smallXPos+smallYPos*bigTileWidth);
							var tile:Tile=tiles[tileIndex];
							
							var tileBMD:BitmapData=tile.toBMD(convertedPalette,0,transparent);
							
							out.copyPixels(tileBMD,srcRect,dstPnt);
						}
					}
				}
			}
			
			out.unlock();
			return out;
		}

	}
	
}
