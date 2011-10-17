package Nitro.SDAT {
	
	import flash.utils.*;
	
	/** A single sound clip */
	public class Wave {
		
		/** The encoding used for the samples */
		public var encoding:uint;
		
		/** 8 bit encoded PCM */
		public static const PCM8:uint=0;
		/** 16 bit encoded PCM */
		public static const PCM16:uint=1;
		/** ADPCM encoded */
		public static const ADPCM:uint=2;
		/** Pulsegenerated */
		public static const GEN:uint=3;
		
		/** If the sample loops or not*/
		public var loops:Boolean;
		/** The start position of the looping part, measured in samples*/
		public var loopStart:uint;
		/** The length of the looping part*/
		public var nonLoopLength:uint;
		
		/** The samplerate of the sound, measured in Hz*/
		public var samplerate:uint;
		
		public var duration:uint;
		
		public var sdat:ByteArray;
		public var dataPos:uint;

		public function Wave() {
			
		}
		
		public function parse(wavePos:uint,_sdat:ByteArray):void {
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			
			sdat.position=wavePos;
			encoding=sdat.readByte();
			loops=sdat.readBoolean();
			samplerate=sdat.readUnsignedShort();
			duration=sdat.readUnsignedShort();
			loopStart=sdat.readUnsignedShort();
			nonLoopLength=sdat.readUnsignedInt();
			
			if(encoding==PCM8) {
				loopStart*=4;
				nonLoopLength*=4;
			} else if(encoding==PCM16) {
				loopStart*=2;
				nonLoopLength*=2;
			} else if(encoding==ADPCM) {
				loopStart-=4;
				loopStart*=8;
				nonLoopLength*=8;
			} else {
				throw new ArgumentError("Invalid encoding type! "+encoding);
			}
			
			dataPos=wavePos+12;
		}
		
		public static function encodingAsString(encoding:uint):String {
			switch(encoding) {
				case PCM8: return "PCM8";
				case PCM16: return "PCM16";
				case ADPCM: return "ADPCM";
				default: throw ArgumentError("Invalid encoding");
			}
		}
		
		public function toString():String {
			var o:String="[Wave ";
			o+=duration.toString()+" ";
			if(loops) {
				o+="loops: "+loopStart.toString()+"-"+nonLoopLength.toString()+" ";
			}
			o+=encodingAsString(encoding)+"]";
			
			return o;
		}

	}
	
}
