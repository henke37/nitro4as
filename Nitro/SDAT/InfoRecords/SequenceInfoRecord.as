package Nitro.SDAT.InfoRecords {
	
	public class SequenceInfoRecord extends BaseInfoRecord {
		
		/** The sound bank to use for playing the sequence */
		public var bankId:uint;
		
		/** The playback volume */
		public var vol:uint;
		
		/** The channel preasure */
		public var cpr:uint;
		
		/** The polyphonic preasure */
		public var ppr:uint;
		
		public var ply:uint;

		public function SequenceInfoRecord() {
			// constructor code
		}
		
		public function toString():String {
			return "[SequenceInfoRecord fatId="+fatId+" bankId="+bankId+" vol="+vol+" cpr="+cpr+" ppr="+ppr+" ply="+ply+"]";
		}

	}
	
}
