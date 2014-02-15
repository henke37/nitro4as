package Nitro.SDAT.SequenceEvents {
	
	public class NoteEvent extends SequenceEvent {

		public var note:uint;
		public var velocity:uint;
		public var duration:uint;

		public function NoteEvent(note:uint,velocity:uint,duration:uint) {
			
			this.note=note;
			this.velocity=velocity;
			this.duration=duration;
		}
		
		public function get infiniteDuration():Boolean { return duration==0; }
		
		public function toString():String {
			return "[NoteEvent note="+note+" vel="+velocity+" dur="+duration+"]";
		}

	}
	
}
