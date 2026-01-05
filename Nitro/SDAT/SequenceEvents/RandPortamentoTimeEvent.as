package Nitro.SDAT.SequenceEvents {
	
	public class RandPortamentoTimeEvent extends SequenceEvent {
		
		public var minTime:uint;
		public var maxTime:uint;

		public function RandPortamentoTimeEvent(_minTime:uint,_maxTime:uint) {
			minTime=_minTime;
			maxTime=_maxTime;
		}
		
		public function toString():String {
			return "[PortamentoTime time="+minTime+"/"+maxTime+"]";
		}

	}
	
}
