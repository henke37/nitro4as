package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.Graphics.*;
	import Nitro.*;
	import Nitro.GK.*;
	
	public class ScreenTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		public function ScreenTest() {
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
			archive.parse(nds.fileSystem.openFileByName("com/upcut.bin"));
			
			var palette:NCLR=new NCLR();
			palette.parse(archive.open(407));
			
			var tiles:NCGR=new NCGR();
			tiles.parse(archive.open(406));
			
			var convertedPalatte:Vector.<uint>=RGB555.paletteFromRGB555(palette.colors);
			
			addChild(tiles.render(convertedPalatte));
			
			/*
			var screen:NSCR=new NSCR();
			screen.parse(archive.open(111));
			
			addChild(screen.render(tiles,palette));*/
		}
	}
}