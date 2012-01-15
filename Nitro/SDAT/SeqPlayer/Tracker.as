package Nitro.SDAT.SeqPlayer {
	
	import Nitro.SDAT.*;
	
	/** Tracker, reads the tracks in a sequence and figures out in what order to execute the commands.
	
	<p>It also deals with playback logic such as looping, calls and variables.</p>*/
	public class Tracker {
		
		private var seq:SSEQ;
		
		private var tracks:Vector.<TrackState>;

		public function Tracker() {
			// constructor code
		}
		
		/** Loads the tracks from a sequence and readies playback.
		@param seq The sequence to load from*/
		public function loadTracks(seq:SSEQ):void {
			if(!seq) throw new ArgumentError("seq can not be null!");
			this.seq=seq;
			
			tracks=new Vector.<TrackState>();
			tracks.length=seq.tracks.length;
			tracks.fixed=true;
			
			var i:uint=0;
			for each(var track:SequenceTrack in seq.tracks) {
				var trackState:TrackState=new TrackState(track);
				tracks[i++]=trackState;
			}
		}

	}
	
}
