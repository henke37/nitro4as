package Nitro.Graphics {
	
	import flash.display.*;
	
	public function drawPalette(inPalette:Vector.<uint>,isRGB555:Boolean=true):BitmapData {
		var i:uint;
		var palette:Vector.<uint>;
		
		if(isRGB555) {
			palette=new Vector.<uint>();
			palette.length=inPalette.length;
			palette.fixed=true;
			
			for(i=0;i<palette.length;++i) {
				palette[i]=RGB555.fromRGB555(inPalette[i]);
			}
		} else {
			palette=inPalette;
		}
		
		var bmd:BitmapData=new BitmapData(16,(palette.length-1)/16+1);
		bmd.lock();
		
		i=0;		
		for(var y:uint=0;y<bmd.height;++y) {
			for(var x:uint=0;x<bmd.width;++x) {
				var c:uint=palette[i++];
				bmd.setPixel(x,y,c);
			}
		}
		
		bmd.unlock();
		
		return bmd;
		
	}
}