package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	
	import Nitro.Graphics.*;
	import Nitro.FileSystem.*;
	
	public class PartionTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public function PartionTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,done);
			loader.load(new URLRequest("simcity.nds"));
		}
		
		private function done(e:Event):void {
			var nds:NDS=new NDS();
			nds.parse(loader.data);
			
			var clr:NCLR=new NCLR();
			clr.parse(nds.fileSystem.openFileByName("ad_B.NCLR"));
			
			var convertedPalette:Vector.<uint>=RGB555.paletteFromRGB555(clr.colors);
		}
	}
	
}
