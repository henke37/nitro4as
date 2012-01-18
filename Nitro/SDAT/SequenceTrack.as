package Nitro.SDAT {
	
	use namespace sequenceInternal;
	
	import Nitro.SDAT.SequenceEvents.*;
	
	/** A track with sequence events */
	
	public class SequenceTrack {
		
		public var events:Vector.<SequenceEvent>;
		public var offsets:Object;

		public function SequenceTrack() {
			events=new Vector.<SequenceEvent>();
			offsets={};
		}

	}
	
}
