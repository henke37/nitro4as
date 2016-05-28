package Nitro.SDAT {
	import Nitro.SDAT.SequenceEvents.SequenceEvent;
	
	public class Sequence {
		
		/** The events in the sequence */
		public var events:Vector.<SequenceEvent>;

		public function Sequence() {
			events=new Vector.<SequenceEvent>();
		}

	}
	
}
