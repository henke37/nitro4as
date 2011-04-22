package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.Graphics.*;

	
	public class CellTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		public function CellTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,parse);
			loader.load(new URLRequest("korg.nds"));
		}
		
		private function parse(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var paletteData:ByteArray=nds.fileSystem.openFileByName("data/Cell_Simple.NCLR");
			var palette:NCLR=new NCLR();
			palette.parse(paletteData);
			
			var tileData:ByteArray=nds.fileSystem.openFileByName("data/Cell_Simple.NCGR");
			var tiles:NCGR=new NCGR();
			tiles.parse(tileData);
			
			var renderedTiles:DisplayObject=tiles.render(palette.colors,0);
			addChild(renderedTiles);
			
			var cellData:ByteArray=nds.fileSystem.openFileByName("data/Cell_Simple.NCER");
			var cells:NCER=new NCER();
			cells.parse(cellData);
			
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
	}
	
}
