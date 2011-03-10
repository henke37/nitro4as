package  {
	
	import flash.utils.*;
	
	//use namespace strmInternal;
	
	public class SWAV {

		private var sdat:ByteArray;
		private var type:String;
		
		public var wave:Wave;

		public function SWAV(swavPos:uint,_sdat:ByteArray) {
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=swavPos;
			type=sdat.readUTFBytes(4);
			if(type!="SWAV") {
				throw new ArgumentError("Invalid SWAV block, wrong type id");
			}
			
			sdat.position=swavPos+16;
			var headType:String=sdat.readUTFBytes(4);
			if(headType!="DATA") {
				throw new ArgumentError("Invalid SWAV block, wrong head id " + headType);
			}
			
			wave=new Wave(swavPos+24,_sdat);
			
		}

	}
	
}
