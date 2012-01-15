package Nitro.SDAT {
	
	use namespace sequenceInternal;
	
	import Nitro.SDAT.SequenceEvents.*;
	
	/** A track with sequence events */
	
	public class SequenceTrack {
		
		sequenceInternal var events:Vector.<SequenceEvent>;
		sequenceInternal var offsets:Object;

		public function SequenceTrack() {
			events=new Vector.<SequenceEvent>();
			offsets={};
		}

	}
	
}
