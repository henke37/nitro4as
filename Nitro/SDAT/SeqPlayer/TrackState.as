﻿package Nitro.SDAT.SeqPlayer {
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
		
		internal var priority:uint;
		private var polyphonic:Boolean;
		
		internal var attack:int;
		internal var decay:int;
		internal var sustain:int;
		internal var release:int;
		
		internal var volume:uint;
		internal var pan:uint;
		internal var expression:uint;
		
		internal var modType:uint;
		internal var modDepth:uint;
		internal var modRange:uint;
		internal var modSpeed:uint;
		internal var modDelay:uint;
		
		internal var pitchBend:int;
		internal var pitchBendRange:uint;

		public function TrackState(tracker:Tracker,track:SequenceTrack) {
			if(!track) throw new ArgumentError("Track can not be null!");
			if(!tracker) throw new ArgumentError("Tracker can not be null!");
			this.track=track;
			this.tracker=tracker;
		}
		
		public function reset():void {
			attack=-1;
			decay=-1;
			sustain=-1;
			release=-1;
			
			position=0;
			
			volume=64;
			expression=127;
			pan=64;
			
			modType = ChannelState.MOD_FREQ;
			modDepth = 0;
			modRange = 1;
			modSpeed = 16;
			modDelay = 10;
			priority = 64;
			
			pitchBend=0;
			pitchBendRange=2;
		}
		
		private function executeEvent(evt:SequenceEvent):void {
			
			var normalFlow:Boolean=true;
			
			if(evt is NoteEvent) {
				var noteEvt:NoteEvent=evt as NoteEvent;
				var instrument:Instrument=instrumentForNote(noteEvt);
				tracker.chanMgr.startNote(instrument,noteEvt,this);
			} else if(evt is RestEvent) {
				
			} else if(evt is ExpressionEvent) {
				expression=(evt as ExpressionEvent).value;
			} else if(evt is PriorityEvent) {
				priority=(evt as PriorityEvent).prio;
			} else if(evt is MonoPolyEvent) {
				polyphonic=!(evt as MonoPolyEvent).mono;
			} else if(evt is VolumeEvent) {
				var volEvt:VolumeEvent=evt as VolumeEvent;
				if(volEvt.master) {
					
				} else {
					volume=volEvt.volume;
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
				pan=(evt as PanEvent).pan;
			} else if(evt is TempoEvent) {
				tracker.tempo=(evt as TempoEvent).bpm;
			} else if(evt is JumpEvent) {
				var jmpEvt:JumpEvent=evt as JumpEvent;
				position=track.offsets[jmpEvt.target];
				if(jmpEvt.isCall) callReturn=position+1;
				normalFlow=false;
			} else if(evt is LoopStartEvent) {
				var loopStartEvt:LoopStartEvent=evt as LoopStartEvent;
				loopCountDown=loopStartEvt.count;
				loopReturn=position+1;
			} else if(evt is LoopEndEvent) {
				if(loopCountDown>0) {
					position=loopReturn;
					loopCountDown--;
					normalFlow=false;
				}
			}
			
			if(normalFlow) {
				position++;
			}
		}
		
		
		private function instrumentForNote(noteEvt:NoteEvent):Instrument {
			return null;
		}

	}
	
}
