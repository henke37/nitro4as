package Nitro.SDAT.SequenceEvents {
	
	public class VarPortamentoTimeEvent extends SequenceEvent {
		
		public var timeVar:uint;

		public function VarPortamentoTimeEvent(_timeVar:uint) {
			timeVar=_timeVar;
		}
		
		public function toString():String {
			return "[PortamentoTime time=var("+timeVar+")]";
		}

	}
	
}
