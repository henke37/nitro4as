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
		
		/** The period of the sound, expressed as a timer value */
		public var timerLen:uint;
		
		/** The ByteArray where the audio data is stored */
		public var data:ByteArray;
		/** The position in the ByteArray where the data is stored */
		public var dataPos:uint;

		public function Wave() {
			
		}
		
		public function parse(wavePos:uint,_data:ByteArray):void {
			data=_data;
			if(!data) {
				throw new ArgumentError("data can not be null!");
			}
			
			data.endian=Endian.LITTLE_ENDIAN;
			data.position=wavePos;
			encoding=data.readByte();
			loops=data.readBoolean();
			samplerate=data.readUnsignedShort();
			timerLen=data.readUnsignedShort();
			loopStart=data.readUnsignedShort();
			nonLoopLength=data.readUnsignedInt();
			
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
		
		public function get sampleCount():uint {
			return loopStart+nonLoopLength;
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
			var o:String="[Wave len=";
			o+=sampleCount.toString()+" ";
			if(loops) {
				o+="loops: "+loopStart.toString()+"-"+nonLoopLength.toString()+" ";
			}
			o+=encodingAsString(encoding)+"]";
			
			return o;
		}
		
		public function toXML():XML {
			var o:XML=<wave
				sampleCount={sampleCount}
				encoding={encodingAsString(encoding)}
				samplerate={samplerate}
				timerLen={timerLen}
			/>;
			if(loops) {
				o.@loopStart=loopStart.toString();
				o.@nonLoopLength=nonLoopLength.toString();
			}
			return o;
		}

	}
	
}
