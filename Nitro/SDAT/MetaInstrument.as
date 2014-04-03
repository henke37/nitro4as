package Nitro.SDAT {
	
	public class MetaInstrument extends Instrument {
		public var regions:Vector.<InstrumentRegion>;

		public function MetaInstrument() {
			regions=new Vector.<InstrumentRegion>();
		}
		
		public function regionForNote(note:uint):InstrumentRegion {
			if(regions.length==1) return regions[0];
			
			for each(var region:InstrumentRegion in regions) {
				if(region.matchesNote(note)) {
					return region;
				}
			}
			
			return null;
		}
		
		public override function toXML():XML {
			var o:XML=super.toXML();
			
			for each(var region:InstrumentRegion in regions) {
				o.appendChild(region.toXML());
			}
			return o;
		}

	}
	
}
