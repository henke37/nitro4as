package Nitro.SDAT.SequenceEvents {
	
	public class ModulationEvent extends SequenceEvent {
		
		public var type:String;
		public var value:uint;

		public function ModulationEvent(_type:String,_value:uint) {
			type=_type;
			value=_value;
		}

	}
	
}
