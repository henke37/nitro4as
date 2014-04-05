package Nitro.SDAT {
	import flash.utils.*;
	import HTools.Audio.MidiPlayer.Instrument;
	
	/** An instrument that can be used to play a melody */
	public class Instrument {
		
		/** Null instrument */
		public static const INSTRUMENT_TYPE_NULL:uint=0;
		/** Sample instrument */
		public static const INSTRUMENT_TYPE_PCM:uint=1;
		/** Rectangle wave instrument */
		public static const INSTRUMENT_TYPE_PULSE:uint=2;
		/** Noise instrument */
		public static const INSTRUMENT_TYPE_NOISE:uint=3;
		/** Region meta instrument */
		public static const INSTRUMENT_TYPE_SPLIT:uint=17;
		/** Drumset meta instrument */
		public static const INSTRUMENT_TYPE_DRUMS:uint=16;
		
		
		public static const INSTRUMENT_RECORD_LENGTH:uint=10;

		public function Instrument() {
		}
		
		public static function makeInstrument(section:ByteArray,baseOffset:uint):Instrument {
			var type:uint=section.readUnsignedByte();
			var offset:uint=section[section.position++] | section[section.position++]<< 8 | section[section.position++] << 16;
			offset-=baseOffset;
			
			section.position=offset;
			
			return _makeInstrument(section,type);
		}
		
		public static function parseInstrumentRecord(section:ByteArray):Instrument {
			var type:uint=section.readUnsignedByte();
			section.position+=1;
			return _makeInstrument(section,type);
		}
		
		
		private static function _makeInstrument(section:ByteArray,type:uint):Instrument {
			
			var instrument:Instrument;
			
			switch(type) {
				case INSTRUMENT_TYPE_NULL:
					section.position+=INSTRUMENT_RECORD_LENGTH;
					return null;
				break;
				
				case INSTRUMENT_TYPE_PCM:
					instrument=new PCMInstrument();
				break;
				case INSTRUMENT_TYPE_PULSE:
					instrument=new PulseInstrument();
				break;
				case INSTRUMENT_TYPE_NOISE:
					instrument=new NoiseInstrument();
				break;
				
				case INSTRUMENT_TYPE_DRUMS:
					instrument=new DrumInstrument();
				break;
				
				case INSTRUMENT_TYPE_SPLIT:
					instrument=new SplitInstrument();
				break;
				
				default:
					return null;
				break;
			}
			
			instrument.parse(section);
			
			return instrument;
		}
		
		public function parse(section:ByteArray):void { throw new Error("Unimplemented instrument parser!"); }
		
		public function get drumset():Boolean { return false; }
		
		public function toXML():XML {
			var o:XML=<instrument 
				instrumentType={instrumentTypeAsString(instrumentType)}
			/>;
				
			return o;
		}
		
		public function get instrumentType():uint { throw new Error("Unimplemented!"); }
		
		public static function instrumentTypeAsString(type:uint):String {
			if(type==INSTRUMENT_TYPE_NULL) return "NULL";
			if(type==INSTRUMENT_TYPE_PCM) return "PCM";
			if(type==INSTRUMENT_TYPE_PULSE) return "Pulse";
			if(type==INSTRUMENT_TYPE_NOISE) return "Noise";
			if(type==INSTRUMENT_TYPE_SPLIT) return "Split";
			if(type==INSTRUMENT_TYPE_DRUMS) return "Drums";
			return "INVALID";
		}

	}
	
}
