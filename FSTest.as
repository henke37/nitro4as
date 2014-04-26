package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.geom.*;
	
	import Nitro.FileSystem.*;
	import Nitro.SDAT.InfoRecords.*;
	import Nitro.SDAT.*;
	import Nitro.*;
	
	import fl.controls.*;
	import fl.data.*;
	
	import HTools.Audio.WaveWriter;
	import HTools.Audio.MidiPlayer.Instrument;
	
	use namespace strmInternal;
	
	public class FSTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public var status_txt:TextField;
		public var title_txt:TextField;
		public var playback_txt:TextField;
		
		private static const iconZoom:Number=10;
		private static const title_txtHeight:Number=40;
		private static const TITLE:String="Nitro SDAT Stream player WIP";
		private static const CLICKLOAD:String="Click to load game from disk";
		
		private var sources:DataProvider;
		
		private var playingItem:Object;
		private var player:BasePlayer;
		
		public var progress_mc:Slider;
		public var list_mc:List;
		public var sublist_mc:List;
		public var source_mc:ComboBox;
		public var export_mc:Button;
		
		private var loopMark:Shape;
		private var icon:Bitmap;
		
		private var resetItem:ContextMenuItem;
		
		private static const streamColor:ColorTransform=new ColorTransform(1,0.3,0.5);
		private static const sequenceColor:ColorTransform=new ColorTransform(1,1,0.6);
		private static const sequenceArchiveColor:ColorTransform=new ColorTransform(0.90,1,0.6);
		private static const bankColor:ColorTransform=new ColorTransform(0.65,0.8,1);
		private static const groupColor:ColorTransform=new ColorTransform(0.8,0.7,0.5);
		private static const waveArchiveColor:ColorTransform=new ColorTransform(1,0.5,0.8);
		private static const playerColor:ColorTransform=new ColorTransform(0.7,0.8,0.6);
		
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
			title_txt.text=TITLE;
			
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
				status_txt.text=CLICKLOAD;
				stage.addEventListener(MouseEvent.CLICK,stageClick);
			}
			
			source_mc.dropdown.setStyle("cellRenderer",ColoredCellRenderer);
			source_mc.x=Banner.ICON_WIDTH*iconZoom;
			source_mc.y=title_txt.y+title_txt.height;
			source_mc.labelFunction=sourceLabeler;
			source_mc.width=550-Banner.ICON_WIDTH*iconZoom;
			source_mc.addEventListener(Event.CHANGE,sourceChange);
			source_mc.visible=false;
			source_mc.dataProvider=sources;
			
			sublist_mc.setSize(Banner.ICON_WIDTH*iconZoom,Banner.ICON_HEIGHT*iconZoom);
			sublist_mc.visible=false;
			sublist_mc.setStyle("cellRenderer",ColoredCellRenderer);			
			sublist_mc.addEventListener(Event.CHANGE,sublistSelect);
			
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
			addChildAt(icon,0);
			
			addEventListener(Event.ENTER_FRAME,updatePosition);
			
			resetItem=new ContextMenuItem("Reset",false,false);
			resetItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,reset);
			var sourceItem:ContextMenuItem=new ContextMenuItem("Source code",true);
			sourceItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,goSource);
			contextMenu=new ContextMenu();
			contextMenu.hideBuiltInItems();
			contextMenu.customItems=[resetItem,sourceItem];
			
			
			return;//explicit return to suppress harmful code that the flash IDE injects beyond this point.
		}
		
		private function goSource(e:Event):void {
			navigateToURL(new URLRequest("https://www.assembla.com/code/sdat4as/subversion/nodes/Nitro"));
		}
		
		private function reset(e:Event):void {
			sources.removeAll();
			progress_mc.visible=false;
			export_mc.visible=false;
			loopMark.visible=false;
			icon.bitmapData=null;
			list_mc.visible=false;
			sublist_mc.visible=false;
			source_mc.visible=false;
			playback_txt.visible=false;
			
			title_txt.text=TITLE;
			status_txt.text=CLICKLOAD;
			status_txt.visible=true;
			
			if(player) { player.stop(); }
			
			resetItem.enabled=false;
			
			stage.addEventListener(MouseEvent.CLICK,stageClick);
		}
		
		private function filesLoaded():void {
			if(sources.length>0) {			
				list_mc.visible=true;
				status_txt.visible=false;
				
				source_mc.selectedIndex=0;
				source_mc.visible=sources.length>1;
				
				sourceChange(null);
				
				resetItem.enabled=true;
			}
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
				resetItem.enabled=true;
				return;
			}
			
			filesLoaded();

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
				streamSource.colorTransform=streamColor;
				sources.addItem(streamSource);
			}
			
			if(sdat.sequenceInfo.length) {
				var seqSource:Object={};
				seqSource.dataProvider=listSequences(sdat);
				seqSource.name="Sequences";
				seqSource.fileName=fileName;
				seqSource.fileIndex=fileId;
				seqSource.colorTransform=sequenceColor;
				sources.addItem(seqSource);
			}
			
			
			for(var seqArchiveIndex:uint=0;seqArchiveIndex<sdat.sequenceArchiveInfo.length;++seqArchiveIndex) {
				//try {
					var seqArchive:SSAR=sdat.openSSAR(seqArchiveIndex);
					
					var seqArchiveSource:Object={};
					var symb:SeqArcSymbRecord;
					
					if(sdat.seqArchiveSymbols) {
						symb=sdat.seqArchiveSymbols[seqArchiveIndex];
					}
					
					if(!name) {
						name="SSAR #"+seqArchiveIndex;
					}
					seqArchiveSource.name=name;
					seqArchiveSource.fileName=fileName;
					seqArchiveSource.fileIndex=fileId;
					seqArchiveSource.dataProvider=listSsar(seqArchive,symb);
					seqArchiveSource.colorTransform=sequenceArchiveColor;
					sources.addItem(seqArchiveSource);
				//} catch(err:Error) {
					//trace(err);
				//}
			}
			
			if(sdat.bankInfo.length>0) {
				var bankSource:Object={};
				bankSource.dataProvider=listBanks(sdat);
				bankSource.name="Instrument Banks";
				bankSource.fileName=fileName;
				bankSource.fileIndex=fileId;
				bankSource.colorTransform=bankColor;
				sources.addItem(bankSource);
			}
			
			if(sdat.groupInfo.length>0) {
				var groupSource:Object={};
				groupSource.dataProvider=listGroups(sdat);
				groupSource.name="Groups";
				groupSource.fileName=fileName;
				groupSource.fileIndex=fileId;
				groupSource.colorTransform=groupColor;
				sources.addItem(groupSource);
			}
			
			if(sdat.playerInfo.length>0) {
				var playerSource:Object={};
				playerSource.dataProvider=listPlayers(sdat);
				playerSource.name="Players";
				playerSource.fileName=fileName;
				playerSource.fileIndex=fileId;
				playerSource.colorTransform=playerColor;
				sources.addItem(playerSource);
			}
			
			if(sdat.waveArchiveInfo.length>0) {
				for(var waveArchiveIndex:uint=0;waveArchiveIndex<sdat.waveArchiveInfo.length;++waveArchiveIndex) {
					var waveArchive:SWAR=sdat.openSWAR(waveArchiveIndex);
					
					var waveArchiveSource:Object={};
					var name:String;
					
					if(sdat.waveArchiveSymbols) {
						name=sdat.waveArchiveSymbols[waveArchiveIndex];
					}
					
					if(!name) {
						name="SWAR #"+waveArchiveIndex;
					}
					waveArchiveSource.name=name;
					waveArchiveSource.fileName=fileName;
					waveArchiveSource.fileIndex=fileId;
					waveArchiveSource.dataProvider=listSwar(waveArchive);
					waveArchiveSource.colorTransform=waveArchiveColor;
					sources.addItem(waveArchiveSource);
				}
			}
			
		}
		
		private function listPlayers(sdat:SDAT):DataProvider {
			var o:DataProvider=new DataProvider();
			for(var playerIndex:uint=0;playerIndex<sdat.playerInfo.length;++playerIndex) {
				var player:PlayerInfoRecord=sdat.playerInfo[playerIndex];
				var item:Object={type: "player", index: playerIndex};
				item.info=player;
				
				if(sdat.playerSymbols && playerIndex in sdat.playerSymbols) {
					item.name=sdat.playerSymbols[playerIndex];
				}
				
				o.addItem(item);
			}
			return o;
		}
		
		private function sourceChange(e:Event):void {
			list_mc.dataProvider=source_mc.selectedItem.dataProvider;
		}
		
		private function listGroups(sdat:SDAT):DataProvider {
			var provider:DataProvider=new DataProvider();
			
			for(var groupIndex:uint=0;groupIndex<sdat.groupInfo.length;++groupIndex) {
				var item:Object={index: groupIndex, type: "group" };
				item.info=sdat.groupInfo[groupIndex];
				item.sublist=providerForGroup(sdat,item.info);
				
				if(sdat.groupSymbols) {
					if(groupIndex in sdat.groupSymbols) {
						item.name=sdat.groupSymbols[groupIndex];
					}
				}
				
				provider.addItem(item);
			}
			
			return provider;
		}
		
		private function providerForGroup(sdat:SDAT,item:GroupInfoRecord):DataProvider {
			var out:DataProvider=new DataProvider();
			
			for each(var subitem:GroupInfoSubRecord in item.entries) {
				var label:String;
				var color:ColorTransform=null;
				
				label=GroupInfoSubRecord.typeMap[subitem.type]+" ";
				
				var symbols:Vector.<String>=null;
				switch(subitem.type) {
					case GroupInfoSubRecord.BANK:
						symbols=sdat.bankSymbols;
						color=bankColor;
					break;
					case GroupInfoSubRecord.SEQ:
						symbols=sdat.seqSymbols;
						color=sequenceColor;
					break;
					case GroupInfoSubRecord.WAVEARC:
						symbols=sdat.waveArchiveSymbols;
						color=waveArchiveColor;
					break;
					case GroupInfoSubRecord.SEQARC:
						color=sequenceArchiveColor;
						symbols=null;//special handled
					break;
				}
				
				if(subitem.type==GroupInfoSubRecord.SEQARC && sdat.seqArchiveSymbols && subitem.id in sdat.seqArchiveSymbols) {
					label+=sdat.seqArchiveSymbols[subitem.id].symbol;
				} else if(symbols && subitem.id in symbols) {
					label+=symbols[subitem.id];
				} else {
					label+=subitem.id;
				}
				
				out.addItem( { entry:subitem, label: label, colorTransform: color, selectHandler: groupSubRecordSelected });
			}
			
			return out;
		}
		
		private function listBanks(sdat:SDAT):DataProvider {
			var provider:DataProvider=new DataProvider();
			
			for(var bankIndex:uint=0;bankIndex<sdat.bankInfo.length;++bankIndex) {
				var sbnk:SBNK=sdat.openBank(bankIndex);
				
				var item:Object= { index: bankIndex, type: "bank" };
				item.instruments=sbnk.instruments;
				item.info=sdat.bankInfo[bankIndex];
				item.sublist=providerForBank(sbnk);
				
				if(sdat.bankSymbols) {
					if(bankIndex in sdat.bankSymbols) {
						item.name=sdat.bankSymbols[bankIndex];
					}
				}
				
				provider.addItem(item);
			}
			
			return provider;
		}
		
		private function providerForBank(sbnk:SBNK):DataProvider {
			var out:DataProvider=new DataProvider();
			for(var i:uint=0;i<sbnk.instruments.length;++i) {
				var inst:Instrument=sbnk.instruments[i];
				var label:String;
				var color:ColorTransform;
				if(!inst) {
					label="NULL";
					color=new ColorTransform(0.4,0.4,0.4);
				} else {
					if(inst is DrumInstrument) {
						label="Drums";
						color=new ColorTransform(0.8,1,0.8);
					} else if(inst is SplitInstrument) {
						label="Split";
						color=new ColorTransform(0.8,1,1);
					} else if(inst is NoiseInstrument) {
						label="Noise";
						color=new ColorTransform(0.8,0.2,0.8);
					} else if(inst is PulseInstrument) {
						var pulse:PulseInstrument=PulseInstrument(inst);
						label="Pulse "+pulse.dutyPercent.toFixed(1)+" %";
						color=new ColorTransform(1,1,0.5);
					} else {
						var pcm:PCMInstrument=PCMInstrument(inst);
						label="PCM "+pcm.swar+"/"+pcm.swav;
						color=new ColorTransform(1,1,1);
					}
				}
				label="# "+i+" "+label;
				out.addItem({inst:inst, label:label, colorTransform: color, selectHandler: instrumentSelected });
			}
			return out;
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
		
		private function listSequences(sdat:SDAT):DataProvider {
			
			var provider:DataProvider=new DataProvider();
			
			for(var seqIndex:uint=0;seqIndex<sdat.sequenceInfo.length;++seqIndex) {
				try {
					var sseq:SSEQ=sdat.openSSEQ(seqIndex);
					
					var item:Object=listSequence(seqIndex,sseq.sequence,sdat.sequenceInfo[seqIndex],sdat.seqSymbols);
					
					provider.addItem(item);
				} catch(err:Error) {
					trace(err);
				}
			}
			return provider;
		}
		
		private function listSequence(seqIndex:uint,sequence:Sequence,info:SequenceInfoRecord,symbols:Vector.<String>):Object {
			var item:Object={ index: seqIndex, type: "sequence" };
			item.seq=sequence;
			item.info=info;
			
			if(symbols) {
				if(seqIndex in symbols) {
					item.name=symbols[seqIndex];
				}
			}
			
			return item;
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
		
		private function listSsar(ssar:SSAR,symbol:SeqArcSymbRecord):DataProvider {
			var provider:DataProvider=new DataProvider();
			
			for(var sequenceIndex:uint=0;sequenceIndex<ssar.length;++sequenceIndex) {
				var symbols:Vector.<String>;
				if(symbol) {
					symbols=symbol.subSymbols;
				} else {
					symbols=null;
				}
					
				var item:Object=listSequence(sequenceIndex,null,ssar.sequenceInfo[sequenceIndex],symbols);
				
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
			
			if(includeTime && "sampleRate" in item) {
				name+=" - "+formatTime(item.length/item.sampleRate) + (item.loops?(" - Loop: "+formatTime(item.loopPoint/item.sampleRate)):"");
			}
			
			return name;
		}
		
		private function sourceLabeler(item:Object):String {
			//trace(item.fileName,item.fileName.match(/\/([^\/]+)$/));
			return item.fileIndex + " - "+ item.name;
		}
		
		private function sublistSelect(e:Event):void {
			var handler:Function=sublist_mc.selectedItem.selectHandler;
			if(!Boolean(handler)) return;
			handler(sublist_mc.selectedItem);
		}
		
		private function instrumentSelected(obj:Object):void {
			playback_txt.visible=true;
			var inst:Instrument=obj.inst;
			if(!inst) {
				playback_txt.text="NULL Instrument";
				return;
			}

			var o:String=Instrument.instrumentTypeAsString(inst.instrumentType);
			
			var leaf:LeafInstrumentBase=inst as LeafInstrumentBase;
			if(leaf) {

				var pcm:PCMInstrument=inst as PCMInstrument;
				var pulse:PulseInstrument=inst as PulseInstrument;
				if(pcm) {
					o+=" "+pcm.swar+"/"+pcm.swav;
				} else if(pulse) {
					o+=" "+pulse.dutyPercent.toFixed(1)+" %";
				}
				
				o+="\nBase note: "+leaf.baseNote+"\n";
				o+="ADSR: "+leaf.attack+", "+leaf.decay+", "+leaf.sustain+", "+leaf.release+"\n";
				o+="Pan: "+leaf.pan+"\n";
			}
			
			playback_txt.text=o;
			trace(inst.toXML().toXMLString());
		}
		
		private function groupSubRecordSelected(obj:Object):void {
			var entry:GroupInfoSubRecord=obj.entry;
		}
		
		private function listSelect(e:Event):void {
			sublist_mc.visible=false;
			
			if(player) {
				player.stop();
			}
			
			playingItem=list_mc.selectedItem;
			if(playingItem.type=="stream") {
				player=new STRMPlayer(playingItem.stream);
			} else if(playingItem.type=="wave") {
				player=new WavePlayer(playingItem.wave);
			} else {
				player=null;
			}
			
			if("sublist" in playingItem) {
				sublist_mc.dataProvider=playingItem.sublist;
				sublist_mc.visible=true;
			}
			
			playback_txt.visible=progress_mc.visible=export_mc.visible=Boolean(player);
			
			if(playingItem.type=="bank") {
				bankSelected();
			} else if(playingItem.type=="player") {
				playerSelected();
			}
			
			if(player) {
				player.play();
			}
		}
		
		private function bankSelected():void {
			var bankInfo:BankInfoRecord=list_mc.selectedItem.info;
			playback_txt.visible=true;
			var o:String="Bank\nSWARs:";
			o+=bankInfo.swars.join(", ");
			playback_txt.text=o;
		}
		
		private function playerSelected():void {
			var player:PlayerInfoRecord=list_mc.selectedItem.info;
			playback_txt.visible=true;
			var o:String="Player # "+list_mc.selectedItem.index;
			o+="\nMax sequences: "+player.maxSequences+" Player heap size: "+player.heapSize;
			o+="\nChannels: "+pad(player.channels.toString(2),16,"0",true);
			playback_txt.text=o;
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
			} else {
				decoder=null;
			}
			
			if(!decoder) return;
			
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