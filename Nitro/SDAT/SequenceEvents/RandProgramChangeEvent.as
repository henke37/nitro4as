package Nitro.SDAT.SequenceEvents {
	
	public class RandProgramChangeEvent extends SequenceEvent {

		public var minProgram:uint;
		public var maxProgram:uint;

		public function RandProgramChangeEvent(_minProgram:uint,_maxProgram:uint) {
			minProgram=_minProgram;
			maxProgram=_maxProgram;
		}
		
		public function toString():String {
			return "[ProgramChangeEvent program="+minProgram+"/"+maxProgram+"]";
		}

	}
	
}
