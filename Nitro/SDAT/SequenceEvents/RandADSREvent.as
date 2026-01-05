package Nitro.SDAT.SequenceEvents {
	
	public class RandADSREvent extends SequenceEvent {

		/** The part of the envelope being set.
		
		<p>A for attack, D for decay, S for sustain and R for release</p> */
		public var type:String;
		public var minValue:uint;
		public var maxValue:uint;

		public function RandADSREvent(_type:String,_minValue:uint,_maxValue:uint) {
			type=_type;
			minValue=_minValue;
			maxValue=_maxValue;
		}
		
		public function toString():String {
			return "[ADSREvent type="+type+" value="+minValue+"/"+maxValue+"]";
		}

	}
	
}
