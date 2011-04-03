package Nitro.SDAT {
	
	import flash.utils.*;
	
	//use namespace strmInternal;
	
	public class SBNK {

		private var sdat:ByteArray;
		
		public var instruments:Vector.<Instrument>;

		public function SBNK(bankPos:uint,_sdat:ByteArray) {
			
			var magic:String;
			
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=bankPos;
			magic=sdat.readUTFBytes(4);
			if(magic!="SBNK") {
				throw new ArgumentError("Invalid SBNK block, wrong type id "+magic);
			}
			
			sdat.position=bankPos+16;
			magic=sdat.readUTFBytes(4);
			if(magic!="DATA") {
				throw new ArgumentError("Invalid SBNK block, wrong data header id "+magic);
			}
			
			sdat.position=bankPos+16+4+4+8*4;
			var numInstruments:uint=sdat.readUnsignedInt();
			
			return;
			
			instruments=new Vector.<Instrument>(numInstruments,true);
			
			var realInstruments:uint;
			for(var i:uint;i<numInstruments;++i) {
				var type:uint=sdat.readUnsignedByte();
				var offset:uint=sdat.readUnsignedShort();
				offset+=bankPos;
				var instrument:Instrument=makeInstrument(type,offset);
				
				if(instrument) {
					++realInstruments;
				}

				instruments[i]=instrument;
			}
			instruments.fixed=true;
			//trace(numInstruments,realInstruments);
		}
		
		private function makeInstrument(type:uint,offset:uint):Instrument {
			switch(type) {
				case 0:
					return null;
				break;
				
				case 1:
				case 2:
				case 3:
					return parseSimpleInstrument(offset);
				break;
				
				case 16:
					return parseDrumInstrument(offset);
				break;
				
				case 17:
					return new Instrument();
				break;
				
				default:
					return null;
				break;
			}
		}
		
		private function parseSimpleInstrument(offset:uint):Instrument {
			var instrument:Instrument=new Instrument();
			sdat.position=offset;
			instrument.definitions.push(new InstrumentRegion(sdat));
			return instrument;
		}
		
		private function parseDrumInstrument(offset:uint):Instrument {
			var instrument:Instrument=new Instrument();
			sdat.position=offset;
			
			var low:uint=sdat.readUnsignedByte();
			var high:uint=sdat.readUnsignedByte();
			
			if(high<low) {
				throw new ArgumentError("Invalid range, high("+high+") is lower than low("+low+")!");
			}
			
			var range:uint=high-low;
			
			for(var i:uint;i<range;++i) {
				sdat.position=offset+2+i*12+2;			
				instrument.definitions.push(new InstrumentRegion(sdat));
			}
			
			//trace(range);
			
			return instrument;
		}

	}
	
}
