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
				
				var instrument:Instrument=Instrument.makeInstrument(section,baseOffset);
				
				if(instrument) {
					++realInstruments;
				}

				instruments[i]=instrument;
			}
			instruments.fixed=true;
			//trace(numInstruments,realInstruments);
		}

	}
	
}
