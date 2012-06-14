package Nitro.Compression {
	import flash.utils.*;
	
	/** Decodes RLE encoded data
	@param inBuff The ByteArray holding the compressed data stream
	@param length The length of the decoded data
	@return A new ByteArray holding the decoded data*/	
	public function rleDecode(inBuf:ByteArray,length:uint):ByteArray {
		var outBuf:ByteArray=new ByteArray();
		
		do {
			var flag:uint=inBuf.readUnsignedByte();
			var runLen:uint=flag & 0x7F;
			var compressed:Boolean=Boolean(flag & 0x80);
			
			if(compressed) {
				runLen+=3;
				var sourceByte:uint=inBuf.readUnsignedByte();
				for(var i:uint=0;i<runLen;++i) {
					outBuf.writeByte(sourceByte);
				}
			} else {
				runLen+=1;
				
				inBuf.readBytes(outBuf,outBuf.position,runLen);
				outBuf.position=outBuf.length;
			}
			
		} while(outBuf.length<length);
		
		outBuf.position=0;
		return outBuf;
	}
}