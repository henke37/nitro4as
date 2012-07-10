package Nitro.Layton {
	
	import flash.utils.*;
	
	public class LaytonImage {

		public function LaytonImage() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			var type:String=data.readUTFBytes(4);
			if(type!="LIMG") throw new ArgumentError("Type has to be LIMG but was "+type);
		}

	}
	
}
