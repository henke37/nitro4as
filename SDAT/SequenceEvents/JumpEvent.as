package SDAT.SequenceEvents {
	
	public class JumpEvent extends SequenceEvent {
		
		public var target:uint;

		public function JumpEvent(_target:uint) {
			target=_target;
		}

	}
	
}
