package Nitro.Graphics {
	
	public class OAMCollector {
		
		public var oams:Vector.<OamTile>;

		public function OAMCollector() {
			
		}

		public function loadOams(cells:NCER):void {
			
			oams=new Vector.<OamTile>();
			
			for each (var cell:Cell in cells.cells) {
				for each(var oam:CellOam in cell.oams) {
					if(!inOams(oam)) {
						oams.push(oam.cloneOamTile());
					}
				}
			}
		}
		
		private function inOams(oam:CellOam):Boolean {
			for each(var candidate:OamTile in oams) {
				if(candidate.tileIndex!=oam.tileIndex) continue;
				if(candidate.paletteIndex!=oam.paletteIndex) continue;
				if(candidate.height!=oam.height) continue;
				if(candidate.width!=oam.width) continue;
				return true;
			}
			return false;
		}
	}
	
}
