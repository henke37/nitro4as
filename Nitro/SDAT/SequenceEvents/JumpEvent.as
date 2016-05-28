package Nitro.SDAT.SequenceEvents {
	
	public class JumpEvent extends SequenceEvent {
		
		public var target:uint;
		public var jumpType:uint;
		
		public static const JT_JUMP:uint=0;
		public static const JT_CALL:uint=1;
		public static const JT_TRACK:uint=2;

		public function JumpEvent(_target:uint,jumpType:uint) {
			target=_target;
			this.jumpType=jumpType;
		}
		
		public function toString():String {
			var targetStr:String=target.toString(16);
			switch(jumpType) {
				case JT_JUMP:
				return "[JumpEvent target="+targetStr+"]";
				case JT_CALL:
				return "[CallEvent target="+targetStr+"]";
				case JT_TRACK:
				return "[TrackStartEvent target="+targetStr+"]";
			}
			throw new Error("Bad jump type!");
		}

	}
	
}
