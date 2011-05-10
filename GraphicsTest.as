package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.Graphics.*;

	
	public class GraphicsTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		public function GraphicsTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,parse);
			loader.load(new URLRequest("korg.nds"));
		}
		
		private function parse(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var paletteData:ByteArray=nds.fileSystem.openFileByName("data/BG1.NCLR");
			var palette:NCLR=new NCLR();
			palette.parse(paletteData);
			
			var tileData:ByteArray=nds.fileSystem.openFileByName("data/BG1.NCGR");
			var tiles:NCGR=new NCGR();
			tiles.parse(tileData);
			
			var convertedPalette:Vector.<uint>=RGB555.paletteFromRGB555(palette.colors);
			
			var renderedTiles:DisplayObject=tiles.render(convertedPalette,0);
			addChild(renderedTiles);
			
			
			var screenData:ByteArray=nds.fileSystem.openFileByName("data/BG1.NSCR");
			var screen:NSCR=new NSCR();
			screen.parse(screenData);
			
			var rendered:DisplayObject=screen.render(tiles,convertedPalette);
			//rendered.scaleX=2;
			//rendered.scaleY=2;
			rendered.x=renderedTiles.width;
			
			
			addChild(rendered);
			
		}
	}
	
}
