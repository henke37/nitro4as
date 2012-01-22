﻿package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	use namespace sequenceInternal;
	
	/** Parser for sequence data */
	
	public class SequenceDataParser {
		
		/** Parses sequence data
		@param data The sequence data to parse
		@return The parsed data*/
		sequenceInternal static function parse(data:ByteArray):Vector.<SequenceTrack> {
			var track:SequenceTrack;
			var tracks:Vector.<SequenceTrack>;
			
			tracks=new Vector.<SequenceTrack>();
			
			track=new SequenceTrack();
			tracks.push(track);
			
			var trackStarts:Vector.<uint>=new Vector.<uint>();
			
			var commandIndex:uint=0;
			
			for(;;) {
				
				track.offsets[data.position]=commandIndex++;
				
				var trackOver:Boolean=false;
				
				var command:uint=data.readUnsignedByte();
				
				var evt:SequenceEvent=null;
				
				if(command<0x80) {//notes
					evt=new NoteEvent(command,data.readUnsignedByte(),readVarLen(data));
				} else switch(command) {
					
					case 0x80:
						evt=new RestEvent(readVarLen(data));
					break;
					
					case 0x81:
						evt=new ProgramChangeEvent(readVarLen(data));
					break;
					
					case 0x93://open track
						data.position+=1;//skip past the id
						var trackPos:uint=read3ByteInt(data);
						if(trackPos>data.length) throw new RangeError("Can't begin a track after the end of the end of the data");
						trackStarts.push(trackPos);
					break;
					
					case 0x94:
						evt=new JumpEvent(read3ByteInt(data),false);
					break;
					
					case 0x95://call
						evt=new JumpEvent(read3ByteInt(data),true);
					break;
					
					case 0xA2:
						evt=new IfEvent();
					break;
					
					case 0xB0:
						evt=new VarEvent(VarEvent.assign,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB1:
						evt=new VarEvent(VarEvent.addition,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB2:
						evt=new VarEvent(VarEvent.subtract,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB3:
						evt=new VarEvent(VarEvent.multiply,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB4:
						evt=new VarEvent(VarEvent.divide,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB5:
						evt=new VarEvent(VarEvent.shift,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB6:
						evt=new VarEvent(VarEvent.random,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB7:
						evt=new VarEvent(VarEvent.unknownOp,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB8:
						evt=new VarEvent(VarEvent.equals,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xB9:
						evt=new VarEvent(VarEvent.greaterThanEq,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xBA:
						evt=new VarEvent(VarEvent.greaterThan,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xBB:
						evt=new VarEvent(VarEvent.lessThanEq,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xBC:
						evt=new VarEvent(VarEvent.lessThan,data.readUnsignedByte(),read3ByteInt(data));
					break;
					case 0xBD:
						evt=new VarEvent(VarEvent.notEqual,data.readUnsignedByte(),read3ByteInt(data));
					break;
					
					case 0xC0:
						evt=new PanEvent(data.readUnsignedByte());
					break;
					
					case 0xC1:
						evt=new VolumeEvent(data.readUnsignedByte(),false);
					break;
					
					case 0xC2:
						evt=new VolumeEvent(data.readUnsignedByte(),true);//master
					break;
					
					case 0xC3:
						evt=new TransposeEvent(data.readUnsignedByte());
					break;
					
					case 0xC4:
						evt=new PitchBendEvent(data.readUnsignedByte(),false);
					break;
					
					case 0xC5:
						evt=new PitchBendEvent(data.readUnsignedByte(),true);//range
					break;
					
					case 0xC6:
						evt=new PriorityEvent(data.readUnsignedByte());
					break;
					
					case 0xC7:
						evt=new MonoPolyEvent(data.readBoolean());
					break;
					
					case 0xCA:
						evt=new ModulationEvent("depth",data.readUnsignedByte());
					break;
					
					case 0xCB:
						evt=new ModulationEvent("speed",data.readUnsignedByte());
					break;
					
					case 0xCC:
						evt=new ModulationEvent("type",data.readUnsignedByte());
					break;
					
					case 0xCD:
						evt=new ModulationEvent("range",data.readUnsignedByte());
					break;
					
					case 0xCE:
						evt=new PortamentoEvent(data.readBoolean());
					break;
					
					case 0xCF:
						evt=new PortamentoTimeEvent(data.readUnsignedByte());
					break;
					
					case 0xD0:
						evt=new ADSREvent("A",data.readUnsignedByte());
					break;
					
					case 0xD1:
						evt=new ADSREvent("D",data.readUnsignedByte());
					break;
					
					case 0xD2:
						evt=new ADSREvent("S",data.readUnsignedByte());
					break;
					
					case 0xD3:
						evt=new ADSREvent("R",data.readUnsignedByte());
					break;
					
					case 0xE0:
						evt=new ModulationEvent("delay",data.readUnsignedShort());
					break;
					
					case 0xE1:
						evt=new TempoEvent(data.readUnsignedShort());
					break;
					
					case 0xE3:
						evt=new SweepPitchEvent(data.readUnsignedShort());
					break;
					
					case 0xD4:
						evt=new LoopStartEvent(data.readUnsignedByte());
					break;
					
					case 0xD5://Expression
						evt=new ExpressionEvent(data.readUnsignedByte());
					break;
					
					case 0xD6://print var
						data.position+=1;
					break;					
					
					case 0xFE://Multitrack marker op
						data.position+=2;//unknown data
					break;
					
					case 0xFC:
						evt=new LoopEndEvent();
					break;
					
					case 0xFD:
						evt=new ReturnEvent();
					break;
					
					case 0xFF:
						evt=new EndTrackEvent();
						trackOver=true;
					break;
					
					default:
						trace("unknown command: "+command.toString(16));
					break;
				}
				
				if(evt) {
					track.events.push(evt);
					trace(evt);
				}
				
				if(trackOver) {
					if(trackStarts.length==0) {
						break;
					} else {
						data.position=trackStarts.shift();
						trackOver=false;
						
						track=new SequenceTrack();
						tracks.push(track);
					}
				}
			}
			
			return tracks;
		}
		
		private static function readVarLen(data:ByteArray):uint {
			var value:uint=0;
			do {
				var byte:uint=data.readUnsignedByte();
				
				value<<=7;
				value|=byte&0x7F;
			} while(byte & 0x80);
			return value;
		}
		
		private static function read3ByteInt(data:ByteArray):uint {
			var value:uint=data.readUnsignedByte();
			value+=data.readUnsignedShort()<<8;
			return value;
		}
	}
}