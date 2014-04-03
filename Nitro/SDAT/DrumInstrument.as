package Nitro.SDAT {
	import flash.utils.*;
	
	public class DrumInstrument extends MetaInstrument {

		public function DrumInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray,offset:uint):void {
			section.position=offset;
			
			var low:uint=section.readUnsignedByte();
			var high:uint=section.readUnsignedByte();
			
			if(high<low) {
				throw new ArgumentError("Invalid range, high("+high+") is lower than low("+low+")!");
			}
			
			var range:uint=high-low+1;
			
			regions.length=range;
			regions.fixed=true;
			
			for(var i:uint;i<range;++i) {
				//base offset+lh bytes+indexed positon+skipping first two bytes of each record
				section.position=offset+2+i*12+2;
				
				var region:InstrumentRegion=new InstrumentRegion();
				region.parse(section,0);
				
				region.highEnd=region.lowEnd=i+low;
				
				regions[i]=region;
			}
			
			//trace(range);
		}
		
		public override function get drumset():Boolean { return true; }

	}
	
}
