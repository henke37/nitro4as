package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	use namespace sequenceInternal;
	
	public class SequenceDataParser {
		
		sequenceInternal static function parse(sdat:ByteArray,offset:uint) {
			var track:SequenceTrack;
			var tracks:Vector.<SequenceTrack>;
			
			tracks=new Vector.<SequenceTrack>();
			
			track=new SequenceTrack();
			tracks.push(track);
			
			var trackStarts:Vector.<uint>=new Vector.<uint>();
			
			sdat.position=offset;
			
			//var offsets:Vector.<Object>=new Vector.<Object>();
			
			for(;;) {
				
				var trackOver:Boolean=false;
				
				var command:uint=sdat.readUnsignedByte();
				
				if(command<0x80) {//notes
					track.events.push(new NoteEvent(command,sdat.readUnsignedByte(),readVarLen(sdat)));
					continue;
				}
				
				switch(command) {
					
					case 0x80:
						track.events.push(new RestEvent(readVarLen(sdat)));
					break;
					
					case 0x81:
						track.events.push(new ProgramChangeEvent(readVarLen(sdat)));
					break;
					
					case 0x93://open track
						sdat.position+=1;//skip past the id
						trackStarts.push(read3ByteInt(sdat));
					break;
					
					case 0x94:
						track.events.push(new JumpEvent(read3ByteInt(sdat),false));
					break;
					
					case 0x95://call
						track.events.push(new JumpEvent(read3ByteInt(sdat),true));
					break;
					
					case 0xC0:
						track.events.push(new PanEvent(sdat.readUnsignedByte()));
					break;
					
					case 0xC1:
						track.events.push(new VolumeEvent(sdat.readUnsignedByte(),false));
					break;
					
					case 0xC2:
						track.events.push(new VolumeEvent(sdat.readUnsignedByte(),true));//master
					break;
					
					case 0xC3:
						track.events.push(new TransposeEvent(sdat.readUnsignedByte()));
					break;
					
					case 0xC4:
						track.events.push(new PitchBendEvent(sdat.readUnsignedByte(),false));
					break;
					
					case 0xC5:
						track.events.push(new PitchBendEvent(sdat.readUnsignedByte(),true));//range
					break;
					
					case 0xC6:
						track.events.push(new PriorityEvent(sdat.readUnsignedByte()));
					break;
					
					case 0xC7:
						track.events.push(new MonoPolyEvent(sdat.readBoolean()));
					break;
					
					case 0xCA:
						track.events.push(new ModulationEvent("depth",sdat.readUnsignedByte()));
					break;
					
					case 0xCB:
						track.events.push(new ModulationEvent("speed",sdat.readUnsignedByte()));
					break;
					
					case 0xCC:
						track.events.push(new ModulationEvent("type",sdat.readUnsignedByte()));
					break;
					
					case 0xCD:
						track.events.push(new ModulationEvent("range",sdat.readUnsignedByte()));
					break;
					
					case 0xCE:
						track.events.push(new PortamentoEvent(sdat.readBoolean()));
					break;
					
					case 0xCF:
						track.events.push(new PortamentoTimeEvent(sdat.readUnsignedByte()));
					break;
					
					case 0xD0:
						track.events.push(new ADSREvent("A",sdat.readUnsignedByte()));
					break;
					
					case 0xD1:
						track.events.push(new ADSREvent("D",sdat.readUnsignedByte()));
					break;
					
					case 0xD2:
						track.events.push(new ADSREvent("S",sdat.readUnsignedByte()));
					break;
					
					case 0xD3:
						track.events.push(new ADSREvent("R",sdat.readUnsignedByte()));
					break;
					
					case 0xE0:
						track.events.push(new ModulationEvent("delay",sdat.readUnsignedShort()));
					break;
					
					case 0xE1:
						track.events.push(new TempoEvent(sdat.readUnsignedShort()));
					break;
					
					case 0xE3:
						track.events.push(new SweepPitchEvent(sdat.readUnsignedShort()));
					break;
					
					case 0xD4:
						track.events.push(new LoopStartEvent(sdat.readUnsignedByte()));
					break;
					
					case 0xD5://Expression
						track.events.push(new ExpressionEvent(sdat.readUnsignedByte()));
					break;
					
					case 0xD6://print var
						sdat.position+=1;
					break;					
					
					case 0xFE://Multitrack marker op
						sdat.position+=2;//unknown data
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
						sdat.position=offset+trackStarts.shift();
						trackOver=false;
						
						track=new SequenceTrack();
						tracks.push(track);
					}
				}
			}
			
			return tracks;
		}
		
		private static function readVarLen(sdat:ByteArray):uint {
			var value:uint=0;
			do {
				var byte:uint=sdat.readUnsignedByte();
				
				value<<=7;
				value|=byte&0x7F;
			} while(byte & 0x80);
			return 0;
		}
		
		private static function read3ByteInt(sdat:ByteArray):uint {
			var value:uint=sdat.readUnsignedByte();
			value+=sdat.readUnsignedShort()<<8;
			return value;
		}
	}
}