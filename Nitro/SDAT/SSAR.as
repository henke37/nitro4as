package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SectionedFile;
	
	public class SSAR extends SubFile {
		
		private var sdat:ByteArray;
		
		sequenceInternal var offset:uint;

		public function SSAR() {
			
		}
		
		public override function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="SSAR") {
				throw new ArgumentError("Invalid SSAR block, wrong type id");
			}
			
			readDATA(sections.open("DATA"));
		}
		
		private function readDATA(section:ByteArray):void {
			
		}

	}
	
}
