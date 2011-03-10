package  {
	
	import flash.utils.*;
	
	//use namespace strmInternal;
	
	public class SWAR {

		private var sdat:ByteArray;
		private var type:String;
		
		public var waves:Vector.<Wave>;

		public function SWAR(swarPos:uint,_sdat:ByteArray) {
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=swarPos;
			type=sdat.readUTFBytes(4);
			if(type!="SWAR") {
				throw new ArgumentError("Invalid SWAR block, wrong type id");
			}
			
			sdat.position=swarPos+16;
			var headType:String=sdat.readUTFBytes(4);
			if(headType!="DATA") {
				throw new ArgumentError("Invalid SWAR block, wrong head id " + headType);
			}
			
			sdat.position=swarPos+56;
			var count:uint=sdat.readUnsignedInt();
			
			//trace(count);
			
			waves=new Vector.<Wave>();
			
			for(var i:uint;i<count;++i) {
				sdat.position=swarPos+60+4*i;
				var pos=sdat.readUnsignedInt()+swarPos;
				var wave:Wave=new Wave(pos,_sdat);
				waves.push(wave);
			}
			
		}

	}
	
}
