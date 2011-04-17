package Nitro.FileSystem {
	
	import flash.utils.*;
	import Nitro.*;
	
	public class NDS {
		
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
		
		public var arm9OverlayOffset:uint;
		public var arm9OverlaySize:uint;
		public var arm7OverlayOffset:uint;
		public var arm7OverlaySize:uint;
		public var arm9Overlays:Vector.<Overlay>;
		public var arm7Overlays:Vector.<Overlay>;
		
		private var nds:ByteArray;
		
		public var fileSystem:FileSystem;
		
		public var bannerOffset:uint;		
		public var banner:Banner;

		public function NDS() {
			
		}
		
		public function parse(nds:ByteArray):void {
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
			
			//nds.position+=4*4;//overlays
			arm9OverlayOffset=nds.readUnsignedInt();
			arm9OverlaySize=nds.readUnsignedInt();
			arm7OverlayOffset=nds.readUnsignedInt();
			arm7OverlaySize=nds.readUnsignedInt();
			
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
				banner=new Banner();
				banner.parse(nds,bannerOffset);
			}
			
			fileSystem=new FileSystem();
			fileSystem.parse(nds,fileNameTablePos,fileNameTableSize,fileAllocationTablePos,fileAllocationTableSize);
			
			arm9Overlays=readOVT(arm9OverlayOffset,arm9OverlaySize);
			arm7Overlays=readOVT(arm7OverlayOffset,arm7OverlaySize);
		}
		
		private function readOVT(offset:uint,size:uint):Vector.<Overlay> {
			
			if(offset==0) return null;
			
			const entrySize:uint=32;
			
			var o:Vector.<Overlay>=new Vector.<Overlay>();
			
			nds.position=offset;
			
			for(var i:uint=0;i<size;i+=entrySize) {
				var overlay=new Overlay();
				overlay.id=nds.readUnsignedInt();
				overlay.ramAddress=nds.readUnsignedInt();
				overlay.ramSize=nds.readUnsignedInt();
				overlay.bssSize=nds.readUnsignedInt();
				overlay.bssStart=nds.readUnsignedInt();
				overlay.bssStop=nds.readUnsignedInt();
				overlay.fileId=nds.readUnsignedInt();
				o.push(overlay);
				nds.position+=4;//unknown/unused
			}
			
			o.fixed=true;
			return o;
		}

	}
	
}
