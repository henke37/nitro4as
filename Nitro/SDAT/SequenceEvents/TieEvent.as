package Nitro.SDAT.SequenceEvents {
	
	public class TieEvent extends SequenceEvent {

		public var tie:Boolean;

		public function TieEvent(_tie:Boolean) {
			tie=_tie;
		}
		
		public function toString():String {
			return "[TieEvent tie="+(tie?"true":"false")+"]";
		}

	}
	
}
