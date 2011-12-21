package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	import Nitro.*;
	
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
		
		/** Parses just a TEX0 section */
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
			
			
			function textureInfoReader(data:ByteArray):* {				
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
			
			
			const textureInfos:Vector.<InfoData>=readInfo(section,textureInfoOffset, textureInfoReader);
			
			for(i=0;i<textureInfos.length;++i) {
				info=textureInfos[i];
				
				trace(info.name,info.infoData.width,info.infoData.height,TextureEntry.textypeToString(info.infoData.format),uint(info.infoData.offset).toString(16));
			}
			
			
			function paletteInfoReader(data:ByteArray):Object {				
				var paletteDataOffset:uint=paletteDataBaseOffset;
				paletteDataOffset+=data.readUnsignedShort()<<3;
				
				var unknown:uint=data.readUnsignedShort();
				
				return { offset: paletteDataOffset, unknown: unknown };
			}
			
			
			//var infoData:ByteArray=new ByteArray();
			//section.readBytes(infoData,0);
			const paletteInfos:Vector.<InfoData>=readInfo(section,paletteInfoOffset,paletteInfoReader);
			
			palettes=new Vector.<PaletteEntry>();
			palettes.length=paletteInfos.length;
			palettes.fixed=true;
			
			for (i=0;i<paletteInfos.length;++i) {
				info = paletteInfos[i];
				
				var entry:PaletteEntry=new PaletteEntry();
				entry.name=info.name;
				
				trace(entry.name,uint(info.infoData.offset).toString(16),info.infoData.unknown);
				
				palettes[i]=entry;
			}
			
		}
		
		

	}
	
}
