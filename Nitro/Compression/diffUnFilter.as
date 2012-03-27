package Nitro.Compression {
	
	import flash.utils.*;
	
	public function diffUnFilter(inBuff:ByteArray,bits:uint=8,len:uint=0):void {
		
		const valLen:uint=bits/8;
		
		if(bits!=8 && bits!=16) throw new ArgumentError("Bits must be either 8 or 16!");
		if(len==0) {
			len=inBuff.bytesAvailable;
		} else if(len>inBuff.bytesAvailable) {
			throw new RangeError("Can't unfilter more data than exists in the buffer!");
		}

		if(bits==16 && (len%2==1)) throw new ArgumentError("16 bit unfiltering requires an even ammount of bytes to unfilter!");
		
		var val:int=0;
		var processed:uint=0
		
		if(bits==16) {
			for(;processed<len;processed+=valLen) {
				val+=inBuff.readShort();
				val &= 0xFFFF;
				inBuff.position-=2;
				inBuff.writeShort(val);
			}
		} else {
			for(;processed<len;processed+=valLen) {
				val+=inBuff.readByte();
				val &= 0xFF;
				inBuff.position-=1;
				inBuff.writeByte(val);
			}
		}
	}
}