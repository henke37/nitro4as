package Nitro.Apollo {
	import flash.utils.*;
	
	public class PAC {
		
		private var pac:ByteArray;
		
		public var fileCount:uint;

		public function PAC() {
			
		}
		
		/** Loads the archive from a ByteArray
		@param _pac The ByteArray to load from */
		public function parse(_pac:ByteArray):void {
			
			if(!_pac) throw new ArgumentError("pac must be a real bytearray");
			
			pac=_pac;
			
			pac.endian=Endian.LITTLE_ENDIAN;
			
			fileCount=pac.readUnsignedInt();
		}
		
		/** Opens a file with a given id
		@param id The id of the file to open
		@return A new ByteArray holding the contents of the file*/
		public function openFile(fid:uint):ByteArray {
			pac.position=4+8*fid;
			var offset:uint=pac.readUnsignedInt();
			var size:uint=pac.readUnsignedInt();
			
			var out:ByteArray=new ByteArray();
			
			pac.position=offset;
			
			pac.readBytes(out,0,size);
			
			return out;
		}

	}
	
}
