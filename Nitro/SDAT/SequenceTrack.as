package Nitro.SDAT {
	
	use namespace sequenceInternal;
	
	import Nitro.SDAT.SequenceEvents.*;
	
	public class SequenceTrack {
		
		sequenceInternal var events:Vector.<SequenceEvent>;

		public function SequenceTrack() {
			events=new Vector.<SequenceEvent>();
		}

	}
	
}
