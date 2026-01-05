package Nitro.SDAT.SequenceEvents {
	
	public class RandExpressionEvent extends SequenceEvent {
		
		public var minValue:uint;
		public var maxValue:uint;

		public function RandExpressionEvent(minValue:uint,maxValue:uint) {
			this.minValue=minValue;
			this.maxValue=maxValue;
		}
		
		public function toString():String {
			return "[ExpressionEvent val="+minValue+"/"+maxValue+"]";
		}

	}
	
}
