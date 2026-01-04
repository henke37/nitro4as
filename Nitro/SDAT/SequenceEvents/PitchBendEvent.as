package Nitro.SDAT.SequenceEvents {
	
	public class PitchBendEvent extends SequenceEvent {
		
		public var bend:int;
		public var range:Boolean;

		public function PitchBendEvent(_bend:int,_range:Boolean) {
			bend=_bend;
			range=_range;
		}

	}
	
}
