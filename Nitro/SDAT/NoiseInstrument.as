﻿package Nitro.SDAT {
	import flash.utils.*;
	
	public class NoiseInstrument extends LeafInstrumentBase {

		public function NoiseInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray):void {
			section.position+=2*2;
			
			super.parse(section);
		}
		
		public override function get instrumentType():uint { return INSTRUMENT_TYPE_NOISE; }

	}
	
}
