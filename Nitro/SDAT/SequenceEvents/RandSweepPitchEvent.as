package Nitro.SDAT.SequenceEvents {
	
	public class RandSweepPitchEvent extends SequenceEvent {
		
		public var minAmmount:uint;
		public var maxAmmount:uint;

		public function RandSweepPitchEvent(_minAmmount:uint,_maxAmmount:uint) {
			minAmmount=_minAmmount;
			maxAmmount=_maxAmmount;
		}

	}
	
}
