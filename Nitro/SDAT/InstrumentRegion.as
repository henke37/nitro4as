package Nitro.SDAT {
	import flash.utils.ByteArray;
	
	/** A region in an instrument
	
	<p>A region defins how to play a sample</p>*/
	
	public class InstrumentRegion {
		
		public var lowEnd:uint;//inclusive
		public var highEnd:uint;//exclusive
		
		public var subInstrument:Instrument;

		public function InstrumentRegion() {
			
		}
		
		public function parse(section:ByteArray,baseOffset:uint):void {
			subInstrument=Instrument.makeInstrument(section,baseOffset);
		}
		
		public function matchesNote(n:uint):Boolean {
			return n >= lowEnd && n <=highEnd;
		}
		
		public function toXML():XML {
			var o:XML=<instrumentRegion
				lowEnd={lowEnd}
				highEnd={highEnd}
			/>;
				
			o.appendChild(subInstrument.toXML());
			
			return o;
		}

	}
	
}
