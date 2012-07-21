﻿package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SectionedFile;
	
	/** SBNK reader
	
	<p>SBNK Files defines a set of sample based instruments</p>*/
	
	public class SBNK extends SubFile {

		/** The instruments defined in the file */
		public var instruments:Vector.<Instrument>;

		public function SBNK() {
			
		}
		
		/** Loads definitons from a ByteArray
		@param data The ByteArray to load data from*/
		public override function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);

			if(sections.id!="SBNK") {
				throw new ArgumentError("Invalid SBNK block, wrong type id "+sections.id);
			}
			
			readDATA(sections.open("DATA"),sections.getDataOffsetForId("DATA"));
			
		}
		
		private function readDATA(section:ByteArray,baseOffset:uint):void {
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			const padding:uint=8*4;
			section.position=padding;
			var numInstruments:uint=section.readUnsignedInt();
			
			instruments=new Vector.<Instrument>();
			instruments.length=numInstruments
			instruments.fixed=true;
			
			var realInstruments:uint;
			for(var i:uint;i<numInstruments;++i) {
				section.position=padding+4+i*4;
				var type:uint=section.readUnsignedByte();
				var offset:uint=section.readUnsignedShort();
				offset-=baseOffset;
				var instrument:Instrument=makeInstrument(section,type,offset);
				
				if(instrument) {
					++realInstruments;
				}

				instruments[i]=instrument;
			}
			instruments.fixed=true;
			//trace(numInstruments,realInstruments);
		}
		
		private function makeInstrument(section:ByteArray,type:uint,offset:uint):Instrument {
			
			var instrument:Instrument;
			
			switch(type) {
				case 0:
					return null;
				break;
				
				case 1:
				case 2:
				case 3:
					instrument=parseSimpleInstrument(section,offset);
					instrument.noteType=type-1;
				break;
				
				case 16:
					instrument=parseDrumInstrument(section,offset);
				break;
				
				case 17:
					instrument=parseSplitInstrument(section,offset);
				break;
				
				default:
					return null;
				break;
			}
			
			return instrument;
		}
		
		private function parseSimpleInstrument(section:ByteArray,offset:uint):Instrument {
			var instrument:Instrument=new Instrument();
			instrument.regions.length=1;
			instrument.regions.fixed=true;
			
			section.position=offset;
			var region:InstrumentRegion=new InstrumentRegion();
			region.parse(section);
			
			region.lowEnd=0;
			region.highEnd=127;
			
			instrument.regions[0]=region;
			
			return instrument;
		}
		
		private function parseDrumInstrument(section:ByteArray,offset:uint):Instrument {
			var instrument:Instrument=new Instrument();
			instrument.drumset=true;
			section.position=offset;
			
			var low:uint=section.readUnsignedByte();
			var high:uint=section.readUnsignedByte();
			
			if(high<low) {
				throw new ArgumentError("Invalid range, high("+high+") is lower than low("+low+")!");
			}
			
			var range:uint=high-low+1;
			
			instrument.regions.length=range;
			instrument.regions.fixed=true;
			
			for(var i:uint;i<range;++i) {
				//base offset+lh bytes+indexed positon+skipping first two bytes of each record
				section.position=offset+2+i*12+2;
				
				var region:InstrumentRegion=new InstrumentRegion();
				region.parse(section);
				
				region.highEnd=region.lowEnd=i+low;
				
				instrument.regions[i]=region;
			}
			
			//trace(range);
			
			return instrument;
		}
		
		private function parseSplitInstrument(section:ByteArray,offset:uint):Instrument {
			var regionEnds:Vector.<uint>=new Vector.<uint>();
			section.position=offset;
			
			for(;;) {
				var regionEnd:uint=section.readUnsignedByte();
				
				if(!regionEnd) break;
				regionEnds.push(regionEnd);
			}
			
			var instrument:Instrument=new Instrument();
			
			instrument.regions.length=regionEnds.length;
			instrument.regions.fixed=true;
			
			var startPos:uint=0;
			for(var i:uint=0;i<regionEnds.length;++i) {
				//record length*record index+base offset+skipping the region end data
				section.position=i*12+offset+8;
				var region:InstrumentRegion=new InstrumentRegion();
				region.parse(section);
				region.lowEnd=startPos;
				region.highEnd=regionEnds[i];
				
				startPos=regionEnds[i]+1;
				
				instrument.regions[i]=region;
			}
			
			return null;
		}

	}
	
}
