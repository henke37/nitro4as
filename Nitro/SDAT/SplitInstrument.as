package Nitro.SDAT {
	import flash.utils.*;
	
	public class SplitInstrument extends MetaInstrument {

		public function SplitInstrument() {
			// constructor code
		}
		
		public override function parse(section:ByteArray,offset:uint):void {
			var regionEnds:Vector.<uint>=new Vector.<uint>();
			section.position=offset;
			
			for(;;) {
				var regionEnd:uint=section.readUnsignedByte();
				
				if(!regionEnd) break;
				regionEnds.push(regionEnd);
			}
			
			regions.length=regionEnds.length;
			regions.fixed=true;
			
			var startPos:uint=0;
			for(var i:uint=0;i<regionEnds.length;++i) {
				//record length*record index+base offset+skipping the region end data
				section.position=i*12+offset+8;
				var region:InstrumentRegion=new InstrumentRegion();
				region.parse(section,0);
				region.lowEnd=startPos;
				region.highEnd=regionEnds[i];
				
				startPos=regionEnds[i]+1;
				
				regions[i]=region;
			}
		}

	}
	
}
