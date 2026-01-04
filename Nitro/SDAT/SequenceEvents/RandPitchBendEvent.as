package Nitro.SDAT.SequenceEvents {
	
	public class RandPitchBendEvent extends SequenceEvent {
		
		public var minBend:int;
		public var maxBend:int;
		public var range:Boolean;

		public function RandPitchBendEvent(_minBend:int,_maxBend:int,_range:Boolean) {
			minBend=_minBend;
			maxBend=_maxBend;
			range=_range;
		}

	}
	
}
