package Nitro.Graphics {
	
	import flash.display.*;
	
	/** Draws a palette to a BitmapData for easy display.
	@param inPalette The palette to draw
	@param isRGB555 If the palette is in RGB555 format
	@return A new BitmapData with the palette drawn on it*/
	
	public function drawPalette(inPalette:Vector.<uint>,isRGB555:Boolean=true):BitmapData {
		var i:uint;
		var palette:Vector.<uint>;
		
		if(isRGB555) {
			palette=RGB555.paletteFromRGB555(inPalette);
		} else {
			palette=inPalette;
		}
		
		var bmd:BitmapData=new BitmapData(16,(palette.length-1)/16+1);
		bmd.lock();
		
		i=0;		
		for(i=0;i<palette.length;++i) {
			var c:uint=palette[i];
			bmd.setPixel(i%bmd.width,i/bmd.width,c);
		}
		
		bmd.unlock();
		
		return bmd;
		
	}
}