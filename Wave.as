package  {
	
	import flash.utils.*;
	
	public class Wave {
		
		public var encoding:uint;
		
		public static const PCM8:uint=0;
		public static const PCM16:uint=1;
		public static const ADPCM:uint=2;
		public static const GEN:uint=3;
		
		public var loops:Boolean;
		public var loopStart:uint;
		public var loopLength:uint;
		
		public var samplerate:uint;
		
		public var duration:uint;
		
		public var sdat:ByteArray;
		public var dataPos:uint;

		public function Wave(wavePos:uint,_sdat:ByteArray) {
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
			loopLength=sdat.readUnsignedInt();
			
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

	}
	
}
