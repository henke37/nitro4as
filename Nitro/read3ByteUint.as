package Nitro {
	import flash.utils.*;
	
	public function read3ByteUint(data:ByteArray):uint {
		var o:uint;
		
		o=data.readUnsignedByte();
		o|=data.readUnsignedByte() << 8;
		o|=data.readUnsignedByte() << 16;
		
		return o;
	}
}