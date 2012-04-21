package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import Nitro.FileSystem.*;
	import Nitro.SDAT.*;
	import Nitro.SDAT.SeqPlayer.SeqPlayer;
	
	public class SeqPlayerTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var sdat:SDAT;
		
		private var seqPlayer:SeqPlayer;
		
		public function SeqPlayerTest() {
			
			if(loaderInfo.url.indexOf("file")==0) {
			
				loader=new URLLoader();
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE,loaded);
				loader.addEventListener(IOErrorEvent.IO_ERROR,loadFail);
				loader.load(new URLRequest("aj.nds"));
				
				status_txt.text="Loading aj.nds...";
			} else {
				status_txt.text="Click to load aj.nds.";
				stage.addEventListener(MouseEvent.CLICK,manualLoad);
			}
			
			stage.align=StageAlign.TOP_LEFT;
		}
		
		var fr:FileReference;
		
		private function manualLoad(e:MouseEvent):void {
			fr=new FileReference();
			fr.addEventListener(Event.SELECT,manualSelected);
			fr.browse([new FileFilter("aj.nds","*.nds")]);
		}
		
		private function manualSelected(e:Event):void {
			fr.addEventListener(Event.COMPLETE,manualLoadDone);
			fr.load();
			
			stage.removeEventListener(MouseEvent.CLICK,manualLoad);
			fr.removeEventListener(Event.SELECT,manualSelected);
		}
		
		private function manualLoadDone(e:Event):void {
			try {
				nds=new NDS();
				nds.parse(fr.data);
				loadSeq();
				status_txt.text="Load succeeded. Click to start playback.";
			} catch(err:Error) {
				status_txt.text="Load failed.";
				status_txt.appendText("\n"+err.getStackTrace());
			}
		}
		
		private function loaded(e:Event):void {
			try {
				nds=new NDS();
				nds.parse(loader.data);
				loadSeq();
				status_txt.text="Load succeeded. Click to start playback.";
			} catch(err:Error) {
				status_txt.text="Load failed.";
				status_txt.appendText(err.getStackTrace());
			}
		}
		
		private function loadFail():void {
			status_txt.text="Load failed.";
		}
		
		private function loadSeq():void {
			
			var files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.sdat$/i,true,true);
			
			sdat=new SDAT();
			sdat.parse(nds.fileSystem.openFileByReference(File(files[0])));
			
			var fr:FileReference=new FileReference();
			//fr.save(sdat.openFileById(sdat.bankInfo[48].fatId),"t.sbnk");
			
			//trace(sdat.sequences);
			//trace(sdat.seqSymbols);
			
			seqPlayer=new SeqPlayer(sdat);
			seqPlayer.loadSeqByName("BGM01DS_REQ");
			
			stage.addEventListener(MouseEvent.CLICK,clicked);
		}
		
		private function clicked(e:MouseEvent):void {
			seqPlayer.play();
		}
	}
	
}
