package Nitro.SDAT.SequenceEvents {
	
	public class NoteEvent extends SequenceEvent {

		public var note:uint;
		public var velocity:uint;
		public var duration:uint;

		public function NoteEvent(note:uint,velocity:uint,duration:uint) {
			
			if(duration==0) throw new RangeError("duration can't be zero!");
			
			this.note=note;
			this.velocity=velocity;
			this.duration=duration;
		}
		
		public function toString():String {
			return "[NoteEvent note="+note+" vel="+velocity+" dur="+duration+"]";
		}

	}
	
}
