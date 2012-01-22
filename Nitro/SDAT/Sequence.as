package Nitro.SDAT {
	import Nitro.SDAT.SequenceEvents.SequenceEvent;
	
	public class Sequence {
		
		/** The events in the sequence */
		public var events:Vector.<SequenceEvent>;
		
		/** The starting offsets of the tracks in the sequence. */
		public var trackStarts:Vector.<uint>;

		public function Sequence() {
			events=new Vector.<SequenceEvent>();
			
			trackStarts=new Vector.<uint>();
		}

	}
	
}
