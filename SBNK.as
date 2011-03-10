package  {
	
	import flash.utils.*;
	
	//use namespace strmInternal;
	
	public class SBNK {

		private var sdat:ByteArray;
		private var type:String;

		public function SBNK(strmPos:uint,_sdat:ByteArray) {
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=strmPos;
			type=sdat.readUTFBytes(4);
			if(type!="SBNK") {
				throw new ArgumentError("Invalid SBNK block, wrong type id");
			}
			
		}

	}
	
}
