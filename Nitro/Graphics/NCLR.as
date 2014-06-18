package Nitro.Graphics {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	/** NCLR file parser and writer
	
	<p>NCLR files contain palette data</p>*/
	
	public class NCLR {
		
		/** The palette data, in RGB 555 format. */
		public var colors:Vector.<uint>;
		
		/** If the extended palette memory should be used for this palette */
		public var useExtPal:Boolean;
		
		/** The intended length of a pixel for usage with this palette. */
		public var bitDepth:uint;
		
		

		public function NCLR() {
		}
		
		/** Loads a file
		@param data The file to load*/
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
						
			var section:ByteArray;
			if(sections.id=="RLCN") {
				section=sections.open("TTLP");
			} else if(sections.id=="NCCL") {
				section=sections.open("PALT");
			} else {
				throw new ArgumentError("Incorrect file header, type is "+sections.id);
			}
			
			parseTTLP(section);
			
			if(sections.hasSection("PMCP")) {
				section=sections.open("PMCP");
				parsePCMP(section);
			}
		}
		
		private function parseTTLP(section:ByteArray):void {
			section.endian=Endian.LITTLE_ENDIAN;
			
			bitDepth=1 << (section.readUnsignedShort()-1);
			section.position+=2;
			useExtPal=Boolean(section.readUnsignedInt());
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
			const compressedPaletteCount:uint=section.readUnsignedShort();
			section.position+=2;//padding;
			const tbltPtr=section.readUnsignedInt();
		}
		
		/** Writes the palette data of the file to a new ByteArray
		@return The new ByteArray*/
		public function save():ByteArray {
			
			var sectionList:Object={ TTLP:writeTTLP() };
			
			return SectionedFile.build("RLCN",sectionList);
		}
		
		private function writeTTLP():ByteArray {
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			o.writeUnsignedInt(bitDepth==4?3:4);
			o.writeUnsignedInt(useExtPal?1:0);//more unknown
			o.writeUnsignedInt(colors.length*RGB555.byteSize);
			o.writeUnsignedInt(o.position+4);
			
			for each(var color:uint in colors) {
				o.writeShort(color);
			}
			
			return o;
		}

	}
	
}
