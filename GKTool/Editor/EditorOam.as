package GKTool.Editor {
	import Nitro.Graphics.*;
	
	import flash.display.*;
	
	public class EditorOam extends CellOam {
		
		internal var rendering:EditorRendering;

		public function EditorOam() {
			rendering=new EditorRendering(this);
		}
		
		public static function spawnFromTemplate(simpleTile:OamTile):EditorOam {
			var o:EditorOam=new EditorOam();
			
			o.width=simpleTile.width;
			o.height=simpleTile.height;
			o.tileIndex=simpleTile.tileIndex;
			o.paletteIndex=simpleTile.paletteIndex;
			
			var complexTile:CellOam= simpleTile as CellOam;
			
			if(complexTile) {
				o.doubleSize=complexTile.doubleSize;
				o.hide=complexTile.hide;
				o.x=complexTile.x;
				o.y=complexTile.y;
				o.xFlip=complexTile.xFlip;
				o.yFlip=complexTile.yFlip;
			}
			
			return o;
		}

	}
	
}
