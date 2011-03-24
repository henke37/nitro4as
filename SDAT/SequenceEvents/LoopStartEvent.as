package SDAT.SequenceEvents {
	
	public class LoopStartEvent extends SequenceEvent {
		
		public var count:uint;

		public function LoopStartEvent(_count:uint) {
			count=_count;
		}

	}
	
}
