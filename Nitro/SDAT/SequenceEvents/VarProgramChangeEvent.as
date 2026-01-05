package Nitro.SDAT.SequenceEvents {
	
	public class VarProgramChangeEvent extends SequenceEvent {

		public var programVar:uint;

		public function VarProgramChangeEvent(_programVar:uint) {
			programVar=_programVar;
		}
		
		public function toString():String {
			return "[ProgramChangeEvent program=var("+programVar+")]";
		}

	}
	
}
