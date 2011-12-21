package Nitro.FileSystem {
	import flash.utils.*;
	
	import Nitro.*;
	
	/** Nintendo archive parser
	
	<p>Nintendo archives are pretty much an additional filesystem that has been packaged as a standard sectioned file.</p> */
	
	public class NARC {
		
		/** The contained filesystem */		
		public var fileSystem:FileSystem;

		public function NARC() {
		}
		
		/** Loads the archive from a ByteArray
		@param data The bytearray to load from */
		public function parse(data:ByteArray):void {
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			var fat:Section=sections.findSection("BTAF");
			var fnt:Section=sections.findSection("BTNF");
			var img:Section=sections.findSection("GMIF");
			
			fileSystem=new FileSystem();
			fileSystem.parse(
				data,
				fnt.offset+SectionedFile.sectionHeaderSize,
				fnt.size,
				fat.offset+SectionedFile.sectionHeaderSize+4,
				fat.size-SectionedFile.sectionHeaderSize,
				img.offset+SectionedFile.sectionHeaderSize
			);
		}

	}
	
}
