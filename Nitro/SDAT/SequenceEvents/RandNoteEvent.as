package Nitro.SDAT.SequenceEvents {
	
	public class RandNoteEvent extends SequenceEvent {

		public var note:uint;
		public var velocity:uint;
		public var minDuration:uint;
		public var maxDuration:uint;

		public function RandNoteEvent(note:uint,velocity:uint,minDuration:uint,maxDuration:uint) {
			
			this.note=note;
			this.velocity=velocity;
			this.minDuration=minDuration;
			this.maxDuration=maxDuration;
		}
		
		public function toString():String {
			return "[RandNoteEvent note="+note+" vel="+velocity+" dur="+minDuration+"/"+maxDuration+"]";
		}

	}
	
}
