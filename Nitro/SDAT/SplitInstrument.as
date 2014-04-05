package Nitro.SDAT {
	import flash.utils.*;
	
	public class SplitInstrument extends MetaInstrument {

		public function SplitInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray):void {
			var i:uint;
			var startPosition:uint=section.position;
			var regionEnds:Vector.<uint>=new Vector.<uint>();
			
			for(i=0;i<8;++i) {
				var regionEnd:uint=section.readUnsignedByte();
				
				if(!regionEnd) break;
				regionEnds.push(regionEnd);
			}
			section.position=startPosition+8;
			
			regions.length=regionEnds.length;
			regions.fixed=true;
			
			var startPos:uint=0;
			for(i=0;i<regionEnds.length;++i) {
				var region:InstrumentRegion=new InstrumentRegion();
				region.parse(section);
				region.lowEnd=startPos;
				region.highEnd=regionEnds[i];
				
				startPos=regionEnds[i]+1;
				
				regions[i]=region;
			}
		}
		
		public override function get instrumentType():uint { return INSTRUMENT_TYPE_SPLIT; }

	}
	
}
