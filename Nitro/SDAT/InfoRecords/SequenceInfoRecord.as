package Nitro.SDAT.InfoRecords {
	
	public class SequenceInfoRecord extends BaseInfoRecord {
		
		/** The sound bank to use for playing the sequence */
		public var bankId:uint;
		
		/** The playback volume */
		public var vol:uint;
		
		/** The channel preasure */
		public var channelPressure:uint;
		
		/** The polyphonic preasure */
		public var polyPressure:uint;
		
		/** The player to use to play this sequence */
		public var player:uint;

		public function SequenceInfoRecord() {
			// constructor code
		}
		
		public function toString():String {
			return "[SequenceInfoRecord fatId="+fatId+" bankId="+bankId+" vol="+vol+" cpr="+channelPressure+" ppr="+polyPressure+" ply="+player+"]";
		}

	}
	
}
