package Nitro.Graphics {
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	public class NSCR {
		
		public var width:uint;
		public var height:uint;
		
		public var dataHeight:uint;
		public var dataWidth:uint;
		
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
			
			var size:uint=section.readUnsignedShort();
			var mode:uint=section.readUnsignedShort();
			
			if(mode==0) {
				dataHeight=[256,256,512,512][size];
				dataWidth=[256,512,256,512][size];
			} else {
				dataHeight=[128,256,512,1024][size];
				dataWidth=[128,256,512,1024][size];
			}
			
			section.position=0x0C;
			
			entries=new Vector.<TileEntry>();
			entries.length=(height/Tile.height)*(width/Tile.width);
			entries.fixed=true;
			
			for(var y:uint=0;y<height;y+=Tile.height) {
				for(var x:uint=0;x<width;x+=Tile.width) {
					var value:uint=section.readUnsignedShort();
					
					var entry:TileEntry=new TileEntry();
					
					entry.tile=value & 0x3FF;
					entry.xFlip=(value & 0x400) == 0x400;
					entry.yFlip=(value & 0x800) == 0x800;
					entry.palette=value >> 12;
					
					var index:uint=(width/Tile.width)*(y/Tile.height)+(x/Tile.width);
					
					entries[index]=entry;
				}
			}
		}
		
		public function render(tiles:NCGR,convertedPalette:Vector.<uint>,useTransparency:Boolean=true):Sprite {
			var spr:Sprite=new Sprite();
			
			var tileCache:Object={};
			
			//var hits:uint,misses:uint;
			
			for(var y:uint=0;y<height;y+=Tile.height) {
				for(var x:uint=0;x<width;x+=Tile.width) {
					
					var index:uint=(width/Tile.width)*(y/Tile.height)+(x/Tile.width);
					
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
						//hits++;
					} else {
						bmd=tiles.renderTile(entry.tile,convertedPalette,entry.palette,useTransparency);
						paletteCache[entry.tile]=bmd;
						//misses++;
					}
					
					var bitmap:Bitmap=new Bitmap(bmd);
					bitmap.x=x;
					bitmap.y=y;
					
					if(entry.xFlip) {
						bitmap.scaleX=-1;
						bitmap.x+=Tile.width;
					}
					
					if(entry.yFlip) {
						bitmap.scaleY=-1;
						bitmap.y+=Tile.height;
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