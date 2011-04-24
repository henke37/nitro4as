package Nitro.Graphics {
	
	import flash.display.*;
	import flash.utils.*;
	
	public class NCGRCreator {
		
		private var picture:BitmapData;

		public function NCGRCreator() {
			// constructor code
		}
		
		//load picture
		
		private function findPalette():void {
			var colorOccurances:Vector.<uint>=new Vector.<uint>;
			
			colorOccurances.length=(1 << 15)-1;
			colorOccurances.fixed=true;
			
			for(var y:uint=0;y<picture.height;++y) {
				for(var x:uint=0;x<picture.width;++x) {
					var color:uint=picture.getPixel32(x,y);
					
					if((color & 0xFF000000)!=0xFF000000) continue;
					
					color=stripColor(color);
					
					++colorOccurances[color];
				}
			}
			
			function sortComp(a:uint,b:uint):int {
				return colorOccurances[a]-colorOccurances[b];
			}
			
			var colorOrder:Vector.<uint>=new Vector.<uint>();
			colorOrder.length=colorOccurances.length;
			colorOrder.fixed=true;
			for(var i:uint=0;i<colorOrder.length;++i) {
				colorOrder[i]=i;
			}
			colorOrder=colorOrder.sort(sortComp);
		}
		//build palette
		//save palette
		//build tiles
		//save tiles

		private function stripColor(c:uint):uint {
			var r:uint=(c>> 16) & 0xFF;
			var g:uint=(c>>8) 0xFF;
			var b:uint=c &0xFF;
			
			r>>>=3;
			g>>>=3;
			b>>>=3;
			
			return (r << 10) | (g << 5) | b;
		}
	}
	
}
