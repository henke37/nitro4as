package Nitro.SDAT.SequenceEvents {
	
	public class VarPanEvent extends SequenceEvent {

		public var panVar:uint

		public function VarPanEvent(_panVar:uint) {
			panVar=_panVar;
		}
		
		public function toString():String {
			return "[PanEvent pan=var("+panVar+")]";
		}

	}
	
}
