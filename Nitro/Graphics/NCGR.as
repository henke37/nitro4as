package Nitro.Graphics {
	
	import flash.utils.*;
	import flash.display.*;
	
	public class NCGR {
		
		private const sectionOffset:uint=0x10;
		
		public var tiles:Vector.<Tile>;
		
		public var tilesX:uint,tilesY:uint;
		
		private const tileWidth:uint=8;
		private const tileHeight:uint=8;

		public function NCGR() {
		}
		
		public function parse(data:ByteArray):void {
			var type:String;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			type=data.readUTFBytes(4);
			if(type!="RGCN") throw new ArgumentError("Incorrect file header, type is "+type);
			
			data.position=sectionOffset;
			type=data.readUTFBytes(4);
			if(type!="RAHC") throw new ArgumentError("Incorrect file header, section type is "+type);
			
			data.position=sectionOffset+8;
			tilesY=data.readUnsignedShort();
			tilesX=data.readUnsignedShort();
			
			var bitDepth:uint=1 << (data.readUnsignedInt()-1);
			
			tiles=new Vector.<Tile>();
			tiles.length=tilesY*tilesX;
			tiles.fixed=true;
			
			data.position=sectionOffset+0x14;
			var tiled:Boolean=data.readUnsignedInt()==0;
			
			data.position=0x20;
			for(var y:uint=0;y<tilesY;++y) {
				for(var x:uint=0;x<tilesX;++x) {
					var tile:Tile=new Tile();
					tile.readTile(tileWidth,tileHeight,bitDepth,data);
					
					var index:uint=x+y*tilesX;
					
					tiles[index]=tile;
				}
			}
		}

	}
	
}
