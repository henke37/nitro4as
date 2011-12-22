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
			
			
			
			//Parse the palettes first
			const paletteInfos:Vector.<InfoData>=readInfo(section,paletteInfoOffset,paletteInfoReader);
			
			paletteInfos.sort(sortEntriesInReverse);
			
			palettes=new Vector.<PaletteEntry>();
			palettes.length=paletteInfos.length;
			palettes.fixed=true;
			
			var lastPaletteOffset:uint=paletteDataSize;
			
			for (i=0;i<paletteInfos.length;++i) {
				info = paletteInfos[i];
				var offset:uint=info.infoData.offset;
				
				var palette:PaletteEntry=new PaletteEntry();
				palette.name=info.name;
				
				var colorCount:uint=(lastPaletteOffset-offset)/RGB555.byteSize;
				
				if(colorCount>256) throw new Error("colorCount is ludicrous!");
				
				trace(palette.name,offset.toString(16),info.infoData.unknown, colorCount);
				
				var colors:Vector.<uint>=new Vector.<uint>();
				colors.length=colorCount;
				colors.fixed=true;
				
				section.position=offset+paletteDataBaseOffset;
				for(var j:uint=0;j<colorCount;++j) {
					colors[j]=section.readUnsignedShort();
				}
				
				palette.unconvertedColors=colors;
				
				palettes[paletteInfos.length-i-1]=palette;
				lastPaletteOffset=offset;
			}
			
			
			
			//Parse the textures later
			const textureInfos:Vector.<InfoData>=readInfo(section,textureInfoOffset, textureInfoReader);
			textures=new Vector.<TextureEntry>();
			textures.length=textureInfos.length;
			textures.fixed=true;
			
			for(i=0;i<textureInfos.length;++i) {
				info=textureInfos[i];
				
				var texture:TextureEntry=new TextureEntry();
				
				texture.name=info.name;
				texture.width=info.infoData.width;
				texture.height=info.infoData.height;
				texture.format=info.infoData.format;
				texture.palette=palettes[info.infoData.palette];
				texture.transparentZero=info.infoData.transparent;
				texture.flipX=info.infoData.flipX;
				texture.flipY=info.infoData.flipY;
				texture.repeatX=info.infoData.repeatX;
				texture.repeatY=info.infoData.repeatY;
				
				var pixelData:ByteArray=new ByteArray();
				
				var baseOffset:uint=(info.infoData.format==5?compressedTextureDataBaseOffset:textureDataBaseOffset);
				var readSize:uint=texture.width*texture.height*texture.bpp/8;
				
				section.position=info.infoData.offset+baseOffset;
				section.readBytes(pixelData,0,readSize);
				
				texture.pixelData=pixelData;
				
				trace(info.name,info.infoData.width,info.infoData.height,TextureEntry.textypeToString(info.infoData.format),uint(info.infoData.offset).toString(16));
				
				
				textures[i]=texture;
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
			for each(var palette:PaletteEntry in palettes) {
				if(palette.name==name) {
					return palette;
				}
			}
			throw new ArgumentError("No palette with that name");
		}
		
		/** Retrives a texture based on its name
		@param name The name of the texture
		@return The retrived texture
		@throws ArgumentError There is no entry with that name */
		public function getTextureByName(name:String):TextureEntry {
			for each(var texture:TextureEntry in textures) {
				if(texture.name==name) {
					return texture;
				}
			}
			throw new ArgumentError("No texture with that name");
		}
		
		private static function sortEntriesInReverse(a:InfoData,b:InfoData):int {
			return b.infoData.offset-a.infoData.offset;
		}
		

	}
	
}
