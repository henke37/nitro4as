package Nitro.Apollo {
	import flash.utils.*;
	import flash.display.*;
	import flash.geom.*;
	
	import Nitro.Graphics.*;
	
	
	public class IndexedBitmap {
		
		private var tiles:Vector.<Tile>;
		
		private var rawPalette:Vector.<uint>;
		
		/** The width of the image */
		public var width:uint;
		
		/** The height of the image */
		public var height:uint;

		public function IndexedBitmap() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			
			data.endian=Endian.LITTLE_ENDIAN;
			data.position=0;
			
			width=data.readUnsignedShort();
			height=data.readUnsignedShort() & ~0x00008000;
			
			const shortSize:uint=4+16*2+width*height/2;
			
			const bpp:uint=((shortSize==data.length)?4:8);
			
			const paletteSize:uint=((bpp==4)?16:256);
			
			rawPalette=new Vector.<uint>();
			rawPalette.length=paletteSize;
			rawPalette.fixed=true;
			
			for(var i:uint=0;i<paletteSize;++i) {
				rawPalette[i]=data.readUnsignedShort();
			}
			
			const xTiles:uint=width/Tile.width;
			const yTiles:uint=height/Tile.height;
			
			tiles=new Vector.<Tile>();
			tiles.length=yTiles*xTiles;
			tiles.fixed=true;
			
			for(var yPos:uint=0;yPos<yTiles;++yPos) {
				for(var xPos:uint=0;xPos<xTiles;++xPos) {
					var tile:Tile=new Tile();
					tile.readTile(bpp,data);
					tiles[yPos*xTiles+xPos]=tile;
				}
			}
		}
		
		public function toBMD():BitmapData {
			var out:BitmapData=new BitmapData(width,height);
			
			out.lock();
			
			const xTiles:uint=width/Tile.width;
			const yTiles:uint=height/Tile.height;
			
			var convertedPalette:Vector.<uint>=RGB555.paletteFromRGB555(rawPalette);
			
			const srcRect:Rectangle=new Rectangle(0,0,Tile.width,Tile.height);
			var dstPnt:Point=new Point(0,0);
			
			for(var yPos:uint=0;yPos<yTiles;++yPos) {
				
				dstPnt.y=yPos*Tile.height;
				
				for(var xPos:uint=0;xPos<xTiles;++xPos) {
					var tile:Tile=tiles[yPos*xTiles+xPos];
					var tileBMD:BitmapData=tile.toBMD(convertedPalette);
					
					dstPnt.x=xPos*Tile.width;
					
					out.copyPixels(tileBMD,srcRect,dstPnt);
				}
			}
			
			out.unlock();
			return out;
		}

	}
	
}
