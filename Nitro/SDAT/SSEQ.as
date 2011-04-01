package SDAT {
	
	import flash.utils.*;
	
	use namespace sequenceInternal;
	
	public class SSEQ {
		
		private var sdat:ByteArray;
		
		sequenceInternal var tracks;

		public function SSEQ(sseqPos:uint,_sdat:ByteArray) {
			
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=sseqPos;
			
			var type:String
			
			type=sdat.readUTFBytes(4);
			if(type!="SSEQ") {
				throw new ArgumentError("Invalid SSEQ block, wrong type id");
			}
			
			sdat.position=sseqPos+16;
			type=sdat.readUTFBytes(4);
			if(type!="DATA") {
				throw new ArgumentError("Invalid SSEQ block, wrong head id " + type);
			}
			
			var offset:uint;
			
			sdat.position=sseqPos+24;
			offset=sdat.readUnsignedInt();
			offset+=sseqPos;
			
			tracks=SequenceDataParser.parse(sdat,offset);
		}

	}
	
}
