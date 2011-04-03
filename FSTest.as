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
			
			trace(parser.gameCode,parser.gameName,parser.makerCode,parser.cardSize,parser.banner.enTitle);
			
			var icon:Bitmap=new Bitmap(parser.banner.icon);
			icon.scaleX=12;
			icon.scaleY=12;
			addChild(icon);
			
			trace(dumpFs(parser.fileSystem.rootDir));
		}
		
		private function dumpFs(dir:Directory) {
			var o:XML=<dir name={dir.name} />;
			
			for each(var abf:AbstractFile in dir.files) {
				var subDir:Directory=abf as Directory;
				if(subDir) {
					o.appendChild(dumpFs(subDir));
				} else {
					o.appendChild(<file name={abf.name} />);
				}
			}
			return o;
		}
	}
	
}
