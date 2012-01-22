package Nitro.SDAT.SequenceEvents {
	
	public class RestEvent extends SequenceEvent {

		public var rest:uint;

		public function RestEvent(_rest:uint) {
			rest=_rest;
		}
		
		public function toString():String {
			return "[RestEvent duration="+rest+"]";
		}

	}
	
}
