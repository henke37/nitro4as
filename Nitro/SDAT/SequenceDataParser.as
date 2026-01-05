package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	use namespace sequenceInternal;
	
	/** Parser for sequence data */
	
	public class SequenceDataParser {
		
		private var flows:Object;
		private var unparsedFlows:Vector.<Flow>;
		private var commandIndex:uint=0;
		
		private var untranslatedJumps:Vector.<JumpEvent>;
		
		private var data:ByteArray;
		
		private var suffixIf:Boolean=false;
		private var flowOver:Boolean=false;
		
		public function SequenceDataParser() {
			flows={};
			unparsedFlows=new Vector.<Flow>();
		}
		
		/** Parses sequence data
		@param data The sequence data to parse
		@return The parsed data*/
		sequenceInternal function parse(data:ByteArray):Sequence {
			
			this.data=data;
			
			var seq:Sequence=new Sequence();
			
			var newFlow:Flow;
			
			newFlow=new Flow(data.position);
			flows[data.position]=newFlow;
			newFlow.parsed=true;
			
			untranslatedJumps=new Vector.<JumpEvent>();
			
			var suffixVar:Boolean=false;
			var suffixRand:Boolean=false;
			
parseLoop: for(;;) {
				
				flowOver=false;
				
				newFlow=null;
	
				var evt:SequenceEvent=readEvent(data);
				
				if(evt) {
					commandIndex++;
					
					if(suffixIf) {
						evt.suffixIf=true;
						suffixIf=false;
					}
				
					
					var jmpEvt:JumpEvent = evt as JumpEvent;
					if(jmpEvt) {
						untranslatedJumps.push(jmpEvt);
						newFlow=new Flow(jmpEvt.target);
						flowOver=!suffixIf;
					}
				
					//must push null to keep indexes correct
					seq.events.push(evt);
					//trace(evt,commandIndex,data.position.toString(16));
				}
				
				if(newFlow && !(newFlow.rawOffset in flows)) {
					unparsedFlows.push(newFlow);
					flows[newFlow.rawOffset]=newFlow;
				}
				
				if(flowOver) {
					if(unparsedFlows.length==0) {
						break;
					} else {
						var nextFlow:Flow=unparsedFlows.shift();
						data.position=nextFlow.rawOffset;
						nextFlow.parsed=true;
						nextFlow.commandIndex=commandIndex;
						//trace("new flow at:",nextFlow.rawOffset.toString(16));
					}
				}//end if flowOver
			}//end forever
			
			translateJumpEvents();
			
			return seq;
		}
	
		private function translateJumpEvents():void {
			for(var i:uint=0;i<untranslatedJumps.length;++i) {
				var jmpEvt:JumpEvent=untranslatedJumps[i];
				jmpEvt.target=flows[jmpEvt.target].commandIndex;
			}
		}
	
		private function readEvent(data:ByteArray):SequenceEvent {
			var command:uint=data.readUnsignedByte();
				
				if(command<0x80) {//notes
					return new NoteEvent(command,data.readUnsignedByte(),readVarLen());
				} else switch(command) {
					
					case 0x80:
						return new RestEvent(readVarLen());
					break;
					
					case 0x81:
						return new ProgramChangeEvent(readVarLen());
					break;
					
					case 0x93://open track
						var trackId:uint=data.readUnsignedByte();
						var trackPos:uint=read3ByteInt();
						if(trackPos>data.length) throw new RangeError("Can't begin a track after the end of the end of the data");
						return new OpenTrackEvent(trackPos,trackId);
					break;
					
					case 0x94:
						var jmpTarget:uint=read3ByteInt();
						return new JumpEvent(jmpTarget,JumpEvent.JT_JUMP);
					break;
					
					case 0x95://call
						jmpTarget=read3ByteInt();
						return new JumpEvent(jmpTarget,JumpEvent.JT_CALL);
					break;
					case 0xA0://rand
						return readRandEvent();
					case 0xA1://var
						return readVarEvent();
					case 0xA2:
						suffixIf=true;
						return null;
					break;
					
					case 0xB0:
						return new VarEvent(VarEvent.assign,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB1:
						return new VarEvent(VarEvent.addition,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB2:
						return new VarEvent(VarEvent.subtract,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB3:
						return new VarEvent(VarEvent.multiply,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB4:
						return new VarEvent(VarEvent.divide,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB5:
						return new VarEvent(VarEvent.shift,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB6:
						return new VarEvent(VarEvent.random,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB7:
						return new VarEvent(VarEvent.unknownOp,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB8:
						return new VarEvent(VarEvent.equals,data.readUnsignedByte(),data.readShort());
					break;
					case 0xB9:
						return new VarEvent(VarEvent.greaterThanEq,data.readUnsignedByte(),data.readShort());
					break;
					case 0xBA:
						return new VarEvent(VarEvent.greaterThan,data.readUnsignedByte(),data.readShort());
					break;
					case 0xBB:
						return new VarEvent(VarEvent.lessThanEq,data.readUnsignedByte(),data.readShort());
					break;
					case 0xBC:
						return new VarEvent(VarEvent.lessThan,data.readUnsignedByte(),data.readShort());
					break;
					case 0xBD:
						return new VarEvent(VarEvent.notEqual,data.readUnsignedByte(),data.readShort());
					break;
					
					case 0xC0:
						return new PanEvent(data.readUnsignedByte());
					break;
					
					case 0xC1:
						return new VolumeEvent(data.readUnsignedByte(),false);
					break;
					
					case 0xC2:
						return new VolumeEvent(data.readUnsignedByte(),true);//master
					break;
					
					case 0xC3:
						return new TransposeEvent(data.readUnsignedByte());
					break;
					
					case 0xC4:
						return new PitchBendEvent(data.readByte(),false);
					break;
					
					case 0xC5:
						return new PitchBendEvent(data.readByte(),true);//range
					break;
					
					case 0xC6:
						return new PriorityEvent(data.readUnsignedByte());
					break;
					
					case 0xC7:
						return new MonoPolyEvent(data.readBoolean());
					break;
					
					case 0xC8:
						return new TieEvent(data.readBoolean());
					break;
					
					case 0xC9:
						return new PortamentoKeyEvent(data.readUnsignedByte());
					break;
					
					case 0xCA:
						return new ModulationEvent("depth",data.readUnsignedByte());
					break;
					
					case 0xCB:
						return new ModulationEvent("speed",data.readUnsignedByte());
					break;
					
					case 0xCC:
						return new ModulationEvent("type",data.readUnsignedByte());
					break;
					
					case 0xCD:
						return new ModulationEvent("range",data.readUnsignedByte());
					break;
					
					case 0xCE:
						return new PortamentoEvent(data.readBoolean());
					break;
					
					case 0xCF:
						return new PortamentoTimeEvent(data.readUnsignedByte());
					break;
					
					case 0xD0:
						return new ADSREvent("A",data.readUnsignedByte());
					break;
					
					case 0xD1:
						return new ADSREvent("D",data.readUnsignedByte());
					break;
					
					case 0xD2:
						return new ADSREvent("S",data.readUnsignedByte());
					break;
					
					case 0xD3:
						return new ADSREvent("R",data.readUnsignedByte());
					break;
					
					case 0xD4:
						return new LoopStartEvent(data.readUnsignedByte());
					break;
					
					case 0xD5://Expression
						return new ExpressionEvent(data.readUnsignedByte());
					break;
					
					case 0xD6://print var
						return new PrintVarEvent(data.readUnsignedByte());
					break;	
					
					case 0xE0:
						return new ModulationEvent("delay",data.readUnsignedShort());
					break;
					
					case 0xE1:
						return new TempoEvent(data.readUnsignedShort());
					break;
					
					case 0xE3:
						return new SweepPitchEvent(data.readUnsignedShort());
					break;
					
					case 0xFE://Multitrack marker op
						return new AllocateTrackEvent(data.readUnsignedShort());
					break;
					
					case 0xFC:
						return new LoopEndEvent();
					break;
					
					case 0xFD:
						flowOver=!suffixIf;
						return new ReturnEvent();
					break;
					
					case 0xFF:
						flowOver=!suffixIf;
						return new EndTrackEvent();
					break;
					
					default:
						trace("unknown command: "+command.toString(16));
						return null;
					break;
				}
			
			return null;
		}
	
		private function readRandEvent():SequenceEvent {
				var command:uint=data.readUnsignedByte();
				
				if(command<0x80) {//notes
					return new RandNoteEvent(command,data.readUnsignedByte(),data.readUnsignedShort(),data.readUnsignedShort());
				} else switch(command) {
					case 0x80:
						return new RandRestEvent(data.readUnsignedShort(),data.readUnsignedShort());
					break;
					
					case 0xC1:
						return new RandVolumeEvent(data.readShort(),data.readShort(),false);
					break;
					
					case 0xC4:
						return new RandPitchBendEvent(data.readShort(),data.readShort(),false);
					
					case 0xC5:
						return new RandPitchBendEvent(data.readShort(),data.readShort(),true);//range
					
					default:
						trace("unknown rand command: "+command.toString(16));
						return null;
				}
			
				return null;
		}
	
		private function readVarEvent():SequenceEvent {
				var command:uint=data.readUnsignedByte();
				
				if(command<0x80) {//notes
					return new VarNoteEvent(command,data.readUnsignedByte(),data.readUnsignedByte());
				} else switch(command) {
					case 0xC4:
						return new VarPitchBendEvent(data.readByte(),false);
					break;
					default:
						trace("unknown var command: "+command.toString(16));
						return null;
				}
			
				return null;
		}
		
		private function readVarLen():uint {
			var value:uint=0;
			do {
				var byte:uint=data.readUnsignedByte();
				
				value<<=7;
				value|=byte&0x7F;
			} while(byte & 0x80);
			return value;
		}
		
		private function read3ByteInt():uint {
			var value:uint=data.readUnsignedByte();
			value+=data.readUnsignedShort()<<8;
			return value;
		}
	}
}

class Flow {
	public var parsed:Boolean=false;
	public var rawOffset:uint;
	public var commandIndex:uint;
	
	public function Flow(rawOffset:uint) {
		this.rawOffset=rawOffset;
	}
}