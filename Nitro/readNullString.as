package Nitro {
	
	import flash.utils.*;
	
	/** Reads a null terminated, UTF-8 encoded, string
	@param data The ByteArray to read from
	@param pos The position in the ByteArray where to begin reading
	@return The read String*/
	public function readNullString(data:ByteArray,pos:uint):String {
		data.position=pos;
		var len:uint=0;
		do {
			var byte:uint=data.readUnsignedByte();
			len++;
		} while(byte!=0);
		data.position=pos;
		return data.readUTFBytes(len);
	}
	
}
