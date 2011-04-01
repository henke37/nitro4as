package Nitro.SDAT.SequenceEvents {
	
	public class JumpEvent extends SequenceEvent {
		
		public var target:uint;
		public var isCall:Boolean;

		public function JumpEvent(_target:uint,_isCall:Boolean) {
			target=_target;
			isCall=_isCall;
		}

	}
	
}
