package Nitro.SDAT.InfoRecords {
	
	public class GroupInfoSubRecord {
		
		public var type:uint;
		public var loadFlags:uint;
		public var id:uint;
		
		public static const SEQ:uint=0x00;
		public static const SEQARC:uint=0x03;
		public static const BANK:uint=0x01;
		public static const WAVEARC:uint=0x02;
		
		public static const typeMap:Object={
			0x00: "SEQ",
			0x01: "BANK",
			0x02: "WAVEARC",
			0x03: "SEQARC"
		}

		public function GroupInfoSubRecord(type:uint,loadFlags:uint,id:uint) {
			this.type=type;
			this.loadFlags=loadFlags;
			this.id=id;
		}
		
		public function toXML():XML {
			return <groupElement type={type} loadFlags={loadFlags} id={id} />;
		}
		
		public function get typeString():String {
			if(type in typeMap) return typeMap[type];
			return "UNKNOWN";
		}

	}
	
}
