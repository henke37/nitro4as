package SDAT.SequenceEvents {
	
	public class ProgramChangeEvent extends SequenceEvent {

		public var program:uint;

		public function ProgramChangeEvent(_program:uint) {
			program=_program;
		}

	}
	
}
