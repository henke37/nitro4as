package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SectionedFile;
	import Nitro.SDAT.InfoRecords.SequenceInfoRecord;
	
	/** SSAR reader
	
	<p>SSAR files contains a set of sequences</p>*/
	
	public class SSAR extends SubFile {
		
		public var sequences:Vector.<Sequence>;
		public var sequenceInfo:Vector.<SequenceInfoRecord>;

		public function SSAR() {
			sequenceInfo=new Vector.<SequenceInfoRecord>();
			sequences=new Vector.<Sequence>();
		}
		
		/** Loads data from a ByteArray
		@param data The ByteArray to load from*/
		public override function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="SSAR") {
				throw new ArgumentError("Invalid SSAR block, wrong type id");
			}
			
			readDATA(sections.open("DATA"));
		}
		
		/** The number of sequences in the archive */
		public function get length():uint {
			return sequenceInfo.length;
		}
		
		private function readDATA(section:ByteArray):void {
			section.endian=Endian.LITTLE_ENDIAN;
			
			const dataOffset:uint=section.readUnsignedInt();
			const seqCount:uint=section.readUnsignedInt();
			
			for(var i:uint=0;i<seqCount;++i) {
				var info:SequenceInfoRecord=new SequenceInfoRecord();
				var offset:uint=section.readUnsignedInt();
				
				info.bankId=section.readUnsignedShort();
				info.vol=section.readUnsignedByte();
				info.channelPressure=section.readUnsignedByte();
				info.polyPressure=section.readUnsignedByte();
				info.player=section.readUnsignedByte();
				section.position+=2;
				
				sequenceInfo[i]=info;
			}
		}

	}
	
}
