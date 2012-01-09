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
	import fl.data.*;
	
	use namespace strmInternal;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var status:TextField;
		private var title:TextField;
		private var playback:TextField;
		
		private static const iconZoom:Number=10;
		private static const titleHeight:Number=40;
		
		private var playingItem:Object;
		private var player:BasePlayer;
		
		public var progress_mc:Slider;
		public var list_mc:List;
		public var source_mc:ComboBox;
		
		private var loopMark:Shape;
		
		public function FSTest() {
			
			//stage.align=StageAlign.TOP_LEFT;
			
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
			addChildAt(title,0);
			
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
			
			//source_mc.visible=false;
			source_mc.x=Banner.ICON_WIDTH*iconZoom;
			source_mc.y=title.y+title.height;
			source_mc.labelFunction=sourceLabeler;
			source_mc.width=550-Banner.ICON_WIDTH*iconZoom;
			source_mc.addEventListener(Event.CHANGE,sourceChange);
			source_mc.visible=false;
			
			list_mc.visible=false;
			list_mc.addEventListener(Event.CHANGE,listSelect);
			list_mc.x=Banner.ICON_WIDTH*iconZoom;
			list_mc.y=source_mc.y+source_mc.height;
			list_mc.setSize(550-Banner.ICON_WIDTH*iconZoom,400-(source_mc.y+source_mc.height));
			list_mc.labelFunction=listLabeler;
			
			progress_mc.width=Banner.ICON_WIDTH*iconZoom-20;
			progress_mc.visible=false;
			
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
			progress_mc.maximum=playingItem.length;
			progress_mc.value=player.position;
			
			var ptext:String=formatTime(player.position/playingItem.sampleRate)+"/"+formatTime(playingItem.length/playingItem.sampleRate);
			
			ptext+=" "+playingItem.sampleRate+"Hz "+(playingItem.stereo?"stereo":"mono")+" "+Wave.encodingAsString(playingItem.encoding);
			if(playingItem.loops) {
				ptext+=" Loop:"+formatTime(playingItem.loopPoint/playingItem.sampleRate);
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
			
			if(files.length==0) {
				status.text="No sdat found";
				return;
			}
			
			var sources:DataProvider=new DataProvider();
			
			var fileId:uint=0;
			for each(var fileRef:File in files) {
			
				var fileContents:ByteArray=nds.fileSystem.openFileByReference(fileRef);
				var sdat:SDAT=new SDAT();
				sdat.parse(fileContents);
				
				var fileName:String=nds.fileSystem.getFullNameForFile(fileRef);
				
				if(sdat.streams.length==0) {
					status.text="No Streams";
				} else {
					var streamSource:Object={};
					streamSource.dataProvider=listStreams(sdat);
					streamSource.name="Streams";
					streamSource.fileName=fileName;
					streamSource.fileIndex=fileId;
					sources.addItem(streamSource);
				}
				
				if(sdat.waveArchives.length>0) {
					for (var archiveIndex:String in sdat.waveArchives) {
						var archive:SWAR=sdat.waveArchives[archiveIndex];
						
						var archiveSource:Object={};
						var name:String;
						
						if(sdat.waveArchiveSymbols) {
							name=sdat.waveArchiveSymbols[archiveIndex];
						}
						
						if(!name) {
							name="SWAR #"+archiveIndex;
						}
						archiveSource.name=name;
						archiveSource.fileName=fileName;
						archiveSource.fileIndex=fileId;
						archiveSource.dataProvider=listSwar(archive);
						sources.addItem(archiveSource);
					}
				}
				
				++fileId;
			}
			
			if(sources.length>0) {			
				list_mc.visible=true;
				status.visible=false;
				progress_mc.visible=true;
				
				source_mc.dataProvider=sources;
				source_mc.selectedIndex=0;
				source_mc.visible=sources.length>1;
				
				sourceChange(null);
			}

		}
		
		private function sourceChange(e:Event):void {
			list_mc.dataProvider=source_mc.selectedItem.dataProvider;
		}
		
		private function listStreams(sdat:SDAT):DataProvider {
			
			var provider:DataProvider=new DataProvider();
						
			for(var streamIndex:String in sdat.streams) {
				var strm:STRM=sdat.streams[streamIndex];
				
				var item:Object={ index: streamIndex, type: "stream" };
				
				item.length=strm.sampleCount;
				item.loopPoint=strm.loopPoint;
				item.loops=strm.loop;
				item.sampleRate=strm.sampleRate;
				item.stereo=strm.stereo;
				item.encoding=strm.encoding;
				item.stream=strm;
				
				if(sdat.streamSymbols) {
					if(streamIndex in sdat.streamSymbols) {
						item.name=sdat.streamSymbols[streamIndex];
					}
				}
				
				provider.addItem(item);
				
			}
			
			return provider;
		}
		
		private function listSwar(swar:SWAR):DataProvider {
			var provider:DataProvider=new DataProvider();
			
			for(var sampleIndex:String in swar.waves) {
				var wave:Wave=swar.waves[sampleIndex];
				
				var item:Object={index: sampleIndex, type: "wave"};
				
				item.length=wave.sampleCount;
				item.loops=wave.loops;
				item.loopPoint=wave.loopStart;
				item.sampleRate=wave.samplerate;
				item.stereo=false;
				item.encoding=wave.encoding;
				item.wave=wave;
				
				provider.addItem(item);
			}
			
			return provider;
		}
		
		private function listLabeler(item:Object):String {
			var name:String="";
			
			name=item.name;
				
			if(!name || !name.match(/\S/i)) {
				name=String(item.type).toLocaleUpperCase()+" #"+item.index;
			}
			
			return name +" - "+formatTime(item.length/item.sampleRate) + (item.loops?(" - Loop: "+formatTime(item.loopPoint/item.sampleRate)):"");
		}
		
		private function sourceLabeler(item:Object):String {
			//trace(item.fileName,item.fileName.match(/\/([^\/]+)$/));
			return item.fileIndex + " - "+ item.name;
		}
		
		private function listSelect(e:Event):void {
			if(player) {
				player.stop();
			}
			
			playingItem=list_mc.selectedItem;
			if(playingItem.type=="stream") {
				player=new STRMPlayer(playingItem.stream);
			} else if(playingItem.type=="wave") {
				player=new WavePlayer(playingItem.wave);
			}
			
			player.play();
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
