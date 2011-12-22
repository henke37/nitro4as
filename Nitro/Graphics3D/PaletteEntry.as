package Nitro.Graphics3D {
	
	import Nitro.Graphics.*;
	import flash.display.BitmapData;
	
	/** A palette */
	
	public class PaletteEntry {
		
		private var _unconvertedColors:Vector.<uint>;
		private var _convertedColors:Vector.<uint>;
		
		/** The name of the palette */
		public var name:String;

		public function PaletteEntry() {
			// constructor code
		}
		
		/** The palette colors in RGB555 format */
		public function set unconvertedColors(c:Vector.<uint>):void {
			_convertedColors=null;
			_unconvertedColors=c;
		}
		public function get unconvertedColors():Vector.<uint> { return _unconvertedColors; }
		
		/** The palette colors in RGB888 format */
		public function get convertedColors():Vector.<uint> {
			if(_convertedColors) return _convertedColors;
			_convertedColors=RGB555.paletteFromRGB555(_unconvertedColors);
			return _convertedColors;
		}
		
		public function draw():BitmapData {
			return drawPalette(convertedColors,false);
		}
		

	}
	
}
