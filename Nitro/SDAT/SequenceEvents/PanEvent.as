﻿package Nitro.SDAT.SequenceEvents {
	
	public class PanEvent extends SequenceEvent {

		public var pan:uint

		public function PanEvent(_pan:uint) {
			pan=_pan;
		}
		
		public function toString():String {
			return "[PanEvent pan="+pan+"]";
		}

	}
	
}
