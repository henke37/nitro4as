﻿package Nitro.SDAT {
	
	/** An instrument that can be used to play a melody */
	
	public class Instrument {

		public var regions:Vector.<InstrumentRegion>;
		
		//these constants must not be changed, they are used as array indexes
		/** Sample channel */
		public static const NOTETYPE_PCM:uint=0;
		/** Rectangle wave channel */
		public static const NOTETYPE_PULSE:uint=1;
		/** Noise channel */
		public static const NOTETYPE_NOISE:uint=2;
		
		public var noteType:uint;

		public function Instrument() {
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

	}
	
}
