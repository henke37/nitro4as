package Nitro.FileSystem {
	import flash.utils.*;
	
	/** Reader for utlity.bin files. */
	
	public class UtilityBin {
		
		/** The contained filesystem */
		public var fileSystem:FileSystem;

		public function UtilityBin() {
			// constructor code
		}
		
		/** Loads from a ByteArray
		@param data The ByteArray to load from */
		public function parse(data:ByteArray):void {
			if(!data) throw new ArgumentError("Data can't be null!");
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			var fntOffset:uint=data.readUnsignedInt();
			var fntSize:uint=data.readUnsignedInt();
			var fatOffset:uint=data.readUnsignedInt();
			var fatSize:uint=data.readUnsignedInt();
			
			fileSystem= new FileSystem();
			fileSystem.parse(data,fntOffset,fntSize,fatOffset,fatSize);
		}

	}
	
}
