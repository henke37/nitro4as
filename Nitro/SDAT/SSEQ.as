﻿package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.*;
	
	use namespace sequenceInternal;
	
	/** Reader for SSEQ files
	
	<p>SSEQ files contains a sequence</p>*/
	
	public class SSEQ extends SubFile {
		
		/** The stored sequence */
		public var sequence:Sequence;

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
			
			var parser:SequenceDataParser=new SequenceDataParser();
			
			sequence=parser.parse(sequenceData);
		}

	}
	
}
