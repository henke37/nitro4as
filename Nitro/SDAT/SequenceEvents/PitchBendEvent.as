package SDAT.SequenceEvents {
	
	public class PitchBendEvent extends SequenceEvent {
		
		public var bend:uint;
		public var range:Boolean;

		public function PitchBendEvent(_bend:uint,_range:Boolean) {
			bend=_bend;
			range=_range;
		}

	}
	
}
