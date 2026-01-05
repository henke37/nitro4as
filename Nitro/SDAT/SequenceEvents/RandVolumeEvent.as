package Nitro.SDAT.SequenceEvents {
	
	public class RandVolumeEvent extends SequenceEvent {
		
		public var master:Boolean;
		public var minVolume:uint
		public var maxVolume:uint

		public function RandVolumeEvent(_minVolume:uint,_maxVolume:uint,_master:Boolean) {
			minVolume=_minVolume;
			maxVolume=_maxVolume;
			master=_master;
		}
		
		public function toString():String {
			if(master) {
				return "[MasterVolumeEvent vol="+minVolume+"/"+maxVolume+"]";
			} else {
				return "[VolumeEvent vol="+minVolume+"/"+maxVolume+"]";
			}
		}

	}
	
}
