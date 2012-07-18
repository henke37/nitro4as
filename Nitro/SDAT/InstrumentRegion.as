﻿package Nitro.SDAT {
	import flash.utils.ByteArray;
	
	/** A region in an instrument
	
	<p>A region defins how to play a sample</p>*/
	
	public class InstrumentRegion {
		
		/** The wave in the archive to use for this region */
		public var swav:uint;
		/** The wave archive where in to find the sample for this region */
		public var swar:uint;// the swar used. NB. cross-reference to "1.3.2 Info Block - Entry, Record 2 BANK"
		
		public var baseNote:uint;
		
		public var lowEnd:uint;//inclusive
		public var highEnd:uint;//exclusive
		
		
		public var attack:uint;// 0..127
		public var decay:uint;
		public var sustain:uint;
		public var release:uint;
		
		public var pan:uint// 0..127, 64 = middle

		public function InstrumentRegion() {
			
		}
		
		public function parse(sdat:ByteArray):void {
			swav=sdat.readUnsignedShort();
			swar=sdat.readUnsignedShort();
			
			baseNote=sdat.readUnsignedByte();
			
			attack=sdat.readUnsignedByte();
			decay=sdat.readUnsignedByte();
			sustain=sdat.readUnsignedByte();
			release=sdat.readUnsignedByte();
			
			pan=sdat.readUnsignedByte();	

		}
		
		public function matchesNote(n:uint):Boolean {
			return n >= lowEnd && n <=highEnd;
		}
		
		public function toXML():XML {
			var o:XML=<instrumentRegion
				swav={swav}
				swar={swar}
				baseNote={baseNote}
				lowEnd={lowEnd}
				highEnd={highEnd}
				attack={attack}
				decay={decay}
				sustain={sustain}
				release={release}
				pan={pan}
			/>;
			
			return o;
		}

	}
	
}
