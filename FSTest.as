package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.FileSystem.*;	
	import Nitro.SDAT.*;
	import Nitro.*;
	
	import fl.controls.*;
	
	use namespace strmInternal;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var sdat:SDAT;
		
		private var status:TextField;
		private var title:TextField;
		private var playback:TextField;
		
		private static const iconZoom:Number=10;
		private static const titleHeight:Number=40;
		
		private var stream:STRM;
		private var player:STRMPlayer;
		
		public var progress_mc:Slider;
		public var list_mc:List;
		
		private var loopMark:Shape;
		
		public function FSTest() {
			
			stage.align=StageAlign.TOP_LEFT;
			
			status=new TextField();
			status.x=Banner.ICON_WIDTH*iconZoom;
			status.y=titleHeight;
			status.width=550-Banner.ICON_WIDTH*iconZoom;
			status.wordWrap=true;
			status.multiline=true;
			status.autoSize=TextFieldAutoSize.LEFT;
			addChild(status);
			
			title=new TextField();
			title.x=Banner.ICON_WIDTH*iconZoom;
			title.width=550-Banner.ICON_WIDTH*iconZoom;
			title.wordWrap=true;
			title.height=titleHeight;
			title.text="Nitro SDAT Stream player WIP";
			addChild(title);
			
			playback=new TextField();
			playback.y=Banner.ICON_HEIGHT*iconZoom;
			playback.height=stage.stageHeight-Banner.ICON_HEIGHT*iconZoom;
			playback.width=Banner.ICON_WIDTH*iconZoom;
			playback.selectable=false;
			addChild(playback);
			
			if(loaderInfo.url.match(/^file:/) && false) {
				status.text="Loading data";
				loader=new URLLoader();
				loader.addEventListener(Event.COMPLETE,loaded);
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.load(new URLRequest("game.nds"));
			} else {
				status.text="Click to load game from disk";
				stage.addEventListener(MouseEvent.CLICK,stageClick);
			}
			
			list_mc.visible=false;
			list_mc.addEventListener(Event.CHANGE,listSelect);
			list_mc.x=Banner.ICON_WIDTH*iconZoom;
			list_mc.y=title.y+title.height;
			list_mc.setSize(550-Banner.ICON_WIDTH*iconZoom,380-(title.y+title.height));
			
			loopMark=new Shape();
			loopMark.graphics.lineStyle(1,0xFF0000);
			loopMark.graphics.moveTo(0,-10);
			loopMark.graphics.lineTo(0,2);
			loopMark.visible=false;
			
			addEventListener(Event.ENTER_FRAME,updatePosition);
		}
		
		private function updatePosition(e:Event):void {
			if(!player) return;
			progress_mc.liveDragging=false;
			progress_mc.minimum=0;
			progress_mc.maximum=stream.sampleCount;
			progress_mc.value=player.position;
			
			var ptext:String=formatTime(player.position/stream.sampleRate)+"/"+formatTime(stream.sampleCount/stream.sampleRate);
			
			ptext+=" "+stream.sampleRate+"Hz "+(stream.stereo?"stereo":"mono")+" "+Wave.encodingAsString(stream.encoding);
			if(stream.loop) {
				ptext+=" Loop:"+formatTime(stream.loopPoint/stream.sampleRate);
			}
			
			playback.text=ptext;
		}
		
		private static function formatTime(t:Number):String {
			var o:String="";
			o=pad(Math.floor(t/60).toString(),2,"0",true);
			o+=":";
			o+=pad(Math.floor(t%60).toString(),2,"0",true);;
			return o;
		}
		
		private static function pad(str:String,minLen:uint,padding:String=" ",fromLeft:Boolean=false):String {
			while(str.length<minLen) {
				if(fromLeft) {
					str=padding+str;
				} else {
					str+=padding;
				}
			}
			return str;
		}
		
		private var fr:FileReference;
		
		private function stageClick(e:MouseEvent):void {
			
			fr=new FileReference();
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Nitro games","*.nds")]);
		}
		
		private function fileSelected(e:Event):void {
			stage.removeEventListener(MouseEvent.CLICK,stageClick);
			
			fr.addEventListener(Event.COMPLETE,frLoaded);
			status.text="Loading data";
			fr.load();
			
		}
		
		private function frLoaded(e:Event):void {
			nds=new NDS();
			nds.parse(fr.data);
			setup();
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			setup();
		}
		
		private function setup():void {
			
			if(nds.banner) {
				var icon:Bitmap=new Bitmap(nds.banner.icon);
				icon.scaleX=iconZoom;
				icon.scaleY=iconZoom;
				addChild(icon);
				
				title.text=nds.banner.enTitle;
			}
			var files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.sdat$/i,true,true);
			
			var fileRef:File;
			if(files.length>0) {
				fileRef=files[0] as File;
			}
			
			if(fileRef) {
				var fileContents:ByteArray=nds.fileSystem.openFileByReference(fileRef);
				sdat=new SDAT();
				sdat.parse(fileContents);
				listStreams();
			} else {
				status.text="No sdat found";
			}

		}
		
		private function playStream(streamNumber:uint):void {
			stream=sdat.streams[streamNumber];
			player=new STRMPlayer(stream);
			player.play();
		}
		
		private function listStreams():void {
			
			status.text="";
			
			if(sdat.streams.length==0) {
				status.text="No Streams";
				return;
			}
			
			status.visible=false;
			list_mc.visible=true;
			list_mc.dataProvider.removeAll();
						
			for(var streamIndex:String in sdat.streams) {
				var streamName:String;
				if(!sdat.streamSymbols) {
					streamName="STREAM #"+streamIndex;
				} else if(streamIndex in sdat.streamSymbols) {
					streamName=sdat.streamSymbols[streamIndex];
				} else {
					streamName="UNLISTED STREAM #"+streamIndex;
				}
				
				list_mc.addItem({ label: streamName, index: streamIndex, type: "stream" });
				
				//status.htmlText+="<a href=\"event:stream/"+streamIndex+"\">"+streamIndex+" "+streamName+"</a><br>";
			}
			
			
			
			//status.addEventListener(TextEvent.LINK,streamClick);
		}
		
		private function listSelect(e:Event):void {
			if(player) {
				player.stop();
			}
			
			var obj:Object=list_mc.selectedItem;
			if(obj.type=="stream") {
				playStream(obj.index);
			}
		}
		
		/*
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
		}*/
	}
	
}
