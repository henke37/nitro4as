package Nitro.SDAT {
	import flash.utils.*;
	
	public class DrumInstrument extends MetaInstrument {

		public function DrumInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray):void {
			var startPosition:uint=section.position;
			
			var low:uint=section.readUnsignedByte();
			var high:uint=section.readUnsignedByte();
			
			const drumHeaderLen:uint=2;
			
			if(high<low) {
				throw new ArgumentError("Invalid range, high("+high+") is lower than low("+low+")!");
			}
			
			var range:uint=high-low+1;
			
			regions.length=range;
			regions.fixed=true;
			
			for(var i:uint;i<range;++i) {
				//section.position=startPosition+drumHeaderLen+i*INSTRUMENT_RECORD_LENGTH;
				
				var region:InstrumentRegion=new InstrumentRegion();
				region.parse(section);
				
				region.highEnd=region.lowEnd=i+low;
				
				regions[i]=region;
			}
			
			//trace(range);
		}
		
		public override function get drumset():Boolean { return true; }
		
		
		public override function get instrumentType():uint { return INSTRUMENT_TYPE_DRUMS; }

	}
	
}
