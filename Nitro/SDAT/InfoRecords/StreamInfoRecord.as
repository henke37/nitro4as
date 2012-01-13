package Nitro.SDAT.InfoRecords {
	
	public class StreamInfoRecord extends BaseInfoRecord {
		
		/** The playback volume */
		public var vol:uint;
		
		public var pri:uint;
		public var ply:uint;

		public function StreamInfoRecord() {
			// constructor code
		}
		
		public function toString():String {
			return "[StreamInfoRecord fatId="+fatId+" vol="+vol+" pri="+pri+" ply="+ply+"]";
		}

	}
	
}
