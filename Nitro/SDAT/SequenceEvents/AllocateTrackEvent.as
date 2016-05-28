package Nitro.SDAT.SequenceEvents {
	
	public class AllocateTrackEvent extends SequenceEvent {
		
		public var tracks:uint;

		public function AllocateTrackEvent(tracks:uint) {
			this.tracks=tracks;
		}

	}
	
}
