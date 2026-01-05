package Nitro.SDAT.SequenceEvents {
	
	public class VarRestEvent extends SequenceEvent {

		public var restVar:uint;

		public function VarRestEvent(_restVar:uint) {
			restVar=_restVar;
		}
		
		public function toString():String {
			return "[RestEvent duration=var("+restVar+")]";
		}

	}
	
}
