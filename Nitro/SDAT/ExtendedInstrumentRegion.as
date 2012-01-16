package Nitro.SDAT {
	import flash.utils.ByteArray;
	
	/** A region in an instrument that is split into multiple regions */
	
	public class ExtendedInstrumentRegion extends InstrumentRegion {
		
		public var lowEnd:uint;//inclusive
		public var highEnd:uint;//exclusive

		public function ExtendedInstrumentRegion() {
			
		}
		
		public override function matchesNote(n:uint):Boolean {
			return n >= lowEnd && n <=highEnd;
		}

	}
	
}
