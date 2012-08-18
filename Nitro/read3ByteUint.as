package Nitro {
	import flash.utils.*;
	
	/** Reads a 3 octets long little endinan encoded unsigned integer
	@param data The ByteArray to read from
	@return The read integer*/
	public function read3ByteUint(data:ByteArray):uint {
		var o:uint;
		
		o=data.readUnsignedByte();
		o|=data.readUnsignedByte() << 8;
		o|=data.readUnsignedByte() << 16;
		
		return o;
	}
}