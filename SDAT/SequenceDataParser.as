package SDAT {
	
	import flash.utils.*;
	import SDAT.SequenceEvents.*;
	
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
					
					case 0x93://open track
						sdat.position+=1;//skip past the id
						trackStarts.push(read3ByteInt(sdat));
					break;
					
					case 0x94:
						track.events.push(new JumpEvent(read3ByteInt(sdat)));
					break;
					
					case 0xC7:
						track.events.push(new MonoPolyEvent(sdat.readBoolean()));
					break;
					
					case 0xE1:
						track.events.push(new TempoEvent(sdat.readUnsignedShort()));
					break;
					
					case 0xFE://Multitrack marker op
						sdat.position+=2;//unknown data
					break;
					
					case 0xFF:
						trackOver=true;
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