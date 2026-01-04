package Nitro.SDAT.SequenceEvents {
	
	public class VarNoteEvent extends SequenceEvent {

		public var note:uint;
		public var velocity:uint;
		public var durationVar:uint;

		public function VarNoteEvent(note:uint,velocity:uint,durationVar:uint) {
			
			this.note=note;
			this.velocity=velocity;
			this.durationVar=durationVar;
		}
		
		public function toString():String {
			return "[NoteEvent note="+note+" vel="+velocity+" dur=var("+durationVar+")]";
		}

	}
	
}
