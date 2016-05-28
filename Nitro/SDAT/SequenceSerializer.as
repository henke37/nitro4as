package Nitro.SDAT {
	import Nitro.SDAT.SequenceEvents.*;
	
	public class SequenceSerializer {
		
		public function SequenceSerializer() {
			// constructor code
		}
		
		public function serializeSequence(seq:Sequence):String {
			var evt:SequenceEvent;
			
			var jumpTargets:Object={};
			for each(evt in seq.events) {
				var jmpEvt:JumpEvent=evt as JumpEvent;
				if(!jmpEvt) continue;
				jumpTargets[jmpEvt.target]=true;
			}
			var o:String="";
			for(var evtIndex:uint=0;evtIndex<seq.events.length;++evtIndex) {
				evt=seq.events[evtIndex];
				if(evtIndex in jumpTargets) {
					o+="L"+evtIndex+":\n";
				}
				o+=this.serializeEvent(evt)+"\n";
			}
			return o;
		}
		
		public function serializeEvent(evt:SequenceEvent):String {
			var params:Array=parameterizeEvent(evt);
			var cmd:String=params.shift();
			if(evt.suffixIf) cmd+="_if";
			if(evt.suffixVar) cmd+="_v";
			if(evt.suffixRand) cmd+="_r";
			
			if(params.length) {
				return cmd+" "+params.join(", ");
			} else {
				return cmd;
			}
		}
		
		private function parameterizeEvent(evt:SequenceEvent):Array {
			if(evt is NoteEvent) {
				var nEvt:NoteEvent=NoteEvent(evt);
				return [noteName(nEvt.note),nEvt.velocity,nEvt.duration];
			}
			if(evt is RestEvent) {
				return ["wait",RestEvent(evt).rest];
			}
			if(evt is EndTrackEvent) {
				return ["fin"];
			}
			if(evt is ProgramChangeEvent) {
				return ["prg",ProgramChangeEvent(evt).program];
			}
			if(evt is TempoEvent) {
				return ["tempo",TempoEvent(evt).bpm];
			}
			if(evt is PitchBendEvent) {
				var pbEvt:PitchBendEvent=PitchBendEvent(evt);
				if(pbEvt.range) {
					return ["bendrange",pbEvt.bend];
				} else {
					return ["pitchbend",pbEvt.bend];
				}
			}
			if(evt is ExpressionEvent) {
				return ["volume2",ExpressionEvent(evt).value];
			}
			if(evt is TransposeEvent) {
				return ["transpose",TransposeEvent(evt).transpose];
			}
			if(evt is PanEvent) {
				return ["pan",PanEvent(evt).pan];
			}
			if(evt is PriorityEvent) {
				return ["prio",PriorityEvent(evt).prio];
			}
			if(evt is TieEvent) {
				if(TieEvent(evt).tie) {
					return ["tieon"];
				} else {
					return ["tieoff"];
				}
			}
			if(evt is MonoPolyEvent) {
				if(MonoPolyEvent(evt).mono) {
					return ["notewait_on"];
				} else {
					return ["notewait_off"];
				}
			}
			if(evt is PortamentoEvent) {
				return ["porta_"+(PortamentoEvent(evt).enable?"on":"off")];
			}
			if(evt is PortamentoKeyEvent) {
				return ["porta",PortamentoKeyEvent(evt).key];
			}
			if(evt is PortamentoTimeEvent) {
				return ["porta_time",PortamentoTimeEvent(evt).time];
			}
			if(evt is SweepPitchEvent) {
				return ["sweep_pitch",SweepPitchEvent(evt).ammount];
			}
				
			if(evt is JumpEvent) {
				switch(JumpEvent(evt).jumpType) {
					case JumpEvent.JT_CALL:
					return ["call", "L"+JumpEvent(evt).target];
					case JumpEvent.JT_JUMP:
					return ["jump", "L"+JumpEvent(evt).target];
					case JumpEvent.JT_TRACK:
					return ["opentrack", "L"+JumpEvent(evt).target, OpenTrackEvent(evt).track];
				}
			}
			if(evt is ReturnEvent) {
				return ["ret"];
			}
			if(evt is LoopStartEvent) {
				return ["loop_start",LoopStartEvent(evt).count];
			}
			if(evt is LoopEndEvent) {
				return ["loop_end"];
			}
			if(evt is ADSREvent) {
				var adsrEvt:ADSREvent=ADSREvent(evt);
				switch(adsrEvt.type) {
					case "A":
						return ["attack",adsrEvt.value];
					case "D":
						return ["decay",adsrEvt.value];
					case "S":
						return ["sustain",adsrEvt.value];
					case "R":
						return ["release",adsrEvt.value];
				}
			}
			if(evt is ModulationEvent) {
				var mEvt:ModulationEvent=ModulationEvent(evt);
				switch(mEvt.type) {
					case "delay":
						return ["mod_delay",mEvt.value];
					case "depth":
						return ["mod_depth",mEvt.value];
					case "speed":
						return ["mod_speed",mEvt.value];
					case "type":
						return ["mod_type",mEvt.value];
					case "range":
						return ["mod_range",mEvt.value];
				}
			}
			if(evt is VolumeEvent) {
				var volEvt:VolumeEvent=VolumeEvent(evt);
				if(volEvt.master) {
					return ["main_volume",volEvt.volume];
				} else {
					return ["volume",volEvt.volume]; 
				}
			}
			if(evt is VarEvent) {
				var varEvt:VarEvent=VarEvent(evt); 
				switch(varEvt.operation) {
					case VarEvent.assign:
						return ["setvar",varEvt.variable,varEvt.operand];
					case VarEvent.addition:
						return ["addvar",varEvt.variable,varEvt.operand];
					case VarEvent.subtract:
						return ["subvar",varEvt.variable,varEvt.operand];
					case VarEvent.multiply:
						return ["mulvar",varEvt.variable,varEvt.operand];
					case VarEvent.divide:
						return ["divvar",varEvt.variable,varEvt.operand];
					case VarEvent.shift:
						return ["shiftvar",varEvt.variable,varEvt.operand];
					case VarEvent.equals:
						return ["cmp_eq",varEvt.variable,varEvt.operand];
					case VarEvent.greaterThan:
						return ["cmp_gt",varEvt.variable,varEvt.operand];
					case VarEvent.greaterThanEq:
						return ["cmp_ge",varEvt.variable,varEvt.operand];
					case VarEvent.lessThanEq:
						return ["cmp_le",varEvt.variable,varEvt.operand];
					case VarEvent.lessThan:
						return ["cmp_lt",varEvt.variable,varEvt.operand];
					case VarEvent.notEqual:
						return ["cmp_ne",varEvt.variable,varEvt.operand];
					case VarEvent.random:
						return ["randvar",varEvt.variable,varEvt.operand];
				}
			}
			if(evt is AllocateTrackEvent) {
				return ["alloctrack",AllocateTrackEvent(evt).tracks.toString(16)];
			}
			if(evt is PrintVarEvent) {
				return ["printvar",PrintVarEvent(evt).variable];
			}
			throw new Error("Unknown event type!");
		}
		
		private function noteName(note:uint):String {
			var oct:int=note/12;
			--oct;
			
			return ["cn", "cs", "dn", "ds", "en", "fn",
			"fs", "gn", "gs", "an", "as", "bn",
			][note%12]+(oct==-1?"m1":oct);
		}

	}
	
}
