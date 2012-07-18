package Nitro.SDAT.InfoRecords {
	
	public class BankInfoRecord extends BaseInfoRecord {
		
		/** A list of the SWAR files belonging to the corresponding intstrument bank */
		public var swars:Vector.<int>;

		public function BankInfoRecord() {
			swars=new Vector.<int>();
			swars.length=4;
			swars.fixed=true;
		}
		
		public function toString():String {
			return "[BankInfoRecord fatId="+fatId+" swars="+swars+"]";
		}

	}
	
}
