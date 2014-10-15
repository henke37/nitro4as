package Nitro.Animation {
	
	/** A single animation from a NANR file */
	
	public class NANRAnim {
		
		/** The frames the animation is composed of. */
		public var frames:Vector.<NANRFrame>;
		
		/** The first frame to show when looping. */
		public var loopStart:uint;
		
		/** Playback mode */
		public var playbackMethod:uint;
	}
}