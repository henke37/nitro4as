package Nitro.SDAT.InfoRecords {
	
	public class BankInfoRecord extends BaseInfoRecord {
		
		public var swars:Vector.<uint>;

		public function BankInfoRecord() {
			swars=new Vector.<uint>();
			swars.length=4;
			swars.fixed=true;
		}
		
		public function toString():String {
			return "[BankInfoRecord fatId="+fatId+" swars="+swars+"]";
		}

	}
	
}
