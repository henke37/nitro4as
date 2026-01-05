package Nitro.SDAT.SequenceEvents {
	
	public class RandModulationEvent extends SequenceEvent {
		
		public var type:String;
		public var minValue:uint;
		public var maxValue:uint;

		public function RandModulationEvent(_type:String,_minValue:uint,_maxValue:uint) {
			type=_type;
			minValue=_minValue;
			maxValue=_maxValue;
		}

	}
	
}
