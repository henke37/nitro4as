package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	public class NSBTX {

		public function NSBTX() {
		}
		
		public function parse(data:ByteArray) {
			var sections:SectionedFile3D=new SectionedFile3D();
			sections.parse(data);
			
			if(sections.id!="BTX0") throw new ArgumentError("File type must be BTX0, was \""+sections.id+"\"!");
			
			parseTex(sections.open("TEX0"));
		}
		
		private function parseTex(section:ByteArray):void {
			
		}

	}
	
}
