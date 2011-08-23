package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.*;
	
	use namespace sequenceInternal;
	
	public class SSEQ extends SubFile {
				
		sequenceInternal var tracks:Vector.<SequenceTrack>;

		public function SSEQ() {
			
		}
		
		public override function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="SSEQ") {
				throw new ArgumentError("Invalid SSEQ block, wrong type id");
			}
			
			var section:ByteArray=sections.open("DATA");			
			section.endian=Endian.LITTLE_ENDIAN;
			
			//This has to be one of the most complicated things to do "right", yet simple to do "wrong".
			var offset:uint=section.readUnsignedInt();
			offset-=sections.getDataOffsetForId("DATA");
			var sequenceData:ByteArray=new ByteArray();
			sequenceData.writeBytes(section,offset);
			sequenceData.position=0;
			sequenceData.endian=Endian.LITTLE_ENDIAN;
			
			tracks=SequenceDataParser.parse(sequenceData);
		}

	}
	
}
