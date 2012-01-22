﻿package Nitro.SDAT.SequenceEvents {
	
	public class ProgramChangeEvent extends SequenceEvent {

		public var program:uint;

		public function ProgramChangeEvent(_program:uint) {
			program=_program;
		}
		
		public function toString():String {
			return "[ProgramChangeEvent program="+program+"]";
		}

	}
	
}
