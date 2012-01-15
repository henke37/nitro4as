package Nitro.SDAT.SequenceEvents {
	
	public class ADSREvent extends SequenceEvent {

		/** The part of the envelope being set.
		
		<p>A for attack, D for decay, S for sustain and R for release</p> */
		public var type:String;
		public var value:uint;

		public function ADSREvent(_type:String,_value:uint) {
			type=_type;
			value=_value;
		}

	}
	
}
