package Nitro.SDAT.SequenceEvents {
	
	public class PortamentoTimeEvent extends SequenceEvent {
		
		public var time:uint;

		public function PortamentoTimeEvent(_time:uint) {
			time=_time;
		}
		
		public function toString():String {
			return "[PortamentoTime time="+time+"]";
		}

	}
	
}
