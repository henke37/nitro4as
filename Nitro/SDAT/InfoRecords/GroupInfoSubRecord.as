package Nitro.SDAT.InfoRecords {
	
	public class GroupInfoSubRecord {
		
		public var type:uint;
		public var id:uint;

		public function GroupInfoSubRecord() {
			// constructor code
		}
		
		public function toXML():XML {
			return <groupElement type={type} id={id} />;
		}

	}
	
}
