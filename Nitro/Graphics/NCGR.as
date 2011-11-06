package Nitro.Graphics {
	
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	/** NCGR File reader and writer
	
	<p>NCGR files contain pixel data for tiles</p>*/
	
	public class NCGR {
		
		/** The tiles the picture is composed of, if any
		@see picture*/
		private var tiles:Vector.<Tile>;
		/** The pixels the picture is composed of, if any
		@see tiles*/
		private var picture:Vector.<uint>;
		
		/** The number of tiles along the x axis */
		public var tilesX:uint;
		/** The number of tiles along the y axis */
		public var tilesY:uint;
		
		public var gridX:uint;
		public var gridY:uint;
		
		/** The number of bits used to store each pixel.
		<p>Must be either 4 or 8.</p>*/
		public var bitDepth:uint;

		public function NCGR() {
		}
		
		/** Loads a NCGR file from a ByteArray
		@param data The ByteArray to load from
		*/
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RGCN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			var section:ByteArray=sections.open("RAHC");
			
			parseRAHC(section);
		}
		
		private function parseRAHC(section:ByteArray):void {
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			tilesY=section.readUnsignedShort();
			tilesX=section.readUnsignedShort();
			
			
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
					var byte:uint=section.readUnsignedByte();
					if(bitDepth==4) {
						picture[index++]=byte & 0xF;
						picture[index++]=byte >> 4;
					} else {
						picture[index++]=byte;
					}
				}
			} else {
				throw new Error("Unsupported tileType encounterd!");
			}
			
		}
		
		/** Writes the contents of the file to a new ByteArray
		@return A new ByteArray*/
		public function save():ByteArray {
			var sections:SectionedFile=new SectionedFile();
			
			var sectionList:Object={ RAHC: writeRAHC() };
			
			sections.build("RGCN",sectionList);
			
			return sections.data;
		}
		
		private function writeRAHC():ByteArray {
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			o.writeShort(tilesY);
			o.writeShort(tilesX);
			
			
			o.writeUnsignedInt(bitDepth==4?3:4);
			
			o.writeShort(gridX);
			o.writeShort(gridY);
			
			o.writeUnsignedInt(tiles?0:1);
			
			var dataSize:uint;
			if(tiles) {
				dataSize=tiles.length*Tile.height*Tile.width;
			} else {
				dataSize=picture.length;
			}
			if(bitDepth==4) dataSize>>>=1;
			
			o.writeUnsignedInt(dataSize);
			
			o.writeUnsignedInt(o.position+4);
			
			if(tiles) {
				for each(var tile:Tile in tiles) {
					tile.writeTile(bitDepth,o);
				}
			} else {
				throw new Error("Not implemented for non tiled graphics!");
			}
			
			return o;
		}
		
		/** Renders a specific tile to a BitmapData
		@param subTileIndex The number of the tile to render
		@param palette The palette to use when rendering the tile, in RGB888 format
		@param paletteIndex The subpalette index to use
		@param useTransparency If the tile should be rendered using transparency
		@return A BitmapData for the tile*/
		public function renderTile(subTileIndex:uint,palette:Vector.<uint>,paletteIndex:uint,useTransparency:Boolean):BitmapData {
			var tile:Tile=tiles[subTileIndex];
			return tile.toBMD(palette,paletteIndex,useTransparency);
		}
		
		/** Renders an oam entry
		@param oam The oam entry to render
		@param palette The palette to use when rendering, in RGB888 format
		@param subImages True if the tiles are aranged in a big grid or false if they are aranged in one grid per oam
		@param useTransparency If the tiles should be rendered using transparency
		@return A DisplayObject that represents the oam entry
		*/
		public function renderOam(oam:OamTile,palette:Vector.<uint>,subImages:Boolean,useTransparency:Boolean=true):DisplayObject {
			if(tiles) {
				return renderTileOam(oam,palette,subImages,useTransparency);
			} else {
				return renderPictureOam(oam,palette,useTransparency);
			}
		}
		
		private function renderPictureOam(oam:OamTile,palette:Vector.<uint>,useTransparency:Boolean): DisplayObject {
			var bmd:BitmapData=new BitmapData(oam.width,oam.height,useTransparency);
			bmd.lock();
			
			const offset:uint=oam.tileIndex*(bitDepth==4?64:32);
			
			for(var y:uint=0;y<oam.height;++y) {
				for(var x:uint=0;x<oam.width;++x) {
					var color:uint=picture[x+y*oam.width+offset];
					if(color==0 && useTransparency) {
						bmd.setPixel32(x,y,0x00FFF00F);
					} else {
						color=palette[color+oam.paletteIndex*16];
						bmd.setPixel(x,y,color);
					}
				}
			}
			bmd.unlock();
			return new Bitmap(bmd);
		}
		
		private function renderTileOam(oam:OamTile,palette:Vector.<uint>,subImages:Boolean,useTransparency:Boolean):DisplayObject {
			var spr:Sprite=new Sprite();
			
			var tileIndex:uint=(bitDepth==8)?oam.tileIndex>>1:oam.tileIndex;
			
			const baseX:uint=tileIndex%tilesX;
			const baseY:uint=tileIndex/tilesX;
			
			const yTiles:uint=oam.height/Tile.height;
			const xTiles:uint=oam.width/Tile.width;
			
			var subTileWidth:uint;
			if(tilesX==0xFFFF) {
				subTileWidth=xTiles;
			} else {
				subTileWidth=tilesX;
			}
			
			for(var y:uint=0;y<yTiles;++y) {
				for(var x:uint=0;x<xTiles;++x) {
					
					var subTileIndex:uint;
					
					if(subImages) {
						var subTileYIndex:uint=baseY+y;
						var subTileXIndex:uint=baseX+x;
						
						subTileIndex=subTileXIndex+subTileYIndex*subTileWidth;
					} else {
						subTileIndex=tileIndex+x+y*xTiles;
					}
					
					var tileR:DisplayObject=new Bitmap(renderTile(subTileIndex,palette,oam.paletteIndex,useTransparency));
					
					tileR.x=Tile.width*x;
					tileR.y=Tile.height*y;
					
					spr.addChild(tileR);
				}
			}
			
			return spr;
		}
		
		/** Converts an OAM to a single Vector with color indexes
		@param oam The OAM to convert
		@param subImages True if the tiles are aranged in a big grid or false if they are aranged in one grid per oam
		@return A new Vector with the color indexes
		*/
		public function oamToVector(oam:OamTile,subImages:Boolean):Vector.<uint> {
			if(tiles) {
				return tileOamToVector(oam,subImages);
			} else {
				return pictureOamToVector(oam);
			}
		}
			
		private function tileOamToVector(oam:OamTile,subImages:Boolean):Vector.<uint> {
			var o:Vector.<uint>=new Vector.<uint>();
			o.length=oam.height*oam.width;
			o.fixed=true;
			
			var tileIndex:uint=(bitDepth==8)?oam.tileIndex>>1:oam.tileIndex;
			
			const baseX:uint=tileIndex%tilesX;
			const baseY:uint=tileIndex/tilesX;
			
			const yTiles:uint=oam.height/Tile.height;
			const xTiles:uint=oam.width/Tile.width;
			
			var subTileWidth:uint;
			if(tilesX==0xFFFF) {
				subTileWidth=xTiles;
			} else {
				subTileWidth=tilesX;
			}
			
			for(var y:uint=0;y<yTiles;++y) {
				for(var x:uint=0;x<xTiles;++x) {
					
					var subTileIndex:uint;
					
					if(subImages) {
						var subTileYIndex:uint=baseY+y;
						var subTileXIndex:uint=baseX+x;
						
						subTileIndex=subTileXIndex+subTileYIndex*subTileWidth;
					} else {
						subTileIndex=tileIndex+x+y*xTiles;
					}
					
					var tile:Tile=tiles[subTileIndex];
					
					for(var tileY:uint=0;tileY<Tile.height;tileY++) {
						var totalY:uint=tileY+y*Tile.height;
						for(var tileX:uint=0;tileX<Tile.width;tileX++) {
							
							var totalX:uint=tileX+x*Tile.width;
							
							var index:uint=totalX+totalY*oam.width;
							o[index]=tile.pixels[tileX+tileY*Tile.height];
						}
					}
				}
				
			}
			
			return o;
		}
		
		private function pictureOamToVector(oam:OamTile):Vector.<uint> {
			const offset:uint=oam.tileIndex*(bitDepth==4?64:32);
			
			return picture.slice(offset,oam.height*oam.width);
		}
		
		/** Builds a complete collection of concatinated oams.
		
		
		
		@param useTiles If the data should be formated as a pixel stream or as tiled pixels
		@param oamPixels The pixel data for each tile
		@param oams The oams the pixel data belongs to
		
		<p>The oams will be edited to contain correct tile indexes.</p>
		
		@return A mapping from old indexes to new indexes
		*/
		public function build(useTiles:Boolean,oamPixels:Vector.<Vector.<uint>>,oams:Vector.<OamTile>):Object {
			
			if(useTiles) {
				return buildTiles(oamPixels,oams);
			} else {
				return buildPicture(oamPixels,oams);
			}
		}
		
		private function buildTiles(oamPixels:Vector.<Vector.<uint>>,oams:Vector.<OamTile>):Object {
			var t:Vector.<Tile>=new Vector.<Tile>;
			var map:Object={};
			
			for(var i:uint=0;i<oams.length;++i) {
				var oam:OamTile=oams[i];
				var tilePixels:Vector.<uint>=oamPixels[i];
				
				map[oam.tileIndex]=t.length;
				oam.tileIndex=t.length;
				
				for(var yPos:uint=0;yPos<oam.height;yPos+=Tile.height) {
					for(var xPos:uint=0;xPos<oam.width;xPos+=Tile.width) {
						var tile:Tile=new Tile();
						
						for(var tileYPos:uint=0;tileYPos<Tile.height;++tileYPos) {
							for(var tileXPos:uint=0;tileXPos<Tile.width;++tileXPos) {
								
								var tileOffset:uint=tileYPos*Tile.width+tileXPos;
								var pixelsOffset:uint=(yPos*Tile.height+tileYPos)*Tile.width+(xPos*Tile.width+tileXPos);
								
								tile.pixels[tileOffset]=tilePixels[pixelsOffset];
							}
						}
						
						t.push(tile);
					}
				}
			}
			tiles=t;
			picture=null;
			
			tilesX=0xFFFF;
			tilesY=0xFFFF;
			
			return map;
		}
		
		private function buildPicture(oamPixels:Vector.<Vector.<uint>>,oams:Vector.<OamTile>):Object {
			var pixels:Vector.<uint>=new Vector.<uint>;
			var map:Object={};
			
			for(var i:uint=0;i<oams.length;++i) {
				var oam:OamTile=oams[i];
				var tilePixels:Vector.<uint>=oamPixels[i];
				
				var tileIndex:uint=pixels.length/(Tile.width*Tile.height);
				pixels=pixels.concat(tilePixels);
				map[oam.tileIndex]=tileIndex;
				oam.tileIndex=tileIndex;
			}
			
			picture=pixels;
			tiles=null;
			
			tilesX=0xFFFF;
			tilesY=0xFFFF;
			
			return map;
		}
		
		/** Renders the full NCGR as one big picture
		@param palette The palette to use when rendering, in RGB888 format
		@param paletteIndex The subpalette index to use
		@param useTransparency If the tiles should be rendered using transparency
		*/
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
		
		/** If the NCGR file can be renderd without a NCER file */
		public function get independentRenderPossible():Boolean {
			return tiles && tilesX!=0xFFFF && tilesY!=0xFFFF;
		}
		
		internal function loadTiles(ts:Vector.<Tile>,tx:uint,ty:uint):void {
			tiles=ts;
			tilesX=tx;
			tilesY=ty;
		}

	}
	
}
