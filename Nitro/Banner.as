package Nitro {
	
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.Graphics.*;
	
	/** Banner data for a Nitro game. */
	
	public class Banner {
		
		/** The Japanese title of the game. */
		public var jpTitle:String;
		/** The English title of the game. */
		public var enTitle:String;
		/** The French title of the game. */
		public var frTitle:String;
		/** The Deutch title of the game. */
		public var deTitle:String;
		/** The Italian title of the game. */
		public var itTitle:String;
		/** The Spanish title of the game. */
		public var esTitle:String;
		
		/** The icon for the game. */
		public var icon:BitmapData;
		
		private static const blockSize:uint=8;
		private static const blockCount:uint=4;
		
		public static const ICON_WIDTH:uint=blockSize*blockCount;
		public static const ICON_HEIGHT:uint=blockSize*blockCount;

		public function Banner() {
			
		}
		
		/** Loads banner data from a ByteArray
		@param nds The ByteArray to load from
		@param bannerOffset The position in the ByteArray to load from
		*/
		public function parse(nds:ByteArray,bannerOffset:uint):void {
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
				pallete[i]=RGB555.read555Color(nds);
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
			
			jpTitle=nds.readMultiByte(256,"unicode");
			enTitle=nds.readMultiByte(256,"unicode");
			frTitle=nds.readMultiByte(256,"unicode");
			deTitle=nds.readMultiByte(256,"unicode");
			itTitle=nds.readMultiByte(256,"unicode");
			esTitle=nds.readMultiByte(256,"unicode");
			
		}

	}
	
}
