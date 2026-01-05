package Nitro.SDAT.SequenceEvents {
	
	public class VarADSREvent extends SequenceEvent {

		/** The part of the envelope being set.
		
		<p>A for attack, D for decay, S for sustain and R for release</p> */
		public var type:String;
		public var valueVar:uint;

		public function VarADSREvent(_type:String,_valueVar:uint) {
			type=_type;
			valueVar=_valueVar;
		}
		
		public function toString():String {
			return "[ADSREvent type="+type+" value=var("+valueVar+")]";
		}

	}
	
}
