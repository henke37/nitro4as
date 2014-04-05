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
			if(subInstrument is MetaInstrument) throw new ArgumentError("Can't have meta instruments inside another meta instrument!");
		}
		
		public function matchesNote(n:uint):Boolean {
			return n >= lowEnd && n <=highEnd;
		}
		
		public function toXML():XML {
			var o:XML=<instrumentRegion
				lowEnd={lowEnd}
				highEnd={highEnd}
			/>;
			
			if(subInstrument) {
				o.appendChild(subInstrument.toXML());
			} else {
				o.appendChild(<NULL />);
			}
			
			return o;
		}

	}
	
}
