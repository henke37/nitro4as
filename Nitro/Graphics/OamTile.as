package Nitro.Graphics {
	
	public class OamTile {
		
		public var paletteIndex:uint;
		public var tileIndex:uint;
		
		public var colorDepth:uint;
		
		public var width:uint;
		public var height:uint;

		public function OamTile() {
			// constructor code
		}
		
		internal function setSize(size:uint,shape:uint):void {
			switch(shape) {
				case 0:
					width=height=8 << size;
				break;
				
				case 1:
					width=[16,32,32,64][size];
					height=[8,8,16,32][size];
				break;
				
				case 2:
					width=[8,8,16,32][size];
					height=[16,32,32,64][size];
				break;
			}
		}
		
		internal function getSize():uint {
			switch(width) {
				case 8:
					switch(height) {
						case 8: return 0;
						case 16: return 0;
						case 32: return 1;
					}
				break;
				
				case 16:
					switch(height) {
						case 16: return 1;
						case 8: return 0;
						case 32: return 2;
					}
				break;
				
				case 32:
				 	switch(height) {
						case 32: return 2;
						case 8: return 1;
						case 16: return 2;
						case 64: return 3;
					}
				break;
				
				case 64:
					switch(height) {
						case 64: return 3;
						case 32: return 3;
					}
				break;
			}
			throw new Error("invalid h/w combo");
		}
		
		public function cloneOamTile():OamTile {
			var o:OamTile=new OamTile();
			o.paletteIndex=paletteIndex;
			o.tileIndex=tileIndex;
			o.width=width;
			o.height=height;
			return o;
		}

	}
	
}
