package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.FileSystem.*;	
	import Nitro.SDAT.*;
	import Nitro.*;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDSParser;
		
		private var sdat:SDATReader;
		
		private var status:TextField;
		
		private static const iconZoom:Number=10;
		private static const titleHeight:Number=40;
		
		public function FSTest() {
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest("game.nds"));
			
			status=new TextField();
			status.x=Banner.ICON_WIDTH*iconZoom;
			status.y=titleHeight;
			status.width=550-Banner.ICON_WIDTH*iconZoom;
			status.wordWrap=true;
			status.multiline=true;
			status.text="Loading data";
			status.autoSize=TextFieldAutoSize.LEFT;
			addChild(status);
		}
		
		private function loaded(e:Event):void {
			nds=new NDSParser(loader.data);
			
			var icon:Bitmap=new Bitmap(nds.banner.icon);
			icon.scaleX=iconZoom;
			icon.scaleY=iconZoom;
			addChild(icon);
			
			var title:TextField=new TextField();
			title.x=Banner.ICON_WIDTH*iconZoom;
			title.width=550-Banner.ICON_WIDTH*iconZoom;
			title.wordWrap=true;
			title.height=titleHeight;
			title.text=nds.banner.enTitle;
			addChild(title);
			
			
			
			var files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.sdat$/i,true,true);
			
			var fileRef:File;
			if(files.length>0) {
				fileRef=files[0] as File;
			}
			
			if(fileRef) {
				var fileContents:ByteArray=nds.fileSystem.openFileByReference(fileRef);
				sdat=new SDATReader(fileContents);
				listStreams();
			} else {
				status.text="No sdat found";
			}

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
		private function playStream(streamNumber:uint):void {
			var stream:STRM=sdat.streams[streamNumber];
			player=new STRMPlayer(stream);
			player.play();
		}
		
		private function listStreams():void {
			
			status.text="";
			
			for(var streamIndex in sdat.streams) {
				var streamName:String;
				if(streamIndex in sdat.streamSymbols) {
					streamName=sdat.streamSymbols[streamIndex];
				} else {
					streamName=" NO NAME";
				}
				
				status.htmlText+="<a href=\"event:stream/"+streamIndex+"\">"+streamIndex+" "+streamName+"</a><br>";
			}
			
			if(sdat.streams.length==0) {
				status.text="No Streams";
			}
			
			status.addEventListener(TextEvent.LINK,streamClick);
		}
		
		private function streamClick(e:TextEvent):void {
			if(player) {
				player.stop();
			}
			
			var parts:Array=e.text.split("/");
			
			var type:String=parts[0];
			if(type=="stream") {
				var streamNumber:uint=parseInt(parts[1]);
				playStream(streamNumber);
			}
		}
	}
	
}
