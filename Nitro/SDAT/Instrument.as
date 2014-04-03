package Nitro.SDAT {
	import flash.utils.*;
	
	/** An instrument that can be used to play a melody */
	public class Instrument {
		
		public var instrumentType:uint;
		
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

		public function Instrument() {
		}
		
		public static function makeInstrument(section:ByteArray,baseOffset:uint):Instrument {
			var type:uint=section.readUnsignedByte();
			var offset:uint=section.readUnsignedShort();
			offset-=baseOffset;
			
			var instrument:Instrument;
			
			switch(type) {
				case 0:
					return null;
				break;
				
				case 1:
					instrument=new PCMInstrument();
				break;
				case 2:
					instrument=new PulseInstrument();
				break;
				case 3:
					instrument=new NoiseInstrument();
				break;
				
				case 16:
					instrument=new DrumInstrument();
				break;
				
				case 17:
					instrument=new SplitInstrument();
				break;
				
				default:
					return null;
				break;
			}
			
			instrument.parse(section,offset);
			
			return instrument;
		}
		
		public function parse(section:ByteArray,offset:uint):void { throw new Error("Unimplemented instrument parser!"); }
		
		public function get drumset():Boolean { return false; }
		
		public function toXML():XML {
			var o:XML=<instrument 
				instrumentType={instrumentTypeAsString(instrumentType)}
				drumset={drumset?"true":"false"}
			/>;
				
			return o;
		}
		
		public static function instrumentTypeAsString(type:uint):String {
			if(type==INSTRUMENT_TYPE_NULL) return "NULL";
			if(type==INSTRUMENT_TYPE_PCM) return "PCM";
			if(type==INSTRUMENT_TYPE_PULSE) return "Pulse";
			if(type==INSTRUMENT_TYPE_NOISE) return "Noise";
			return "INVALID";
		}

	}
	
}
