package Nitro.SDAT {
	import flash.utils.*;
	
	public class PulseInstrument extends LeafInstrumentBase {
		
		public var duty:uint;

		public function PulseInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray):void {
			
			duty=section.readUnsignedShort();
			if(duty>=8) {
				throw new RangeError("The duty cycle has to be less than 8!");
			}
			
			section.position+=2;			
			
			super.parse(section);
		}
		
		public override function toXML():XML {
			var o:XML=super.toXML();
			o.@duty=duty;
			return o;
		}
		
		public function get dutyPercent():Number {
			return [
				12.5,
				25.0,
				37.5,
				50.0,
				62.5,
				75.0,
				87.5,
				0.0
			]
			[duty];
		}
		
		public override function get instrumentType():uint { return INSTRUMENT_TYPE_PULSE; }

	}
	
}
