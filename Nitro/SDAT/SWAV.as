package Nitro.SDAT {
	
	import flash.utils.*;
	
	//use namespace strmInternal;
	
	import Nitro.*;
	
	/** Reader for SWAV files */
	
	public class SWAV extends SubFile {
		
		public var wave:Wave;

		public function SWAV() {
			
		}
		
		public override function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);

			if(sections.id!="SWAV") {
				throw new ArgumentError("Invalid SWAV block, wrong type id");
			}
			
			var section:ByteArray=sections.open("DATA");
			
			wave=new Wave();
			wave.parse(0,section);
			
		}

	}
	
}
