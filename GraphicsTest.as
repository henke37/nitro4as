package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	import flash.ui.*;
	
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
		
		var renderedTiles:DisplayObject;
		var tilesPalette:uint=0;
		
		var tiles:NCGR;
		var convertedPalette:Vector.<uint>;
		
		private function parse(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var paletteData:ByteArray=nds.fileSystem.openFileByName("data/BG1.NCLR");
			var palette:NCLR=new NCLR();
			palette.parse(paletteData);
			
			var tileData:ByteArray=nds.fileSystem.openFileByName("data/BG1.NCGR");
			tiles=new NCGR();
			tiles.parse(tileData);
			
			convertedPalette=RGB555.paletteFromRGB555(palette.colors);
			
			rendTiles();
			
			
			
			var screenData:ByteArray=nds.fileSystem.openFileByName("data/BG1.NSCR");
			var screen:NSCR=new NSCR();
			screen.parse(screenData);
			
			var rendered:DisplayObject=screen.render(tiles,convertedPalette);
			//rendered.scaleX=2;
			//rendered.scaleY=2;
			rendered.x=renderedTiles.width;
			addChild(rendered);
			
			var palR:DisplayObject=new Bitmap(drawPalette(convertedPalette,false));
			palR.y=renderedTiles.height;
			palR.scaleY=palR.scaleX=8;
			addChild(palR);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN,kDown);
		}
		
		function rendTiles():void {
			if(renderedTiles) removeChild(renderedTiles);
			renderedTiles=tiles.render(convertedPalette,tilesPalette);
			addChild(renderedTiles);
		}
		
		function kDown(e:KeyboardEvent):void {
			if(e.keyCode==Keyboard.UP && tilesPalette<15) {
				tilesPalette++;
				rendTiles();
			} else if(e.keyCode==Keyboard.DOWN && tilesPalette>0) {
				tilesPalette--;
				rendTiles();
			}
		}
	}
	
}
