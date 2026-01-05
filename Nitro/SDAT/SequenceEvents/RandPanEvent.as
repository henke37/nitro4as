package Nitro.SDAT.SequenceEvents {
	
	public class RandPanEvent extends SequenceEvent {

		public var minPan:uint
		public var maxPan:uint

		public function RandPanEvent(_minPan:uint,_maxPan:uint) {
			minPan=_minPan;
			maxPan=_maxPan;
		}
		
		public function toString():String {
			return "[PanEvent pan="+minPan+"/"+maxPan+"]";
		}

	}
	
}
