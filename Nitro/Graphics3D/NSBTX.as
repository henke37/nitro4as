package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	import Nitro.*;
	import Nitro.Graphics.*;
	
	/**
	Parser for NSBTX files.
	
	<p>NSBTX files contains a set of textures.</p>*/
	
	public class NSBTX {

		private var palettes:Vector.<PaletteEntry>;
		private var textures:Vector.<TextureEntry>;

		public function NSBTX() {
		}
		
		/** Parses a NSBTX file from a ByteArray
		@param data The ByteArray to parse from
		*/
		public function parse(data:ByteArray):void {
			var sections:SectionedFile3D=new SectionedFile3D();
			sections.parse(data);
			
			if(sections.id!="BTX0") throw new ArgumentError("File type must be BTX0, was \""+sections.id+"\"!");
			
			parseTex(sections.open("TEX0"));
		}
		
		/** Parses just a TEX0 section
		@param section The section data*/
		internal function parseTex(section:ByteArray):void {
			var i:uint;
			var info:InfoData;
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			section.position=12;
			var textureDataSize:uint=section.readUnsignedShort();
			var textureInfoOffset:uint=section.readUnsignedShort();
			
			section.position=20;
			var textureDataBaseOffset:uint=section.readUnsignedInt();
			
			section.position=28;
			var compressedTextureDataSize:uint=section.readUnsignedShort();
			var compressedTextureInfoOffset:uint=section.readUnsignedShort();
			
			section.position=36;
			var compressedTextureDataBaseOffset:uint=section.readUnsignedInt();
			var compressedTextureDataExOffset:uint=section.readUnsignedInt();
			
			section.position=48;
			var paletteDataSize:uint=section.readUnsignedInt();
			var paletteInfoOffset:uint=section.readUnsignedInt();
			var paletteDataBaseOffset:uint=section.readUnsignedInt();
			
			//some fields are stored shifted
			textureDataSize<<=3;
			compressedTextureDataSize<<=3;
			paletteDataSize<<=3;
			
			
			
			
			const textureInfos:Vector.<InfoData>=readInfo(section,textureInfoOffset, textureInfoReader);
			
			for(i=0;i<textureInfos.length;++i) {
				info=textureInfos[i];
				
				trace(info.name,info.infoData.width,info.infoData.height,TextureEntry.textypeToString(info.infoData.format),uint(info.infoData.offset).toString(16));
			}
			
			
			
			
			
			//var infoData:ByteArray=new ByteArray();
			//section.readBytes(infoData,0);
			const paletteInfos:Vector.<InfoData>=readInfo(section,paletteInfoOffset,paletteInfoReader);
			
			paletteInfos.sort(sortPalettesInReverse);
			
			palettes=new Vector.<PaletteEntry>();
			palettes.length=paletteInfos.length;
			palettes.fixed=true;
			
			var lastPaletteOffset:uint=paletteDataSize;
			
			for (i=0;i<paletteInfos.length;++i) {
				info = paletteInfos[i];
				var offset:uint=info.infoData.offset;
				
				var entry:PaletteEntry=new PaletteEntry();
				entry.name=info.name;
				
				var colorCount:uint=(lastPaletteOffset-offset)/RGB555.byteSize;
				
				if(colorCount>256) throw new Error("colorCount is ludicrous!");
				
				trace(entry.name,offset.toString(16),info.infoData.unknown, colorCount);
				
				var colors:Vector.<uint>=new Vector.<uint>();
				colors.length=colorCount;
				colors.fixed=true;
				
				section.position=offset+paletteDataBaseOffset;
				for(var j:uint=0;j<colorCount;++j) {
					colors[j]=section.readUnsignedShort();
				}
				
				entry.unconvertedColors=colors;
				
				palettes[i]=entry;
				lastPaletteOffset=offset;
			}
			
		}
		
		private function textureInfoReader(data:ByteArray):* {				
			var o:Object ={};
			o.offset=data.readUnsignedShort()<<3;
			var params:uint=data.readUnsignedShort();
			o.width = 8 << (params >> 4 & 0x7);
			o.height = 8 << (params >> 7 & 0x7);
			o.format = params >> 10 & 0x7;
			o.palette = params >> 13 & 0x7;
			o.flipX = Boolean(params >> 2 & 1);
			o.flipY = Boolean(params >> 3 & 1);
			o.repeatX = Boolean(params & 1);
			o.repeatY = Boolean(params >> 1 & 1);
			o.transparent = Boolean(params >> 13 & 1);
			
			return o;
		}
		
		private function paletteInfoReader(data:ByteArray):Object {				
			return {
				offset: data.readUnsignedShort()<<3,
				unknown: data.readUnsignedShort()
			};
		}
		
		/** Retrives a palette entry based on its name
		@param name The name of the palette entry
		@return The retrived palette entry
		@throws ArgumentError There is no entry with that name */
		public function getPaletteByName(name:String):PaletteEntry {
			for each(var entry:PaletteEntry in palettes) {
				if(entry.name==name) {
					return entry;
				}
			}
			throw new ArgumentError("No palette with that name");
		}
		
		private static function sortPalettesInReverse(a:InfoData,b:InfoData):int {
			return b.infoData.offset-a.infoData.offset;
		}
		

	}
	
}
