package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.Graphics.*;
	import Nitro.*;
	import Nitro.GK.*;
	import flash.geom.Rectangle;
	
	public class CellTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		public function CellTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,parse);
			loader.load(new URLRequest("gk2.nds"));
			
			stage.align=StageAlign.TOP_LEFT;
		}
		
		private function parse(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var archive:GKArchive=new GKArchive();
			archive.parse(nds.fileSystem.openFileByName("com/bustup.bin"));
			
			var subArchive:GKSubarchive=new GKSubarchive();
			subArchive.parse(archive.open(1));
			
			var paletteData:ByteArray=archive.open(0);
			var palette:NCLR=new NCLR();
			palette.parse(paletteData);
			
			var tileData:ByteArray=subArchive.open(2);
			var tiles:NCGR=new NCGR();
			tiles.parse(tileData);
			
			var convertedPalette:Vector.<uint>=RGB555.paletteFromRGB555(palette.colors);
			
			//var renderedTiles:DisplayObject=tiles.render(palette.colors,0,false);
			//addChild(renderedTiles);
			
			var cellData:ByteArray=subArchive.open(0);
			var cells:NCER=new NCER();
			cells.parse(cellData);
			
			var dump:XML=<cells />;
			
			var cellItr:uint=0;
			
			for each(var cell:Cell in cells.cells) {
				var cellXML:XML=<cell />;
				var cellSpr:DisplayObject;
				for each(var oam:CellOam in cell.oams) {
					var oamXML:XML=<oam x={oam.x} y={oam.y} tile={oam.tileIndex} palette={oam.paletteIndex} width={oam.width} height={oam.height}
					doubleSize={oam.doubleSize?"yes":"no"} flipX={oam.xFlip?"yes":"no"} flipY={oam.yFlip?"yes":"no"} />;
					
					cellXML.appendChild(oamXML);
				}
				
				dump.appendChild(cellXML);
				
				cellSpr=cells.rend(cellItr,convertedPalette,tiles);
				//cellSpr=cell.rendBoxes();
				
				cellSpr.x=(cellItr%10)*50;
				cellSpr.y=uint(cellItr/10)*120;
				addChild(cellSpr);
				
				cellItr++;
			}
			
			trace(dump);
			
			//addChild(cells.rend(0,palette,tiles))
			
			//addChild(cells.cells[0]);
			
			/*
			var screenData:ByteArray=nds.fileSystem.openFileByName("data/BG1.NSCR");
			var screen:NSCR=new NSCR();
			screen.parse(screenData);
			
			var rendered:DisplayObject=screen.render(tiles,palette);
			rendered.scaleX=2;
			rendered.scaleY=2;
			rendered.x=renderedTiles.width;
			
			
			addChild(rendered);*/
			
		}
		
		public override function addChild(obj:DisplayObject):DisplayObject {
			var bounds:Rectangle=obj.getBounds(obj);
			obj.x-=bounds.left;
			obj.y-=bounds.top;
			return super.addChild(obj);
		}
	}
	
}
