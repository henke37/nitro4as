package Nitro.SDAT {
	
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
			
			readDATA(sections.open("DATA"));
			
		}
		
		private function readDATA(section:ByteArray):void {
			const padding:uint=8*4;
			section.position=padding;
			var numInstruments:uint=section.readUnsignedInt();
			
			return;
			
			instruments=new Vector.<Instrument>(numInstruments,true);
			
			var realInstruments:uint;
			for(var i:uint;i<numInstruments;++i) {
				var type:uint=section.readUnsignedByte();
				var offset:uint=section.readUnsignedShort();
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
			switch(type) {
				case 0:
					return null;
				break;
				
				case 1:
				case 2:
				case 3:
					return parseSimpleInstrument(section,offset);
				break;
				
				case 16:
					return parseDrumInstrument(section,offset);
				break;
				
				case 17:
					return new Instrument();
				break;
				
				default:
					return null;
				break;
			}
		}
		
		private function parseSimpleInstrument(section:ByteArray,offset:uint):Instrument {
			var instrument:Instrument=new Instrument();
			section.position=offset;
			var region:InstrumentRegion=new InstrumentRegion();
			region.parse(section);
			instrument.definitions.push(region);
			return instrument;
		}
		
		private function parseDrumInstrument(section:ByteArray,offset:uint):Instrument {
			var instrument:Instrument=new Instrument();
			section.position=offset;
			
			var low:uint=section.readUnsignedByte();
			var high:uint=section.readUnsignedByte();
			
			if(high<low) {
				throw new ArgumentError("Invalid range, high("+high+") is lower than low("+low+")!");
			}
			
			var range:uint=high-low;
			
			for(var i:uint;i<range;++i) {
				section.position=offset+2+i*12+2;
				var region:InstrumentRegion=new InstrumentRegion();
				region.parse(section);
				instrument.definitions.push(region);
			}
			
			//trace(range);
			
			return instrument;
		}

	}
	
}
