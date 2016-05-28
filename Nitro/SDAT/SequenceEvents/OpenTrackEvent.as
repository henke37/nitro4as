package Nitro.SDAT.SequenceEvents {
	
	public class OpenTrackEvent extends JumpEvent {
		
		public var track:uint;

		public function OpenTrackEvent(_target:uint,track:uint) {
			super(_target,JumpEvent.JT_TRACK);
			this.track=track;
		}

	}
	
}
