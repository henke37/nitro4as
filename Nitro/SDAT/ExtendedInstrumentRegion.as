package SDAT {
	import flash.utils.ByteArray;
	
	public class ExtendedInstrumentRegion extends InstrumentRegion {
		
		public var lowEnd:uint;//inclusive
		public var highEnd:uint;//exclusive

		public function ExtendedInstrumentRegion(sdat:ByteArray,low:uint,high:uint) {
			super(sdat);
			lowEnd=low;
			highEnd=high;
		}

	}
	
}
