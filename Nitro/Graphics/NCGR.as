﻿package Nitro.Graphics {
	
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	public class NCGR {
		
		private var tiles:Vector.<Tile>;
		private  var picture:Vector.<uint>;
		
		public var tilesX:uint,tilesY:uint;
		public var gridX:uint,gridY:uint;
		
		public var bitDepth:uint;

		public function NCGR() {
		}
		
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RGCN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			var section:ByteArray=sections.open("RAHC");
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			tilesX=section.readUnsignedShort();
			tilesY=section.readUnsignedShort();
			
			bitDepth=1 << (section.readUnsignedInt()-1);
			
			gridX=section.readUnsignedShort();
			gridY=section.readUnsignedShort();
			
			var tileType:uint=section.readUnsignedInt();
			
			
			
			var dataSize:uint=section.readUnsignedInt();
			var dataOffset:uint=section.readUnsignedInt();
			
			section.position=dataOffset;
			
			var index:uint;
			var tile:Tile;
			
			if(tileType==0) {
				
				tiles=new Vector.<Tile>();
				while(section.position<dataSize+dataOffset) {
					
					tile=new Tile();
					tile.readTile(bitDepth,section);
					
					tiles[index++]=tile;
				}
			} else if(tileType==1) {
				picture=new Vector.<uint>();
				picture.length=dataSize*8/bitDepth;
				picture.fixed=true;
				index=0;
				while(section.position<dataSize+dataOffset) {
					var byte=section.readUnsignedByte();
					if(bitDepth==4) {
						picture[index++]=byte & 0xF;
						picture[index++]=byte >> 4;
					} else {
						picture[index++]=byte;
					}
				}
			}
			
		}
		
		public function renderTile(subTileIndex:uint,palette:Vector.<uint>,paletteIndex:uint=0,useTransparency:Boolean=true) {
			if(tiles) {
				var tile:Tile=tiles[subTileIndex];
				var tileR:DisplayObject=new Bitmap(tile.toBMD(palette,paletteIndex,useTransparency));
				return tileR;
			} else {
				throw new Error();
			}
		}
		
		public function render(palette:Vector.<uint>,paletteIndex:uint=0,useTransparency:Boolean=true):Sprite {
			
			if(tiles) {
			
				var spr:Sprite=new Sprite();
				for(var y:uint=0;y<tilesY;++y) {
					for(var x:uint=0;x<tilesX;++x) {
						var index:uint=x+y*tilesX;
						var tile:Tile=tiles[index];
						
						var bmd:BitmapData=tile.toBMD(palette,paletteIndex,useTransparency);
						var bitmap:Bitmap=new Bitmap(bmd);
						bitmap.x=x*Tile.width;
						bitmap.y=y*Tile.height;
						
						spr.addChild(bitmap);
					}
				}
				return spr;
			} else {
				throw Error("unimplemented");
			}
		}

	}
	
}
