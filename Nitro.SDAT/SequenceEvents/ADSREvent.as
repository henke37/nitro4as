package SDAT.SequenceEvents {
	
	public class ADSREvent extends SequenceEvent {

		public var type:String;
		public var value:uint;

		public function ADSREvent(_type:String,_value:uint) {
			type=_type;
			value=_value;
		}

	}
	
}
