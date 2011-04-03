package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.FileSystem.*;
	
	import Nitro.SDAT.*;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var parser:NDSParser;
		
		public function FSTest() {
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest("game.nds"));
		}
		
		private function loaded(e:Event):void {
			parser=new NDSParser(loader.data);
			
			var icon:Bitmap=new Bitmap(parser.banner.icon);
			icon.scaleX=12;
			icon.scaleY=12;
			addChild(icon);
			
			var title:TextField=new TextField();
			title.x=32*12;
			title.width=550-32*12;
			title.wordWrap=true;
			title.autoSize=TextFieldAutoSize.LEFT;
			title.text=parser.banner.enTitle;
			addChild(title);
			
			if(parser.gameCode=="AGCE") {
				playStream("sound_data.sdat","STRM_BGM19DS_REQ");
			}
			
			//trace(dumpFs(parser.fileSystem.rootDir));
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
		
		private var player:STRMPlayer;
		private function playStream(fileName:String,streamName:String):void {
			var file:ByteArray=parser.fileSystem.openFile(fileName);
			var sdat:SDATReader=new SDATReader(file);
			var stream:STRM=sdat.getStreamByName(streamName);
			player=new STRMPlayer(stream);
			player.play();
		}
	}
	
}
