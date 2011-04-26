package Nitro.Graphics {
	
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	public class NCGR {
		
		public var tiles:Vector.<Tile>;
		
		public var tilesX:uint,tilesY:uint;
		
		public var bitDepth:uint;
		
		private const tileWidth:uint=8;
		private const tileHeight:uint=8;

		public function NCGR() {
		}
		
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RGCN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			var section:ByteArray=sections.open("RAHC");
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			tilesY=section.readUnsignedShort();
			tilesX=section.readUnsignedShort();
			
			bitDepth=1 << (section.readUnsignedInt()-1);
			
			tiles=new Vector.<Tile>();
			tiles.length=tilesY*tilesX;
			tiles.fixed=true;
			
			section.position=0x0C;
			var tiled:Boolean=section.readUnsignedInt()==0;
			
			section.position=0x18;
			for(var y:uint=0;y<tilesY;++y) {
				for(var x:uint=0;x<tilesX;++x) {
					var tile:Tile=new Tile();
					tile.readTile(tileWidth,tileHeight,bitDepth,section);
					
					var index:uint=x+y*tilesX;
					
					tiles[index]=tile;
				}
			}
		}
		
		public function render(palette:Vector.<uint>,paletteOffset:uint=0):Sprite {
			var spr:Sprite=new Sprite();
			for(var y:uint=0;y<tilesY;++y) {
				for(var x:uint=0;x<tilesX;++x) {
					var index:uint=x+y*tilesX;
					var tile:Tile=tiles[index];
					
					var bmd:BitmapData=tile.toBMD(palette,paletteOffset);
					var bitmap:Bitmap=new Bitmap(bmd);
					bitmap.x=x*tileWidth;
					bitmap.y=y*tileHeight;
					
					spr.addChild(bitmap);
				}
			}
			return spr;
		}

	}
	
}
