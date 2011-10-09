﻿package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.FileSystem.*;	
	import Nitro.SDAT.*;
	import Nitro.*;
	import fl.controls.Slider;
	
	use namespace strmInternal;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var sdat:SDAT;
		
		private var status:TextField;
		private var title:TextField;
		private var debug:TextField;
		
		private static const iconZoom:Number=10;
		private static const titleHeight:Number=40;
		
		private var stream:STRM;
		private var player:STRMPlayer;
		
		public var progress_mc:Slider;
		
		public function FSTest() {			
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
			
			debug=new TextField();
			debug.y=Banner.ICON_HEIGHT*iconZoom;
			debug.height=stage.stageHeight-Banner.ICON_HEIGHT*iconZoom;
			debug.width=stage.stageWidth;
			//addChild(debug);
			
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
			
			addEventListener(Event.ENTER_FRAME,updatePosition);
		}
		
		private function updatePosition(e:Event):void {
			if(!player) return;
			progress_mc.liveDragging=false;
			progress_mc.minimum=0;
			progress_mc.maximum=stream.sampleCount;
			progress_mc.value=player.position;
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
			player.debug=debug;
			player.play();
		}
		
		private function listStreams():void {
			
			status.text="";
			
			if(sdat.streams.length==0) {
				status.text="No Streams";
				return;
			}
						
			for(var streamIndex:String in sdat.streams) {
				var streamName:String;
				if(!sdat.streamSymbols) {
					streamName="STREAM #"+streamIndex;
				} else if(streamIndex in sdat.streamSymbols) {
					streamName=sdat.streamSymbols[streamIndex];
				} else {
					streamName="UNLISTED STREAM #"+streamIndex;
				}
				
				status.htmlText+="<a href=\"event:stream/"+streamIndex+"\">"+streamIndex+" "+streamName+"</a><br>";
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
