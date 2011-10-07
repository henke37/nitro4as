package Nitro.Graphics {
	
	/** Utility class that collects all the cell oams defined by a NCER file. */
	
	public class OAMCollector {
		
		/** The found OamTiles */
		public var oams:Vector.<OamTile>;

		public function OAMCollector() {
			
		}
		
		/** Loads the cell oams from a NCER file.
		@param cells The NCER file to load from */
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
