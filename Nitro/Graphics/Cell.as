package Nitro.Graphics {
	import flash.display.*;
	import flash.text.*;
	
	/** A collection of OAMs that when renderd together compose a single picture */
	
	public class Cell {
		
		/** The oams that the picture is composed of */
		public var oams:Vector.<CellOam>;

		public function Cell() {
			// constructor code
		}
		
		/** Draws the cell
		@param palette The palette to use when rendering the tiles, in RGB888 format
		@param tiles The GraphicsBank where the tiles are stored
		@param subImages True if the tiles are aranged in a big grid or false if they are aranged in one grid per object
		@param useTransparence If the tiles should be rendered using transparency
		@return A new DisplayObject that represents the cell */
		public function rend(palette:Vector.<uint>,tiles:GraphicsBank,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			for each(var oam:CellOam in oams) {
				
				var oamR:DisplayObject=oam.rend(palette,tiles,useSubImages,useTranparency);
				
				spr.addChildAt(oamR,0);
			}
			
			return spr;
		}
		
		/** Draws a rectangle for each object in the cell
		@param boxColor The stroke color for the rectangles
		@param useFill If the rectangles should be filled
		@param tileNumbers If the tile numbers should be displayed
		@return A DisplayObject with the boxes representing the objects*/
		public function rendBoxes(boxColor:uint=0,useFill:Boolean=true,tileNumbers:Boolean=true):DisplayObject {
			var spr:Sprite=new Sprite();
			
			
			
			for each(var oam:CellOam in oams) {
				spr.addChild(oam.drawBox(boxColor,useFill,tileNumbers));
			}
			
			return spr;
		}

	}
	
}
