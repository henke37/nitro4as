package Nitro.FileSystem {
	import flash.utils.*;
	
	import Nitro.*;
	
	public class NARC {
		
		public var fileSystem:FileSystem;

		public function NARC() {
		}
		
		public function parse(data:ByteArray):void {
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			var fat:Object=sections.findSection("BTAF");
			var fnt:Object=sections.findSection("BTNF");
			var img:Object=sections.findSection("GMIF");
			
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
