package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	
	import fl.controls.*;
	import fl.events.*;
	
	import Nitro.FileSystem.*;
	import Nitro.SDAT.*;
	
	public class WaveTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		private var sdat:SDAT;
		
		public var playPause_mc:Button;
		public var index_mc:NumericStepper;
		
		public function WaveTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,done);
			loader.addEventListener(IOErrorEvent.IO_ERROR,ops);
			loader.addEventListener(ProgressEvent.PROGRESS,loading);
			try {
				loader.load(new URLRequest("game.nds"));
			} catch (err:Error) {
				trace(err);
			}
			
			playPause_mc.enabled=false;
		}
		
		private function done(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			sdat=new SDAT();
			sdat.parse(nds.fileSystem.openFileByName("sound_data.sdat"));
			
			for (var i:uint=0;i<sdat.waveArchiveInfo.length;++i) {
				var symb:String=sdat.waveArchiveSymbols[i];
				
				var swar:SWAR=sdat.openSWAR(i);
				
				trace(symb,swar.waves.length);
				
				for(var j:uint=0;j<swar.waves.length;++j) {
					var wave:Wave=swar.waves[j];
					trace(wave);
				}
			}
			
			index_mc.minimum=0;
			index_mc.maximum=sdat.openSWAR(1).waves.length-1;
			
			playPause_mc.addEventListener(MouseEvent.CLICK,playPause);
			playPause_mc.enabled=true;
		}
		
		private var player:WavePlayer;
		
		private function playPause(e:Event):void {
			
			if(player) {
				player.stop();
			}
			
			var index:uint=index_mc.value;
			
			var wave:Wave=sdat.openSWAR(1).waves[index];
			
			trace(index,wave);
			
			/*if(wave.encoding==Wave.ADPCM) {
				trace("ADPCM, skipping");
				return;
			}*/
			
			player=new WavePlayer(wave);
			//player.allowLooping=false;
			player.play();
		}
		
		private function ops(e:IOErrorEvent):void {
			trace(e);
		}
		
		private function loading(e:ProgressEvent):void {
			trace(e.bytesTotal,e.bytesLoaded,e.bytesLoaded/e.bytesTotal);
		}
		
	}
	
}
