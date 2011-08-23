﻿package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	use namespace sequenceInternal;
	
	public class SequenceDataParser {
		
		sequenceInternal static function parse(data:ByteArray):Vector.<SequenceTrack> {
			var track:SequenceTrack;
			var tracks:Vector.<SequenceTrack>;
			
			tracks=new Vector.<SequenceTrack>();
			
			track=new SequenceTrack();
			tracks.push(track);
			
			var trackStarts:Vector.<uint>=new Vector.<uint>();
			
			//var offsets:Vector.<Object>=new Vector.<Object>();
			
			for(;;) {
				
				var trackOver:Boolean=false;
				
				var command:uint=data.readUnsignedByte();
				
				if(command<0x80) {//notes
					track.events.push(new NoteEvent(command,data.readUnsignedByte(),readVarLen(data)));
					continue;
				}
				
				switch(command) {
					
					case 0x80:
						track.events.push(new RestEvent(readVarLen(data)));
					break;
					
					case 0x81:
						track.events.push(new ProgramChangeEvent(readVarLen(data)));
					break;
					
					case 0x93://open track
						data.position+=1;//skip past the id
						var trackPos:uint=read3ByteInt(data);
						if(trackPos>data.length) throw new RangeError("Can't begin a track after the end of the end of the data");
						trackStarts.push(trackPos);
					break;
					
					case 0x94:
						track.events.push(new JumpEvent(read3ByteInt(data),false));
					break;
					
					case 0x95://call
						track.events.push(new JumpEvent(read3ByteInt(data),true));
					break;
					
					case 0xC0:
						track.events.push(new PanEvent(data.readUnsignedByte()));
					break;
					
					case 0xC1:
						track.events.push(new VolumeEvent(data.readUnsignedByte(),false));
					break;
					
					case 0xC2:
						track.events.push(new VolumeEvent(data.readUnsignedByte(),true));//master
					break;
					
					case 0xC3:
						track.events.push(new TransposeEvent(data.readUnsignedByte()));
					break;
					
					case 0xC4:
						track.events.push(new PitchBendEvent(data.readUnsignedByte(),false));
					break;
					
					case 0xC5:
						track.events.push(new PitchBendEvent(data.readUnsignedByte(),true));//range
					break;
					
					case 0xC6:
						track.events.push(new PriorityEvent(data.readUnsignedByte()));
					break;
					
					case 0xC7:
						track.events.push(new MonoPolyEvent(data.readBoolean()));
					break;
					
					case 0xCA:
						track.events.push(new ModulationEvent("depth",data.readUnsignedByte()));
					break;
					
					case 0xCB:
						track.events.push(new ModulationEvent("speed",data.readUnsignedByte()));
					break;
					
					case 0xCC:
						track.events.push(new ModulationEvent("type",data.readUnsignedByte()));
					break;
					
					case 0xCD:
						track.events.push(new ModulationEvent("range",data.readUnsignedByte()));
					break;
					
					case 0xCE:
						track.events.push(new PortamentoEvent(data.readBoolean()));
					break;
					
					case 0xCF:
						track.events.push(new PortamentoTimeEvent(data.readUnsignedByte()));
					break;
					
					case 0xD0:
						track.events.push(new ADSREvent("A",data.readUnsignedByte()));
					break;
					
					case 0xD1:
						track.events.push(new ADSREvent("D",data.readUnsignedByte()));
					break;
					
					case 0xD2:
						track.events.push(new ADSREvent("S",data.readUnsignedByte()));
					break;
					
					case 0xD3:
						track.events.push(new ADSREvent("R",data.readUnsignedByte()));
					break;
					
					case 0xE0:
						track.events.push(new ModulationEvent("delay",data.readUnsignedShort()));
					break;
					
					case 0xE1:
						track.events.push(new TempoEvent(data.readUnsignedShort()));
					break;
					
					case 0xE3:
						track.events.push(new SweepPitchEvent(data.readUnsignedShort()));
					break;
					
					case 0xD4:
						track.events.push(new LoopStartEvent(data.readUnsignedByte()));
					break;
					
					case 0xD5://Expression
						track.events.push(new ExpressionEvent(data.readUnsignedByte()));
					break;
					
					case 0xD6://print var
						data.position+=1;
					break;					
					
					case 0xFE://Multitrack marker op
						data.position+=2;//unknown data
					break;
					
					case 0xFC:
						track.events.push(new LoopEndEvent());
					break;
					
					case 0xFD:
						track.events.push(new ReturnEvent());
					break;
					
					case 0xFF:
						trackOver=true;
					break;
					
					default:
						trace("unknown command: "+command.toString(16));
					break;
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
			return 0;
		}
		
		private static function read3ByteInt(data:ByteArray):uint {
			var value:uint=data.readUnsignedByte();
			value+=data.readUnsignedShort()<<8;
			return value;
		}
	}
}