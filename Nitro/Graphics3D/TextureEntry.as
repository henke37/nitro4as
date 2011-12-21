package Nitro.Graphics3D {
	
	/** A texture */
	
	public class TextureEntry {
		
		/** The encoding used for the texture */
		private var type:uint;
		
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
		/** 2x2 matrix compressed encoding */
		public static const TEXTYPE_COMPRESSED:uint=5;
		/** A5I3 encoding */
		public static const TEXTYPE_A5I3:uint=6;
		/** Direct pixel value encoding */
		public static const TEXTYPE_DIRECT:uint=7;

		private static const texTypeStrings:Vector.<String>=new <String> [];
		
		{
			initTexTypeStrings();
		}

		public function TextureEntry() {
			// constructor code
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
