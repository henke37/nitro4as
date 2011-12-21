package Nitro.Graphics3D {
	
	import flash.utils.*;
	
	/** Reads the info block in 3d files
	@param data The ByteArray to read from
	@param startOffset The position in the ByteArray where the info block is located
	@param infoReader A callback Function that parses the format specific part
	@return A Vector containing the parsed records
	*/
	
	internal function readInfo(data:ByteArray,startOffset:uint,infoReader:Function):Vector.<InfoData> {
		
		const o:Vector.<InfoData>=new Vector.<InfoData>;
		
		data.position=startOffset+1;
		const objCount:uint=data.readUnsignedByte();
		
		o.length=objCount;
		o.fixed=true;
		
		const unknownOffset:uint=startOffset+4;
		data.position=unknownOffset;
		const unknownDataSize:uint=data.readUnsignedShort();
		const unknownSize:uint=data.readUnsignedShort();
		
		const infoOffset:uint=startOffset+unknownSize;
		data.position=infoOffset;
		const infoDataSize:uint=data.readUnsignedShort();
		const infoSize:uint=data.readUnsignedShort();
		
		const nameOffset:uint=startOffset+unknownSize+infoSize;
		
		for(var i:uint=0;i<objCount;++i) {
			var infoData:InfoData=new InfoData();
			
			data.position=unknownOffset+unknownDataSize*i;
			infoData.unknown=data.readUnsignedInt();
			
			data.position=nameOffset+i*16;
			infoData.name=data.readUTFBytes(16);
			
			var dataBuff:ByteArray=new ByteArray();
			data.position=infoOffset+4+i*infoDataSize;
			data.readBytes(dataBuff,0,infoDataSize);
			
			dataBuff.endian=Endian.LITTLE_ENDIAN;
			dataBuff.position=0;
			
			infoData.infoData=infoReader(dataBuff);
			
			o[i]=infoData;
		}
		
		return o;
	}
}