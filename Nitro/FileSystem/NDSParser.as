package Nitro.FileSystem {
	
	import flash.utils.*;
	import flash.display.*;
	
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
		
		private var fileNameTablePos:uint;
		private var fileNameTableSize:uint;
		
		private var fileAllocationTablePos:uint;
		private var fileAllocationTableSize:uint;
		
		private var bannerOffset:uint;

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
			
			fileNameTablePos=nds.readUnsignedInt();
			fileNameTableSize=nds.readUnsignedInt();
			
			fileAllocationTablePos=nds.readUnsignedInt();
			fileAllocationTableSize=nds.readUnsignedInt();
			
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
			
			parseBanner();
			
			parseFileSystem();
			
		}
		
		private function parseFileSystem():void {
			
		}
		
		public var jpTitle:String;
		public var enTitle:String;
		public var frTitle:String;
		public var deTitle:String;
		public var itTitle:String;
		public var esTitle:String;
		
		public var icon:BitmapData;
		
		private function parseBanner():void {
			nds.position=bannerOffset;
			
			var version:uint=nds.readUnsignedShort();
			if(version!=1) throw new ArgumentError("Invalid banner version "+version);
			
			var bannerCRC:uint=nds.readUnsignedShort();
			
			nds.position=544+bannerOffset;//pallete data
			
			const palleteLength:uint=16;
			
			var pallete:Vector.<uint>=new Vector.<uint>();
			pallete.length=palleteLength;
			pallete.fixed=true;
			
			for(var i:uint;i<palleteLength;++i) {
				var entry:uint=nds.readUnsignedShort();
				var r:uint=entry & 0x1F;
				var g:uint=(entry >> 5) & 0x1F;
				var b:uint=(entry >> 10) & 0x1F;
				
				r<<=3;
				g<<=3;
				b<<=3;
				
				pallete[i]=b | g << 8 | r << 16;
			}
			
			pallete[0]=0x00FFFF00;
			
			nds.position=bannerOffset+32;
			
			icon=new BitmapData(32,32,true);
			icon.lock();
			
			const blockSize:uint=8;
			const blockCount:uint=4;
			
			for(var blockY:uint=0;blockY<blockCount;++blockY) {
				for(var blockX:uint=0;blockX<blockCount;++blockX) {
					for(var cellY:uint=0;cellY<blockSize;++cellY) {
						for(var cellX:uint=0;cellX<blockSize;) {
							var x:uint=blockX*blockSize+(cellX++);
							var y:uint=blockY*blockSize+cellY;
							
							var nibble:uint=nds.readUnsignedByte();
							
							var highNibble:uint=nibble >> 4 & 0xF;
							var lowNibble:uint=nibble & 0xF;
							
							icon.setPixel(x,y,pallete[ lowNibble ]);
							
							x=blockX*blockSize+(cellX++);
							icon.setPixel(x,y,pallete[ highNibble ]);
														
							
						}
					}
				}
			}
			
			icon.unlock();
			
			
			nds.position=576+bannerOffset;
			
			jpTitle=readUTF16(nds,256);
			enTitle=readUTF16(nds,256);
			frTitle=readUTF16(nds,256);
			deTitle=readUTF16(nds,256);
			itTitle=readUTF16(nds,256);
			esTitle=readUTF16(nds,256);
			
		}
		
		private static function readUTF16(b:ByteArray,len:uint):String {
			var o:String="";
			
			for(var i:uint;i<len;i+=2) {
				o+=String.fromCharCode(b.readUnsignedShort());
			}
			
			return o;
		}

	}
	
}
