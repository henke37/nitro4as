package Nitro.SDAT {
	import flash.utils.*;
	
	public class PulseInstrument extends LeafInstrumentBase {
		
		public var duty:uint;

		public function PulseInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray,offset:uint):void {
			duty=section.readUnsignedShort();
			section.position+=2;
			
			super.parse(section,offset);
		}

	}
	
}
