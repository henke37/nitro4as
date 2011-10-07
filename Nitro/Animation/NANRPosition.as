package Nitro.Animation {
	import flash.geom.Matrix;

	/** The position of a cell in a NANR animation.
	
	<p>Can be reused for multiple frames in an animation.</p> */

	public class NANRPosition {
		/** The position to display the cell at. */
		public var transform:Matrix;
		/** The cell to display. */
		public var cellIndex:uint;
	}

}