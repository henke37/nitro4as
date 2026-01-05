package Nitro.SDAT.SequenceEvents {
	
	public class RandTransposeEvent extends SequenceEvent {

		public var minTranspose:uint;
		public var maxTranspose:uint;

		public function RandTransposeEvent(_minTranspose:uint,_maxTranspose:uint) {
			minTranspose=_minTranspose;
			maxTranspose=_maxTranspose;
		}

	}
	
}
