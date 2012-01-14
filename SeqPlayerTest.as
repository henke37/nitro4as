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
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("aj.nds"));
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.sdat$/i,true,true);
			
			sdat=new SDAT();
			sdat.parse(nds.fileSystem.openFileByReference(File(files[0])));
			
			//trace(sdat.sequences);
			//trace(sdat.seqSymbols);
			
			seqPlayer=new SeqPlayer(sdat);
			seqPlayer.loadSeqByName("BGM01DS_REQ");
		}
	}
	
}
