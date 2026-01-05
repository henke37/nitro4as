package Nitro.SDAT.SequenceEvents {
	
	public class VarLoopStartEvent extends SequenceEvent {
		
		public var countVar:uint;

		public function VarLoopStartEvent(_countVar:uint) {
			countVar=_countVar;
		}

	}
	
}
