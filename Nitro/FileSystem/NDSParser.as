package Nitro.FileSystem {
	
	import flash.utils.*;
	import Nitro.*;
	
	public class NDSParser {
		
		public var gameName:String;
		public var gameCode:String;
		
		public var makerCode:String;
		
		public var cardSize:uint;
		
		public var arm9Offset:uint;
		public var arm9Mirror:uint;
		public var arm9ExecuteStart:uint;
		public var arm9Len:uint;
		
		public var arm7Offset:uint;
		public var arm7Mirror:uint;
		public var arm7ExecuteStart:uint;
		public var arm7Len:uint;
		
		private var nds:ByteArray;
		
		public var fileSystem:FileSystem;
		
		public var bannerOffset:uint;		
		public var banner:Banner;

		public function NDSParser(nds:ByteArray) {
			this.nds=nds;
			
			nds.endian=Endian.LITTLE_ENDIAN;
			
			gameName=nds.readUTFBytes(12);
			gameCode=nds.readUTFBytes(4);
			
			makerCode=nds.readUTFBytes(2);
			
			nds.position+=1;//unit code
			nds.position+=1;//device code
			
			cardSize=2<<(nds.readUnsignedByte()+20);
			
			nds.position+=10;//card info
			nds.position+=1;//flags
			
			arm9Offset=nds.readUnsignedInt();
			arm9ExecuteStart=nds.readUnsignedInt();
			arm9Mirror=nds.readUnsignedInt();
			arm9Len=nds.readUnsignedInt();
			
			arm7Offset=nds.readUnsignedInt();
			arm7ExecuteStart=nds.readUnsignedInt();
			arm7Mirror=nds.readUnsignedInt();
			arm7Len=nds.readUnsignedInt();
			
			var fileNameTablePos:uint=nds.readUnsignedInt();
			var fileNameTableSize:uint=nds.readUnsignedInt();
			
			var fileAllocationTablePos:uint=nds.readUnsignedInt();
			var fileAllocationTableSize:uint=nds.readUnsignedInt();
			
			nds.position+=4*4;//overlays
			
			nds.position+=4*2;//flash chip timing controll data
			
			bannerOffset=nds.readUnsignedInt();
			
			var romCRC:uint=nds.readUnsignedShort();
			
			nds.position+=2;//rom timeout
			
			nds.position+=4*2;//unknown arm offsets
			
			nds.position+=8;//magic for unencrypted mode
			
			nds.position+=4*2;//romsize and header size
			
			nds.position+=56;//plain old unknown/reservated/padding
			
			nds.position+=156;//gba logo
			
			var logoCRC:uint=nds.readUnsignedShort();
			var headerCRC:uint=nds.readUnsignedShort();
			
			if(bannerOffset) {
				banner=new Banner(nds,bannerOffset);
			}
			
			fileSystem=new FileSystem(nds,fileNameTablePos,fileNameTableSize,fileAllocationTablePos,fileAllocationTableSize);
			
		}

	}
	
}
