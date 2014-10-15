package Nitro.WildMagic {
	
	import flash.utils.*;
	
	
	public class WMPF {
		
		/** The palette data, in RGB 555 format. */
		public var colors:Vector.<uint>;

		public function WMPF() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			var sig:String=data.readUTFBytes(29);
			if(sig!="Wild Magic Palette File 1.00") throw new ArgumentError("Bad signature!");

			data.endian=Endian.LITTLE_ENDIAN;
			
			var type:uint=data.readUnsignedInt();
			
			var colorCount:uint=data.readUnsignedInt();
			
			colors=new Vector.<uint>(colorCount,true);
			for(var colorId:uint=0;colorId<colorCount;++colorId) {
				colors[colorId]=data.readUnsignedShort();
			}
		}

	}
	
}
