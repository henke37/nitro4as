package Nitro.Graphics {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	public class NCLR {
		
		public var colors:Vector.<uint>;
		
		public var bitDepth:uint;

		public function NCLR() {
		}
		
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RLCN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			
			var section:ByteArray=sections.open("TTLP");
			section.endian=Endian.LITTLE_ENDIAN;
			
			bitDepth=1 << (section.readUnsignedShort()-1);
			
			section.position=0x0C;
			var paletteSize:uint=section.readUnsignedInt();
			
			if(bitDepth==4) {
				paletteSize=256;
			}
			
			colors=new Vector.<uint>();
			colors.length=paletteSize;
			
			for(var i:uint=0;i<paletteSize;++i) {
				colors[i]=RGB555.read555Color(section);
			}
		}

	}
	
}
