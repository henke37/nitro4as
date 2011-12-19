package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	public class NSBMD {

		public function NSBMD() {
		}
		
		public function parse(data:ByteArray) {
			var sections:SectionedFile3D=new SectionedFile3D();
			sections.parse(data);
			
			if(sections.id!="BMD0") throw new ArgumentError("File type must be BMD0, was \""+sections.id+"\"!");
			
			parseMdl(sections.open("MDL0"));
		}
		
		private function parseMdl(section:ByteArray):void {
			
		}

	}
	
}
