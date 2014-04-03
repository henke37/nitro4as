package Nitro.SDAT {
	import flash.utils.ByteArray;
	
	public class PCMInstrument extends LeafInstrumentBase {
		
		
		/** The wave in the archive to use for this instrument */
		public var swav:uint;
		/** The wave archive where in to find the sample for this instrument */
		public var swar:uint;// the swar used. Cross-reference to "1.3.2 Info Block - Entry, Record 2 BANK"

		public function PCMInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray,offset:uint):void {
			swav=section.readUnsignedShort();
			swar=section.readUnsignedShort();
			
			super.parse(section,offset);
		}
		
		public override function toXML():XML {
			var o:XML=super.toXML();
			o.@swav=swav;
			o.@swar=swar;
			return o;
		}

	}
	
}
