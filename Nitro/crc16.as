package Nitro {
	
	import flash.utils.*;
	
	/** Computes a CRC16 checksum like the BIOS does
	@param ba The data to checksum
	@param start The start position of the data to checksum
	@param end The end position of the data to checksum (exclusive)
	@param crc The CRC seed value
	@return The computed CRC value
	*/
	public function crc16(ba:ByteArray,start:uint=0,end:uint=0xFFFFFFFF,crc:uint=0xFFFF):uint {
		
		if(end==0xFFFFFFFF) end=ba.length;
		
		const flipMasks:Vector.<uint> = new <uint> [0x0000,0xCC01,0xD801,0x1400,0xF001,0x3C00,0x2800,0xE401,0xA001,0x6C00,0x7800,0xB401,0x5000,0x9C01,0x8801,0x4400];
		for(var i:uint=start;i<end;i+=2){
			
			
			var currVal:uint=ba[i]|ba[i+1]<<8;
			
			for(var j:uint=0;j<4;j++){
				var flipVal:uint = flipMasks[crc&0x0F];
				crc >>= 4;
				crc ^= flipVal;
				
				var tempVal:uint = currVal >> (4*j);
				flipVal = flipMasks[tempVal&0x0F];
				crc ^= flipVal;
			}
		}
		return crc;
	}
}