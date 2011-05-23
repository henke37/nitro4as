package Nitro.Graphics {
	
	public class OamTile {
		
		public var paletteIndex:uint;
		public var tileIndex:uint;
		
		public var width:uint;
		public var height:uint;

		public function OamTile() {
			// constructor code
		}
		
		internal function setSize(size:uint,shape:uint) {
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
