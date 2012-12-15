package Nitro.Font {
	
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.SectionedFile;
	import Nitro.Section;
	
	
	public class NFTR {
		
		private static const PLGCHeaderLength:uint=12;
		
		
		internal var tileWidth:uint;
		internal var tileHeight:uint;
		internal var tileLength:uint;
		internal var tileDepth:uint;
		internal var tileRotationMode:uint;
		
		private var tiles:Vector.<FontTile>;

		public function NFTR() {
			// constructor code
		}
		
		public function parse(b:ByteArray):void {
			var sections:SectionedFile=new SectionedFile();
			sections.parse(b);
			
			if(sections.id!="RTFN") throw new ArgumentError("Wrong magic bytes!");
			
			for(var i:uint=0;i<sections.length;++i) {
				var section:Section=sections.getSectionAt(i);
				var sectionData:ByteArray=sections.openSection(section);
				sectionData.endian=Endian.LITTLE_ENDIAN;
				
				switch(section.id) {
					case "FNIF":
						parseFNIF(sectionData);
					break;
					
					case "PLGC":
						parsePLGC(sectionData);
					break;
					
					case "PAMC":
						parsePAMC(sectionData);
					break;
					
					case "HDWC":
						parseHDWC(sectionData);
					break;
					
					default:
						trace(section.id);
					break;
				}
			}
		}
		
		private function parseFNIF(d:ByteArray):void {
			d.readByte();
			var height:uint=d.readByte();
			d.readByte();
			d.readByte();
			d.readByte();
			var width:uint=d.readByte();
			var width_bis:uint=d.readByte();
			var encoding:uint=d.readByte();
			
			var offsetPLGC:uint=d.readUnsignedInt();
			var offsetPAMC:uint=d.readUnsignedInt();
			var offsetHDWC:uint=d.readUnsignedInt();
			
			trace("FNIF",height,width,width_bis,encoding);
		}
		
		private function parsePLGC(d:ByteArray):void {
			tileWidth=d.readUnsignedByte();
			tileHeight=d.readUnsignedByte();
			tileLength=d.readUnsignedShort();
			d.position+=2;
			tileDepth=d.readUnsignedByte();
			tileRotationMode=d.readUnsignedByte();
			
			var tileCount:uint=(d.length-PLGCHeaderLength)/tileLength;
			
			trace("PLGC",tileWidth,tileHeight,tileLength,tileDepth,tileRotationMode,tileCount);
			
			tiles=new Vector.<FontTile>(tileCount);
			
			for(var i:uint=0;i<tileCount;++i) {
				var tile:FontTile=new FontTile(this);
				
				var pixels:ByteArray=new ByteArray();
				d.readBytes(pixels,0,tileLength);
				tile.pixels=pixels;
				
				tiles[i]=tile;
			}
		}
		
		private function parsePAMC(d:ByteArray):void {
			var firstChar:uint=d.readUnsignedShort();
			var lastChar:uint=d.readUnsignedShort();
			var type:uint=d.readUnsignedInt();
			var nextPAMC:uint=d.readUnsignedInt();
			
			trace("PAMC",firstChar,lastChar,type,nextPAMC);
			
			var mapLen:uint;
			var charCode,char:uint;
			var i:uint;
			
			switch(type) {
				case 0://offseted linear map
					var offset:uint=d.readUnsignedShort();
				break;
				
				case 1: //linear scan map
					mapLen=(d.length-12)/2;
					trace(mapLen,lastChar-firstChar);
					for(i=0;i<mapLen;++i) {
						charCode=d.readUnsignedShort();
					}
					
				break;
				
				case 2: //paired map
					mapLen=d.readUnsignedShort();
					for(i=0;i<mapLen;++i) {
						charCode=d.readUnsignedShort();
						char=d.readUnsignedShort();
					}
				break;
			}
		}
		
		private function parseHDWC(d:ByteArray):void {
			var firstCode:uint=d.readUnsignedShort();
			var lastCode:uint=d.readUnsignedShort();
			var unknown:uint=d.readUnsignedInt();
			
			trace("HDWC",firstCode,lastCode,unknown);
			
			for(var i:uint=0;i<tiles.length;++i) {
				var tile:FontTile=tiles[i];
				tile.start=d.readUnsignedByte();
				tile.width=d.readUnsignedByte();
				tile.length=d.readUnsignedByte();
			}
		}
		
		public function get tileCount():uint { return tiles.length; }
		
		public function getTile(tileID:uint):FontTile {
			return tiles[tileID];
		}
		
		public function get tileRotation():Number { return [0,90,270,180][tileRotationMode]; }

	}
	
}
