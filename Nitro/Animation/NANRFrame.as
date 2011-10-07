package Nitro.Animation {
	
	/** A single frame in a NANR animation. */
	
	public class NANRFrame {
		
		/** How many frames to show the frame. */
		public var frameTime:uint;
		/** The position offset of the frame as well as the cell id. 
		
		<p>The position data may be reused for several frames in the animation.</p>*/
		public var position:NANRPosition;
	}
}