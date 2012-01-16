package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	/** The current state of a track in the Tracker */
	public class TrackState {
		
		private var track:SequenceTrack;
		
		private var tracker:Tracker;
		
		private var position:uint;
		
		private var loopReturn:uint;
		private var loopCountDown:uint;
		
		private var callReturn:uint;
		
		private var priority:uint;
		private var polyphonic:Boolean;
		
		internal var attack:uint;
		internal var decay:uint;
		internal var sustain:uint;
		internal var release:uint;

		public function TrackState(tracker:Tracker,track:SequenceTrack) {
			if(!track) throw new ArgumentError("Track can not be null!");
			if(!tracker) throw new ArgumentError("Tracker can not be null!");
			this.track=track;
			this.tracker=tracker;
		}
		
		private function executeEvent(evt:SequenceEvent):void {
			if(evt is NoteEvent) {
				tracker.chanMgr.startNote(null,this);
			} else if(evt is RestEvent) {
				
			} else if(evt is ExpressionEvent) {
				tracker.expression=(evt as ExpressionEvent).value;
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
			} else if(evt is PanEvent) {
				tracker.pan=(evt as PanEvent).pan;
			} else if(evt is TempoEvent) {
				tracker.tempo=(evt as TempoEvent).bpm;
			} else if(evt is JumpEvent) {
				var jmpEvt:JumpEvent=evt as JumpEvent;
				position=jmpEvt.target;
				if(jmpEvt.isCall) callReturn=position+1;
			} else if(evt is LoopStartEvent) {
				var loopStartEvt:LoopStartEvent=evt as LoopStartEvent;
				loopCountDown=loopStartEvt.count;
				loopReturn=position+1;
			} else if(evt is LoopEndEvent) {
				if(loopCountDown>0) {
					position=loopReturn;
					loopCountDown--;
				}
			}
		}

	}
	
}
