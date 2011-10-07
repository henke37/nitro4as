package Nitro.FileSystem {
	
	/** A single overlay. */
	
	public class Overlay {
		/** The numerical id of the overlay. */
		public var id:uint;
	
		public var ramAddress:uint;
		public var ramSize:uint;
		public var bssSize:uint;
		public var bssStart:uint;
		public var bssStop:uint;
		
		/** The file id where the overlay content is actually stored. */
		public var fileId:uint;
		/** The size of the overlay data. */
		public var size:uint;
		public var compressed:Boolean;

		public function Overlay() {
			// constructor code
		}

	}
	
}
