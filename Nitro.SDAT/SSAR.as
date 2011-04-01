package SDAT {
	
	import flash.utils.*;
	
	public class SSAR {
		
		private var sdat:ByteArray;
		
		sequenceInternal var offset:uint;

		public function SSAR(ssarPos:uint,_sdat:ByteArray) {
			
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=ssarPos;
			
			var type:String
			
			type=sdat.readUTFBytes(4);
			if(type!="SSAR") {
				throw new ArgumentError("Invalid SSAR block, wrong type id");
			}
			
			sdat.position=ssarPos+16;
			type=sdat.readUTFBytes(4);
			if(type!="DATA") {
				throw new ArgumentError("Invalid SSAR block, wrong head id " + type);
			}
			
			trace(ssarPos);
		}

	}
	
}
