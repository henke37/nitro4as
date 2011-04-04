package Nitro {
	
	import flash.utils.*;
	import flash.display.*;
	
	public class Banner {
		
		public var jpTitle:String;
		public var enTitle:String;
		public var frTitle:String;
		public var deTitle:String;
		public var itTitle:String;
		public var esTitle:String;
		
		public var icon:BitmapData;
		
		private static const blockSize:uint=8;
		private static const blockCount:uint=4;
		
		public static const ICON_WIDTH:uint=blockSize*blockCount;
		public static const ICON_HEIGHT:uint=blockSize*blockCount;

		public function Banner(nds:ByteArray,bannerOffset:uint) {
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
				
				r=colorScale(r);
				g=colorScale(g);
				b=colorScale(b);
				
				pallete[i]=b | g << 8 | r << 16;
			}
			
			pallete[0]=0x00FFFF00;
			
			nds.position=bannerOffset+32;
			
			icon=new BitmapData(32,32,true);
			icon.lock();
			
			
			
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
		
		private static function colorScale(x:uint):uint {
			var o:uint=x<<3;
			if(x & 1) {
				o+=7;
			}
			return o;
		}

	}
	
}
