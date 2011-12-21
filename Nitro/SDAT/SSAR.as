package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SectionedFile;
	
	/** SSAR reader
	
	<p>SSAR files contains a set of sequences</p>*/
	
	public class SSAR extends SubFile {
		
		sequenceInternal var offset:uint;

		public function SSAR() {
			
		}
		
		/** Loads data from a ByteArray
		@param data The ByteArray to load from*/
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
