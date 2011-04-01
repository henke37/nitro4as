package Nitro.SDAT.SequenceEvents {
	
	public class VolumeEvent extends SequenceEvent {
		
		public var master:Boolean;
		public var volume:uint

		public function VolumeEvent(_volume:uint,_master:Boolean) {
			volume=_volume;
			master=_master;
		}

	}
	
}
