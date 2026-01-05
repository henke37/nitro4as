package Nitro.SDAT.SequenceEvents {
	
	public class VarModulationEvent extends SequenceEvent {
		
		public var type:String;
		public var valueVar:uint;

		public function VarModulationEvent(_type:String,_valueVar:uint) {
			type=_type;
			valueVar=_valueVar;
		}

	}
	
}
