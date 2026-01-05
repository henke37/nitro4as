package Nitro.SDAT.SequenceEvents {
	
	public class VarPitchBendEvent extends SequenceEvent {
		
		public var bendVar:int;
		public var range:Boolean;

		public function VarPitchBendEvent(_bendVar:int,_range:Boolean) {
			bendVar=_bendVar;
			range=_range;
		}

	}
	
}
