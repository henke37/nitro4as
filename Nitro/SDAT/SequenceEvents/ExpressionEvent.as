package Nitro.SDAT.SequenceEvents {
	
	public class ExpressionEvent extends SequenceEvent {
		
		public var value:uint;

		public function ExpressionEvent(_value:uint) {
			value=_value;
		}
		
		public function toString():String {
			return "[ExpressionEvent val="+value+"]";
		}

	}
	
}
