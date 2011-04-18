﻿package Nitro.Graphics {
	
	import flash.utils.*;
	
	public function read555Color(data:ByteArray):uint {
		var entry:uint=data.readUnsignedShort();
		var r:uint=entry & 0x1F;
		var g:uint=(entry >> 5) & 0x1F;
		var b:uint=(entry >> 10) & 0x1F;
		
		r=colorScale(r);
		g=colorScale(g);
		b=colorScale(b);
		
		return b | g << 8 | r << 16;
	}
}

function colorScale(x:uint):uint {
	var o:uint=x<<3;
	if(x & 1) {
		o+=7;
	}
	return o;
}