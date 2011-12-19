package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	public class NSBCA {

		public function NSBCA() {
		}
		
		public function parse(data:ByteArray) {
			var sections:SectionedFile3D=new SectionedFile3D();
			sections.parse(data);
			
			if(sections.id!="BCA0") throw new ArgumentError("File type must be BCA0, was \""+sections.id+"\"!");
			
			parseJnt(sections.open("JNT0"));
		}
		
		private function parseJnt(section:ByteArray):void {
			
		}

	}
	
}
