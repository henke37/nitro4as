package Nitro.FileSystem {
	
	/** A single overlay. */
	
	public class Overlay {
		/** The numerical id of the overlay. */
		public var id:uint;
	
		/** Where to load the overlay in memory */
		public var ramAddress:uint;
		/** The size of the overlay in ram */
		public var ramSize:uint;
		public var bssSize:uint;
		public var bssStart:uint;
		public var bssStop:uint;
		
		/** The file id where the overlay content is actually stored. */
		public var fileId:uint;
		/** The size of the overlay data. */
		public var size:uint;
		/** If the overlay is compressed or not */
		public var compressed:Boolean;

		public function Overlay() {
			// constructor code
		}

	}
	
}
