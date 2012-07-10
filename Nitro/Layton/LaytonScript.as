package Nitro.Layton {
	
	import flash.utils.*;
	
	public class LaytonScript {

		public function LaytonScript() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			var type:String=data.readUTFBytes(4);
			if(type!="LSCR") throw new ArgumentError("Type has to be LSCR but was "+type);
		}

	}
	
}
