package Nitro.SDAT.InfoRecords {
	
	public class GroupInfoSubRecord {
		
		public var type:uint;
		public var id:uint;
		
		public static const SEQ:uint=0x0700;
		public static const SEQARC:uint=0x0803;
		public static const BANK:uint=0x0601;
		public static const WAVEARC:uint=0x0402;
		
		public static const typeMap:Object={
			0x0700: "SEQ",
			0x0803: "SEQARC",
			0x0601: "BANK",
			0x0402: "WAVEARC"
		}

		public function GroupInfoSubRecord(type:uint,id:uint) {
			this.type=type;
			this.id=id;
		}
		
		public function toXML():XML {
			return <groupElement type={type} id={id} />;
		}
		
		public function get typeString():String {
			if(type in typeMap) return typeMap[type];
			return "UNKNOWN";
		}

	}
	
}
