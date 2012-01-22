package Nitro.SDAT.SequenceEvents {
	
	public class MonoPolyEvent extends SequenceEvent {

		public var mono:Boolean;

		public function MonoPolyEvent(_mono:Boolean) {
			mono=_mono;
		}
		
		public function toString():String {
			return "[MonoPolyEvent mono="+(mono?"true":"false")+"]";
		}

	}
	
}
