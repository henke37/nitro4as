package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	import Nitro.*;
	
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
			
		}

	}
	
}
