﻿package Nitro.Graphics {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	public class NCLR {
		
		public var colors:Vector.<uint>;
		
		public var paletteCount:uint;
		
		public var bitDepth:uint;

		public function NCLR() {
		}
		
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RLCN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			
			var section:ByteArray=sections.open("TTLP");
			parseTTLP(section);
			
			if(sections.hasSection("PMCP")) {
				section=sections.open("PMCP");
				parsePCMP(section);
			}
		}
		
		private function parseTTLP(section:ByteArray):void {
			section.endian=Endian.LITTLE_ENDIAN;
			
			bitDepth=1 << (section.readUnsignedShort()-1);
			
			section.position=0x08;
			var paletteSize:uint=section.readUnsignedInt();
			
			paletteSize/=RGB555.byteSize;
			
			var paletteOffset:uint=section.readUnsignedInt();
			
			section.position=paletteOffset;
			
			colors=new Vector.<uint>();
			colors.length=paletteSize;
			
			for(var i:uint=0;i<paletteSize;++i) {
				colors[i]=section.readUnsignedShort();
			}
			
		}
		
		private function parsePCMP(section:ByteArray):void {
			section.endian=Endian.LITTLE_ENDIAN;
			paletteCount=section.readUnsignedShort();
		}
		
		public function save():ByteArray {
			var sections:SectionedFile=new SectionedFile();
			
			var sectionList:Object={ TTLP:writeTTLP() };
			
			sections.build("RLCN",sectionList);
			return sections.data;
		}
		
		private function writeTTLP():ByteArray {
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			o.writeShort(bitDepth==4?3:4);
			o.writeShort(0);//unknown
			o.writeUnsignedInt(0);//more unknown
			o.writeUnsignedInt(colors.length*RGB555.byteSize);
			o.writeUnsignedInt(o.position+4);
			
			for each(var color:uint in colors) {
				o.writeShort(color);
			}
			
			return o;
		}

	}
	
}
