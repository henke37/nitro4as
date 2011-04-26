package Nitro.Graphics {
	
	import flash.display.*;
	import flash.utils.*;
	
	public class NCGRCreator {
		
		private var picture:BitmapData;
		
		public var palette:Vector.<uint>;
		
		private const paletteMaxLen:uint=256;

		public function NCGRCreator() {
			// constructor code
		}
		
		//load picture
		public function set pic(p:BitmapData):void {
			picture=p;
		}
		
		public function findPalette():void {
			
			var color:uint;
			
			//build palette
			var colorOccurances:Vector.<uint>=new Vector.<uint>;
			
			colorOccurances.length=(1 << 15);
			colorOccurances.fixed=true;
			
			for(var y:uint=0;y<picture.height;++y) {
				for(var x:uint=0;x<picture.width;++x) {
					color=picture.getPixel32(x,y);
					
					//if((color & 0xFF000000)!=0xFF000000) continue;
					
					color=RGB555.toRGB555(color);
					
					++colorOccurances[color];
				}
			}
			
			//var colorOrder:Vector.<uint>=colorOccurances.sort(Array.RETURNINDEXEDARRAY| Array.DESCENDING| Array.NUMERIC );
			
			
			
			function sortComp(a:uint,b:uint):int {
				return colorOccurances[b]-colorOccurances[a];
			}
			
			var colorOrder:Vector.<uint>=new Vector.<uint>();
			colorOrder.length=colorOccurances.length;
			colorOrder.fixed=true;
			for(var i:uint=0;i<colorOrder.length;++i) {
				colorOrder[i]=i;
			}
			colorOrder=colorOrder.sort(sortComp);
			
			palette=new Vector.<uint>();
			palette.length=paletteMaxLen;
			palette.fixed=true;
			
			palette[0]=RGB555.toRGB555(0xFFAA00);//transparency is orange
			
			for(i=0;i<paletteMaxLen-1;++i) {
				color=colorOrder[i];
				
				if(colorOccurances[color]==0) break;
				
				palette[i+1]=color;
			}
		}
		
		//save palette
		
		
		//build tiles
		//save tiles

		
	}
	
}
