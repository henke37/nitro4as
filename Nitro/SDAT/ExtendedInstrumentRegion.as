package Nitro.SDAT {
	import flash.utils.ByteArray;
	
	public class ExtendedInstrumentRegion extends InstrumentRegion {
		
		public var lowEnd:uint;//inclusive
		public var highEnd:uint;//exclusive

		public function ExtendedInstrumentRegion() {
			
		}
		
		public function parse(sdat:ByteArray,low:uint,high:uint):void {
			super.parse(sdat);
			lowEnd=low;
			highEnd=high;
		}

	}
	
}
