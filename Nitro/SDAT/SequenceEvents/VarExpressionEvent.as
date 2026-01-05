package Nitro.SDAT.SequenceEvents {
	
	public class VarExpressionEvent extends SequenceEvent {
		
		public var valueVar:uint;

		public function VarExpressionEvent(_valueVar:uint) {
			valueVar=_valueVar;
		}
		
		public function toString():String {
			return "[ExpressionEvent val=rand("+valueVar+")]";
		}

	}
	
}
