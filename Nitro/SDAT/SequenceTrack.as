package Nitro.SDAT {
	
	use namespace sequenceInternal;
	
	import Nitro.SDAT.SequenceEvents.*;
	
	/** A track with sequence events */
	
	public class SequenceTrack {
		
		public var startPosition:uint;
		
		public function SequenceTrack(startPosition:uint) {
			this.startPosition=startPosition;
		}

	}
	
}
