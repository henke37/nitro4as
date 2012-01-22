﻿package Nitro.SDAT.SequenceEvents {
	
	public class TempoEvent extends SequenceEvent {

		public var bpm:uint;

		public function TempoEvent(_bpm:uint) {
			bpm=_bpm;
		}


		public function toString():String {
			return "[TempoEvent bpm="+bpm+"]";
		}
	}
	
}
