package Nitro.Graphics {
	import flash.display.*;
	
	public class CellOam {
		
		public var y:int;
		public var x:int;
		public var hide:Boolean;
		public var doubleSize:Boolean;
		
		public var xFlip:Boolean;
		public var yFlip:Boolean;
		
		public var paletteIndex:uint;
		public var tileIndex:uint;
		
		public var width:uint;
		public var height:uint;

		public function CellOam() {
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

	}
	
}
