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
			loader.load(new URLRequest("game.nds"));
		}
		
		private function done(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			sdat=new SDAT();
			sdat.parse(nds.fileSystem.openFileByName("sound_data.sdat"));
			
			for (var i:String in sdat.waveArchives) {
				var symb:String=sdat.waveArchiveSymbols[i];
				
				var swar:SWAR=sdat.waveArchives[i];
				
				trace(symb,swar.waves.length);
				
				for(var j:uint=0;j<swar.waves.length;++j) {
					var wave:Wave=swar.waves[j];
					trace(wave);
				}
			}
			
			index_mc.minimum=0;
			index_mc.maximum=sdat.waveArchives[1].waves.length-1;
			
			playPause_mc.addEventListener(MouseEvent.CLICK,playPause);
		}
		
		private var player:WavePlayer;
		
		private function playPause(e:Event):void {
			
			if(player) {
				player.stop();
			}
			
			var index:uint=index_mc.value;
			
			var wave:Wave=sdat.waveArchives[1].waves[index];
			
			trace(index,wave);
			
			/*if(wave.encoding==Wave.ADPCM) {
				trace("ADPCM, skipping");
				return;
			}*/
			
			player=new WavePlayer(wave);
			//player.allowLooping=false;
			player.play();
		}
		
		
	}
	
}
