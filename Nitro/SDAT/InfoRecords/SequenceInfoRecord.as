package Nitro.SDAT.InfoRecords {
	
	public class SequenceInfoRecord extends BaseInfoRecord {
		
		/** The sound bank to use for playing the sequence */
		public var bankId:uint;
		
		/** The playback volume */
		public var vol:uint;
		
		/** The channel priority */
		public var channelPriority:uint;
		
		/** The player priority */
		public var playerPriority:uint;
		
		/** The player to use to play this sequence */
		public var player:uint;

		public function SequenceInfoRecord() {
			// constructor code
		}
		
		public function toString():String {
			return "[SequenceInfoRecord fatId="+fatId+" bankId="+bankId+" vol="+vol+" cpr="+channelPriority+" ppr="+playerPriority+" ply="+player+"]";
		}

	}
	
}
