package Nitro.Graphics {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	/** NCGR File reader and writer
	
	<p>NCGR files contain pixel data for tiles</p>*/
	
	public class NCGR extends GraphicsBank {
		
		public var gridX:uint;
		public var gridY:uint;

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
			
			if(tileType==0) {
				parseTiled(section,dataOffset,dataSize);
			} else if(tileType==1) {
				parseScaned(section,dataOffset,dataSize);
			} else {
				throw new Error("Unsupported tileType encounterd!");
			}
			
		}
		
		/** Writes the contents of the file to a new ByteArray
		@return A new ByteArray*/
		public function save():ByteArray {
			
			var sectionList:Object={ RAHC: writeRAHC() };
			
			return SectionedFile.build("RGCN",sectionList);
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
				writeTiles(o);
			} else {
				throw new Error("Not implemented for non tiled graphics!");
			}
			
			return o;
		}

	}
	
}
