package Nitro.SDAT.SeqPlayer {
	
	import Nitro.SDAT.*;
	
	/** Tracker, reads the tracks in a sequence and figures out in what order to execute the commands.
	
	<p>It also deals with playback logic such as looping, calls and variables.</p>*/
	public class Tracker {
		
		internal var seq:Sequence;
		
		internal var chanMgr:ChannelManager;
		
		private var tracks:Vector.<TrackState>;
		
		/** The tempo measured in BPM */
		internal var tempo:uint;
		
		private var updateCounter:uint;
		
		private static const updateThreshold:uint=240;

		public function Tracker(chanMgr:ChannelManager) {
			if(!chanMgr) throw new ArgumentError("chanMgr can not be null!");
			this.chanMgr=chanMgr;
		}
		
		/** Loads the tracks from a sequence and readies playback.
		@param seq The sequence to load from*/
		public function loadTracks(seq:Sequence):void {
			if(!seq) throw new ArgumentError("seq can not be null!");
			this.seq=seq;
			
			tracks=new Vector.<TrackState>();
			tracks.length=seq.trackStarts.length;
			tracks.fixed=true;
			
			var i:uint=0;
			for each(var trackStart:uint in seq.trackStarts) {
				var trackState:TrackState=new TrackState(this,trackStart);
				tracks[i++]=trackState;
			}
		}
		
		public function reset():void {
			for each(var track:TrackState in tracks) {
				track.reset();
			}
			tempo=120;
		}
		
		internal function updateTick():void {
			
			while(updateCounter>updateThreshold) {
				
				for each(var track:TrackState in tracks) {
					track.tick();
				}
				updateCounter-=updateThreshold;
			}
			
			updateCounter+=tempo;
		}

	}
	
}
