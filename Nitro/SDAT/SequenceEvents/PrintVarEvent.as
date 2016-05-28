package Nitro.SDAT.SequenceEvents {
	
	public class PrintVarEvent extends SequenceEvent {
		
		public var variable:uint;

		public function PrintVarEvent(variable:uint) {
			this.variable=variable;
		}

	}
	
}
