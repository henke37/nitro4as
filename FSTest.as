package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.FileSystem.*;
	import Nitro.SDAT.InfoRecords.*;
	import Nitro.SDAT.*;
	import Nitro.*;
	
	import fl.controls.*;
	import fl.data.*;
	
	import HTools.Audio.WaveWriter;
	
	use namespace strmInternal;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public var status_txt:TextField;
		public var title_txt:TextField;
		public var playback_txt:TextField;
		
		private static const iconZoom:Number=10;
		private static const title_txtHeight:Number=40;
		
		private var sources:DataProvider;
		
		private var playingItem:Object;
		private var player:BasePlayer;
		
		public var progress_mc:Slider;
		public var list_mc:List;
		public var source_mc:ComboBox;
		public var export_mc:Button;
		
		private var loopMark:Shape;
		private var icon:Bitmap;
		
		public function FSTest() {
			
			//stage.align=StageAlign.TOP_LEFT;
			
			sources=new DataProvider();
			
			//status_txt=new TextField();
			status_txt.x=Banner.ICON_WIDTH*iconZoom;
			status_txt.y=title_txtHeight;
			status_txt.width=550-Banner.ICON_WIDTH*iconZoom;
			status_txt.wordWrap=true;
			status_txt.multiline=true;
			status_txt.autoSize=TextFieldAutoSize.LEFT;
			
			//title_txt=new TextField();
			title_txt.x=Banner.ICON_WIDTH*iconZoom;
			title_txt.width=550-Banner.ICON_WIDTH*iconZoom;
			title_txt.wordWrap=true;
			title_txt.height=title_txtHeight;
			title_txt.text="Nitro SDAT Stream player WIP";
			
			//playback_txt=new TextField();
			playback_txt.y=Banner.ICON_HEIGHT*iconZoom;
			playback_txt.height=stage.stageHeight-Banner.ICON_HEIGHT*iconZoom;
			playback_txt.width=Banner.ICON_WIDTH*iconZoom;
			playback_txt.selectable=false;
			
			if(loaderInfo.url.match(/^file:/) && false) {
				status_txt.text="Loading data";
				loader=new URLLoader();
				loader.addEventListener(Event.COMPLETE,loaded);
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.load(new URLRequest("game.nds"));
			} else {
				status_txt.text="Click to load game from disk";
				stage.addEventListener(MouseEvent.CLICK,stageClick);
			}
			
			//source_mc.visible=false;
			source_mc.x=Banner.ICON_WIDTH*iconZoom;
			source_mc.y=title_txt.y+title_txt.height;
			source_mc.labelFunction=sourceLabeler;
			source_mc.width=550-Banner.ICON_WIDTH*iconZoom;
			source_mc.addEventListener(Event.CHANGE,sourceChange);
			source_mc.visible=false;
			source_mc.dataProvider=sources;
			
			list_mc.visible=false;
			list_mc.addEventListener(Event.CHANGE,listSelect);
			list_mc.x=Banner.ICON_WIDTH*iconZoom;
			list_mc.y=source_mc.y+source_mc.height;
			list_mc.setSize(550-Banner.ICON_WIDTH*iconZoom,400-(source_mc.y+source_mc.height));
			list_mc.labelFunction=listLabeler;
			
			progress_mc.width=Banner.ICON_WIDTH*iconZoom-20;
			progress_mc.visible=false;
			
			export_mc.visible=false;
			export_mc.label="Export";
			export_mc.addEventListener(MouseEvent.CLICK,exportClick);
			
			loopMark=new Shape();
			loopMark.graphics.lineStyle(1,0xFF0000);
			loopMark.graphics.moveTo(0,-10);
			loopMark.graphics.lineTo(0,2);
			loopMark.visible=false;
			
			icon=new Bitmap();
			icon.scaleX=iconZoom;
			icon.scaleY=iconZoom;
			addChild(icon);
			
			addEventListener(Event.ENTER_FRAME,updatePosition);
			
			return;//explicit return to suppress harmful code that the flash IDE injects beyond this point.
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
			
			playback_txt.text=ptext;
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
			fr.browse([new FileFilter("Nitro games","*.nds"),new FileFilter("SDAT archives","*.sdat")]);
		}
		
		private function fileSelected(e:Event):void {
			stage.removeEventListener(MouseEvent.CLICK,stageClick);
			
			fr.addEventListener(Event.COMPLETE,frLoaded);
			status_txt.text="Loading data";
			fr.load();
			
		}
		
		private function frLoaded(e:Event):void {
			if(RegExp(/\.nds$/i).test(fr.name)) {
				loadNDS(fr.data);
			} else if(RegExp(/\.sdat$/i).test(fr.name)) {
				loadSDAT(fr.data,fr.name);
				filesLoaded();
			}
		}
		
		private function loaded(e:Event):void {
			loadNDS(loader.data);
		}
		
		private function loadNDS(data:ByteArray):void {
			var nds:NDS=new NDS();
			nds.parse(fr.data);
			
			if(nds.banner) {
				icon.bitmapData=nds.banner.icon;
				
				title_txt.text=nds.banner.enTitle;
			}
			var files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.(?:sdat|dsxe)$/i,true,false);
			
			var fileId:uint=0;
			for each(var fileRef:File in files) {
			
				var fileContents:ByteArray=nds.fileSystem.openFileByReference(fileRef);
				
				
				var fileName:String=nds.fileSystem.getFullNameForFile(fileRef);
				
				loadSDAT(fileContents,fileName,fileId);
				
				++fileId;
			}
			
			files=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.(?:adpcm|swav)$/i,true);
			
			if(files.length) {
				listSwavs(files,nds);
			}
			
			if(sources.length==0) {
				status_txt.text="No files found";
				return;
			}
			
			filesLoaded();

		}
		
		private function filesLoaded():void {
			if(sources.length>0) {			
				list_mc.visible=true;
				status_txt.visible=false;
				progress_mc.visible=true;
				
				source_mc.selectedIndex=0;
				source_mc.visible=sources.length>1;
				
				sourceChange(null);
			}
		}
		
		private function loadSDAT(fileContents:ByteArray,fileName:String,fileId:uint=0):void {
			var sdat:SDAT=new SDAT();
			sdat.parse(fileContents);
			
			if(sdat.streamInfo.length==0) {
				status_txt.text="No Streams";
			} else {
				var streamSource:Object={};
				streamSource.dataProvider=listStreams(sdat);
				streamSource.name="Streams";
				streamSource.fileName=fileName;
				streamSource.fileIndex=fileId;
				sources.addItem(streamSource);
			}
			
			if(sdat.waveArchiveInfo.length>0) {
				for(var archiveIndex:uint=0;archiveIndex<sdat.waveArchiveInfo.length;++archiveIndex) {
					var archive:SWAR=sdat.openSWAR(archiveIndex);
					
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
		}
		
		private function sourceChange(e:Event):void {
			list_mc.dataProvider=source_mc.selectedItem.dataProvider;
		}
		
		private function listSwavs(files:Vector.<AbstractFile>,nds:NDS):void {
			var dp:DataProvider=new DataProvider();
			var typeItem:Object= { name: "SWAVS", fileIndex: 0, dataProvider: dp };
			
			sources.addItem(typeItem);
			
			var fileId:uint=0;
			for each(var fileRef:File in files) {
			
				var fileContents:ByteArray=nds.fileSystem.openFileByReference(fileRef);
				
				var swav:SWAV=new SWAV();
				swav.parse(fileContents);
				
				var wave:Wave=swav.wave;
				
				var item:Object={index: fileId, type: "wave"};
				
				item.length=wave.sampleCount;
				item.loops=wave.loops;
				item.loopPoint=wave.loopStart;
				item.sampleRate=wave.samplerate;
				item.stereo=false;
				item.encoding=wave.encoding;
				item.wave=wave;
				
				item.name=fileRef.name;
				
				dp.addItem(item);
				
				++fileId;
			}
		}
		
		private function listStreams(sdat:SDAT):DataProvider {
			
			var provider:DataProvider=new DataProvider();
			
			for(var streamIndex:uint=0;streamIndex<sdat.streamInfo.length;++streamIndex) {
				
				var strm:STRM=sdat.openSTRM(streamIndex);
				
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
		
		private function listLabeler(item:Object,includeTime:Boolean=true):String {
			var name:String="";
			
			name=item.name;
				
			if(!name || !name.match(/\S/i)) {
				name=String(item.type).toLocaleUpperCase()+" #"+item.index;
			}
			
			if(includeTime) {
				name+=" - "+formatTime(item.length/item.sampleRate) + (item.loops?(" - Loop: "+formatTime(item.loopPoint/item.sampleRate)):"");
			}
			
			return name;
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
			
			export_mc.visible=true;
			
			player.play();
		}
		
		private function exportClick(e:MouseEvent):void {
			var fr:FileReference=new FileReference();
			
			var stereo:Boolean=playingItem.type=="stream" && playingItem.stereo;
			
			var wave:WaveWriter=new WaveWriter(stereo,32,playingItem.sampleRate);
			var decoder:BaseDecoder;
			
			if(playingItem.type=="stream") {
				decoder=new STRMDecoder(playingItem.stream);
			} else if(playingItem.type=="wave") {
				decoder=new WaveDecoder(playingItem.wave);
			}
			
			decoder.loopAllowed=false;
			decoder.rendAsMono=!stereo;
			
			var sampleBuff:ByteArray=new ByteArray();
			sampleBuff.endian=Endian.LITTLE_ENDIAN;
			
			const renderSize:uint=10000;
			var rendered:uint;
			do {
				sampleBuff.length=0;
				rendered=decoder.render(sampleBuff,renderSize);
				wave.addSamples(sampleBuff);
			} while(rendered==renderSize);
			
			wave.finalize();
			
			var fileName:String=listLabeler(playingItem,false);
			fileName=fileName.replace(/#/,"");
			
			fr.save(wave.outBuffer,fileName+".wav");
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
