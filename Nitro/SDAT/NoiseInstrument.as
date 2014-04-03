package Nitro.SDAT {
	import flash.utils.*;
	
	public class NoiseInstrument extends LeafInstrumentBase {

		public function NoiseInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray,offset:uint):void {
			section.position+=2*2;
			
			super.parse(section,offset);
		}

	}
	
}
