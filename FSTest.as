package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	
	import Nitro.FileSystem.*;
	import flash.events.Event;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public function FSTest() {
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest("game.nds"));
		}
		
		private function loaded(e:Event):void {
			var parser:NDSParser=new NDSParser(loader.data);
			
			trace(parser.gameCode,parser.gameName,parser.makerCode,parser.cardSize,parser.enTitle);
			
			var icon:Bitmap=new Bitmap(parser.icon);
			icon.scaleX=12;
			icon.scaleY=12;
			addChild(icon);
		}
	}
	
}
