package Nitro.Graphics3D {
	import flash.display.*;
	import flash.utils.*;
	import flash.geom.*;
	
	/** A texture */
	
	public class TextureEntry {
		
		/** The encoding used for the texture */
		public var format:uint;
		
		/** */
		public static const TEXTYPE_NONE:uint=0;
		/** A3I5 Encoding */
		public static const TEXTYPE_A3I5:uint=1;
		/** 2 bpp 4 color encoding */
		public static const TEXTYPE_4COLOR:uint=2;
		/** 4 bpp 16 color encoding */
		public static const TEXTYPE_16COLOR:uint=3;
		/** 8 bpp 256 color encoding */
		public static const TEXTYPE_256COLOR:uint=4;
		/** 4x4 matrix compressed encoding */
		public static const TEXTYPE_COMPRESSED:uint=5;
		/** A5I3 encoding */
		public static const TEXTYPE_A5I3:uint=6;
		/** Direct pixel value encoding */
		public static const TEXTYPE_DIRECT:uint=7;
		
		/** The name of the texture */
		public var name:String;
		
		/** The width of the texture in texels */
		public var width:uint;
		/** The height of the texture in texels */
		public var height:uint;
		
		/** If color index zero is transparent or not */
		public var transparentZero:Boolean;
		
		/** If the texture repetition should bounce on the X axis */
		public var flipX:Boolean;
		
		/** If the texture repetition should bounce on the Y axis */
		public var flipY:Boolean;
		
		/** If the texture should repeat outside of the definition area on the X axis */
		public var repeatX:Boolean;
		
		/** If the texture should repeat outside of the definition area on the Y axis */
		public var repeatY:Boolean;
		
		/** The palette index used for this texture */
		public var palette:PaletteEntry;
		
		/** The pixel data for the texture */
		internal var pixelData:ByteArray;
		
		

		private static const texTypeStrings:Vector.<String>=new <String> [];
		
		{
			initTexTypeStrings();
		}

		public function TextureEntry() {
			// constructor code
		}
		
		public function draw():BitmapData {
			var bmd:BitmapData=new BitmapData(width,height,true,0xFFFF00FF);
			bmd.lock();
			
			switch(format) {
				case TEXTYPE_A3I5:
					drawA3I5(bmd);
				break;
				
				case TEXTYPE_4COLOR:
					draw4Color(bmd);
				break;
				
				case TEXTYPE_16COLOR:
					draw16Color(bmd);
				break;
				
				case TEXTYPE_256COLOR:
					draw256Color(bmd);
				break;
				
				case TEXTYPE_COMPRESSED:
					drawCompressed(bmd);
				break;
				
				case TEXTYPE_A5I3:
					drawA5I3(bmd);
				break;
				
				case TEXTYPE_DIRECT:
					drawDirect(bmd);
				break;
			}
			
			bmd.unlock();
			return bmd;
		}
		
		private function drawA3I5(bmd:BitmapData):void {}
		private function drawA5I3(bmd:BitmapData):void {}
		private function draw4Color(bmd:BitmapData):void {}
		private function draw16Color(bmd:BitmapData):void {}
		
		private function draw256Color(bmd:BitmapData):void {
			const pixelCount:uint=width*height;
			var vect:Vector.<uint>=new Vector.<uint>();
			vect.length=pixelCount;
			vect.fixed=true;
			
			var colors:Vector.<uint>=palette.convertedColors;
			
			pixelData.endian=Endian.LITTLE_ENDIAN;
			pixelData.position=0;
			
			for(var i:uint=0;i<pixelCount;++i) {
				var c:uint=pixelData.readUnsignedByte();
				if(c==0 && transparentZero) {
					c=0x00FF00FF;
				} else {
					c=colors[c] | 0xFF000000;
				}
				vect[i]=c;
			}
			
			bmd.setVector(new Rectangle(0,0,width,height),vect);
		}
		
		private function drawCompressed(bmd:BitmapData):void {}
		private function drawDirect(bmd:BitmapData):void {}
		
		public function get bpp():uint {
			switch(format) {
				case TEXTYPE_DIRECT:
					return 16;
				break;
				
				case TEXTYPE_A3I5:
				case TEXTYPE_A5I3:
				case TEXTYPE_256COLOR:
					return 8;
				break;
				
				case TEXTYPE_16COLOR:
					return 4;
				break;
				
				case TEXTYPE_4COLOR:
				case TEXTYPE_COMPRESSED:
					return 2;
				break;
				
				default:
					throw new Error("Invalid format detected!");
			}
		}
		
		/** Converts a texture type id to a printable string
		@param type The texture type id
		@return The printable string */
		public static function textypeToString(type:uint):String {
			return texTypeStrings[type];
		}
		
		
		private static function initTexTypeStrings():void {
			texTypeStrings.length=8;
			texTypeStrings.fixed=true;
			texTypeStrings[0]="None";
			texTypeStrings[1]="A3I5";
			texTypeStrings[2]="4Color";
			texTypeStrings[3]="16Color";
			texTypeStrings[4]="256Color";
			texTypeStrings[5]="Compressed";
			texTypeStrings[6]="A5I3";
			texTypeStrings[7]="Direct";
		}
		

	}
	
}
