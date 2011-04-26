package Nitro.Graphics {
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	public class NSCR {
		
		public var width:uint;
		public var height:uint;
		
		private const tileWidth:uint=8;
		private const tileHeight:uint=8;
		
		private var entries:Vector.<TileEntry>;

		public function NSCR() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RCSN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			var section:ByteArray=sections.open("NRCS");
			section.endian=Endian.LITTLE_ENDIAN;
			
			height=section.readUnsignedShort();
			width=section.readUnsignedShort();
			
			section.position=0x0C;
			
			entries=new Vector.<TileEntry>();
			entries.length=(height/tileHeight)*(width/tileWidth);
			entries.fixed=true;
			
			for(var y:uint=0;y<height;y+=tileHeight) {
				for(var x:uint=0;x<width;x+=tileWidth) {
					var value:uint=section.readUnsignedShort();
					
					var entry:TileEntry=new TileEntry();
					
					entry.tile=value & 0x3FF;
					entry.xFlip=(value & 0x400) == 0x400;
					entry.yFlip=(value & 0x800) == 0x800;
					entry.palette=value >> 12;
					
					var index:uint=(width/tileWidth)*(y/tileHeight)+(x/tileWidth);
					
					entries[index]=entry;
				}
			}
		}
		
		public function render(tiles:NCGR,palette:NCLR):Sprite {
			var spr:Sprite=new Sprite();
			
			var tileCache:Object={};
			
			//var hits:uint,misses:uint;
			
			for(var y:uint=0;y<height;y+=tileHeight) {
				for(var x:uint=0;x<width;x+=tileWidth) {
					
					var index:uint=(width/tileWidth)*(y/tileHeight)+(x/tileWidth);
					
					var entry:TileEntry=entries[index];
					
					
					var paletteCache:Vector.<BitmapData>=new Vector.<BitmapData>();
					if(tileCache[entry.palette]) {
						paletteCache=tileCache[entry.palette];
					} else {
						paletteCache=new Vector.<BitmapData>();
						paletteCache.length=tiles.tilesX*tiles.tilesY;
						paletteCache.fixed=true;
						tileCache[entry.palette]=paletteCache;
					}
					
					var bmd:BitmapData;
					if(paletteCache[entry.tile]) {
						bmd=paletteCache[entry.tile];
						tile=null;
						//hits++;
					} else {
						var tile:Tile=tiles.tiles[entry.tile];
						bmd=tile.toBMD(palette.colors,(1 << palette.bitDepth) * entry.palette);
						paletteCache[entry.tile]=bmd;
						//misses++;
					}
					
					var bitmap:Bitmap=new Bitmap(bmd);
					bitmap.x=x;
					bitmap.y=y;
					
					if(entry.xFlip) {
						bitmap.scaleX=-1;
						bitmap.x+=tileWidth;
					}
					
					if(entry.yFlip) {
						bitmap.scaleY=-1;
						bitmap.y+=tileHeight;
					}
					
					spr.addChild(bitmap);
				}
			}
			
			//trace(hits,misses);
			
			return spr;
		}

	}
	
}

class TileEntry {
	public var tile:uint;
	public var xFlip:Boolean;
	public var yFlip:Boolean;
	public var palette:uint;
}