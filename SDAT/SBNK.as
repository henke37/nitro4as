package SDAT {
	
	import flash.utils.*;
	
	//use namespace strmInternal;
	
	public class SBNK {

		private var sdat:ByteArray;
		
		public var instruments:Vector.<Instrument>;

		public function SBNK(bankPos:uint,_sdat:ByteArray) {
			
			var magic:String;
			
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=bankPos;
			magic=sdat.readUTFBytes(4);
			if(magic!="SBNK") {
				throw new ArgumentError("Invalid SBNK block, wrong type id "+magic);
			}
			
			sdat.position=bankPos+16;
			magic=sdat.readUTFBytes(4);
			if(magic!="DATA") {
				throw new ArgumentError("Invalid SBNK block, wrong data header id "+magic);
			}
			
			
		}

	}
	
}
