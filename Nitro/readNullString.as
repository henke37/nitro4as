package Nitro {
	
	import flash.utils.*;
	
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
