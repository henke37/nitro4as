package SDAT {
	
	use namespace sequenceInternal;
	
	import SDAT.SequenceEvents.*;
	
	public class SequenceTrack {
		
		sequenceInternal var events:Vector.<SequenceEvent>;

		public function SequenceTrack() {
			events=new Vector.<SequenceEvent>();
		}

	}
	
}
