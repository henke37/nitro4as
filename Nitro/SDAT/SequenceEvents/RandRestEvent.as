package Nitro.SDAT.SequenceEvents {
	
	public class RandRestEvent extends SequenceEvent {

		public var minRest:uint;
		public var maxRest:uint;

		public function RandRestEvent(_minRest:uint,_maxRest:uint) {
			minRest=_minRest;
			maxRest=_maxRest;
		}
		
		public function toString():String {
			return "[RestEvent duration="+minRest+"/"+maxRest+"]";
		}

	}
	
}
