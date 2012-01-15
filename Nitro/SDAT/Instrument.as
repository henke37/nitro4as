package Nitro.SDAT {
	
	/** An instrument that can be used to play a melody */
	
	public class Instrument {

		public var regions:Vector.<InstrumentRegion>;
		
		public static const NOTETYPE_PCM:uint=0;
		public static const NOTETYPE_PULSE:uint=1;
		public static const NOTETYPE_NOISE:uint=2;
		
		public var noteType:uint;

		public function Instrument() {
			regions=new Vector.<InstrumentRegion>();
		}

	}
	
}
