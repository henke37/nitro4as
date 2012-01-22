package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	/** The current state of a track in the Tracker */
	public class TrackState {
		
		private var tracker:Tracker;
		
		private var position:uint;
		
		private var loopReturn:uint;
		private var loopCountDown:uint;
		
		private var callReturn:uint;
		
		internal var patch:uint;
		
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
		
		private var updateDelay:uint;
		
		private var active:Boolean;

		public function TrackState(tracker:Tracker,trackStart:uint) {
			if(!tracker) throw new ArgumentError("Tracker can not be null!");
			position=trackStart;
			this.tracker=tracker;
		}
		
		public function reset():void {
			attack=-1;
			decay=-1;
			sustain=-1;
			release=-1;
			
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
			
			updateDelay=0;
			active=true;
		}
		
		private function executeEvent(evt:SequenceEvent):void {
			
			var normalFlow:Boolean=true;
			
			if(evt is NoteEvent) {
				var noteEvt:NoteEvent=evt as NoteEvent;
				tracker.chanMgr.startNote(noteEvt,this);
				if(!polyphonic) {
					updateDelay=noteEvt.duration;
				}
			} else if(evt is RestEvent) {
				updateDelay=(evt as RestEvent).rest;
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
				position=jmpEvt.target;
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
			} else if(evt is ModulationEvent) {
				var modEvt:ModulationEvent= evt as ModulationEvent;
				switch(modEvt.type) {
					
					case "depth":
						modDepth=modEvt.value;
					break;
					
					case "speed":
						modSpeed=modEvt.value;
					break;
					
					case "type":
						modType=modEvt.value;
					break;
					
					case "range":
						modRange=modEvt.value;
					break;
					
					case "delay":
						modDelay=modEvt.value;
					break;
					
					default:
						throw new Error("Unknown modulation event type!");
					break;
				}
			} else if(evt is PitchBendEvent) {
				var pitchEvt:PitchBendEvent=evt as PitchBendEvent;
				if(pitchEvt.range) {
					pitchBendRange=pitchEvt.bend;
				} else {
					pitchBend=pitchEvt.bend;
				}
				tracker.chanMgr.updatePitchBend(this);
			} else if(evt is EndTrackEvent) {
				this.active=false;
			} else if(evt is ProgramChangeEvent) {
				patch=(evt as ProgramChangeEvent).program;
			}
			
			if(normalFlow) {
				position++;
			}
		}
		
		public function tick():void {
			if(updateDelay) {
				--updateDelay;
				return;
			}
			
			do {
				if(!active) break;
				var nextEvt:SequenceEvent=tracker.seq.events[position];
				trace(position,nextEvt);
				executeEvent(nextEvt);
			} while(updateDelay==0);
		}

	}
	
}
