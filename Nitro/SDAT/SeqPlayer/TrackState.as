package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	/** The current state of a track in the Tracker */
	public class TrackState {
		
		private var track:SequenceTrack;
		
		private var tracker:Tracker;
		
		private var priority:uint;
		private var polyphonic:Boolean;
		
		private var attack:uint;
		private var decay:uint;
		private var sustain:uint;
		private var release:uint;

		public function TrackState(tracker:Tracker,track:SequenceTrack) {
			if(!track) throw new ArgumentError("Track can not be null!");
			this.track=track;
		}
		
		private function executeEvent(evt:SequenceEvent):void {
			if(evt is NoteEvent) {
				tracker.chanMgr.startNote(null);
			} else if(evt is RestEvent) {
				
			} else if(evt is PriorityEvent) {
				priority=(evt as PriorityEvent).prio;
			} else if(evt is MonoPolyEvent) {
				polyphonic=!(evt as MonoPolyEvent).mono;
			} else if(evt is VolumeEvent) {
				var volEvt:VolumeEvent=evt as VolumeEvent;
				if(volEvt.master) {
					
				} else {
					tracker.volume=volEvt.volume;
				}
			} else if(evt is ADSREvent) {
				var adsrEvt:ADSREvent=evt as ADSREvent;
				switch(adsrEvt.type) {
					case "A":
						attack=adsrEvt.value;
					break;
					
					case "D":
						decay=adsrEvt.value;
					break;
					
					case "S":
						sustain=adsrEvt.value;
					break;
					
					default://must be "R"
						release=adsrEvt.value;
					break;
				}
			}
		}

	}
	
}
