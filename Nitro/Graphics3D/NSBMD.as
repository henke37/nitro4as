package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	/** Parser for NSBMD files */
	public class NSBMD {
		
		private var internalTexture:NSBTX;

		public function NSBMD() {
		}
		
		public function parse(data:ByteArray):void {
			var sections:SectionedFile3D=new SectionedFile3D();
			sections.parse(data);
			
			if(sections.id!="BMD0") throw new ArgumentError("File type must be BMD0, was \""+sections.id+"\"!");
			
			if(sections.hasSection("TEX0")) {
				internalTexture=new NSBTX();
				internalTexture.parseTex(sections.open("TEX0"));
			}
			
			parseMdl(sections.open("MDL0"));
		}
		
		private function parseMdl(section:ByteArray):void {
			section.endian=Endian.LITTLE_ENDIAN;
			
			var modelInfos:Vector.<InfoData>=readInfo(section,8,modelInfoReader);
			
			for each(var info:InfoData in modelInfos) {
				trace(info.name);
				
				var modelOffset:uint=info.infoData.offset;
				
				section.position=modelOffset;
				
				var blockSize:uint=section.readUnsignedInt();
				var bonesOffset:uint=section.readUnsignedInt();
				var materialsOffset:uint=section.readUnsignedInt();
				var polygonStartOffset:uint=section.readUnsignedInt();
				var polygonEndOffset:uint=section.readUnsignedInt();
				
				section.position+=3;
				
				var objCount:uint=section.readUnsignedByte();
				var materialCount:uint=section.readUnsignedByte();
				var polygonCount:uint=section.readUnsignedByte();
				
				section.position+=1;
				
				var scaleMode:uint=section.readUnsignedByte();
				
				section.position+=2;
				
				var verticeCount:uint=section.readUnsignedShort();
				var surfaceCount:uint=section.readUnsignedShort();
				var triangleCount:uint=section.readUnsignedShort();
				var quadCount:uint=section.readUnsignedShort();
			}
		}
		
		private static function modelInfoReader(data:ByteArray):Object {
			return { offset: data.readUnsignedInt() };
		}

	}
	
}
