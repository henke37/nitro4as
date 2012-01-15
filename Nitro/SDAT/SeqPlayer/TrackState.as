package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	
	/** The current state of a track in the Tracker */
	public class TrackState {
		
		public var track:SequenceTrack;

		public function TrackState(track:SequenceTrack) {
			if(!track) throw new ArgumentError("Track can not be null!");
			this.track=track;
		}

	}
	
}
