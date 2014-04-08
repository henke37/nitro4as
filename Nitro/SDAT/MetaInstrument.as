package Nitro.SDAT {
	
	public class MetaInstrument extends Instrument {
		public var regions:Vector.<InstrumentRegion>;

		public function MetaInstrument() {
			regions=new Vector.<InstrumentRegion>();
		}
		
		public override function leafInstrumentForNote(note:uint):LeafInstrumentBase {
			var region:InstrumentRegion=regionForNote(note);
			
			if(!region) return null;
			
			return LeafInstrumentBase(region.subInstrument);
		}
		
		public function regionForNote(note:uint):InstrumentRegion {
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
