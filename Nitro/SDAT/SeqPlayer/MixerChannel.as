package Nitro.SDAT.SeqPlayer {
	
	import flash.utils.*;
	
	import Nitro.SDAT.*;
	
	import HTools.Audio.*;
	
	public class MixerChannel {

		public var psgMode:Boolean;
		public var pan:Number;
		public var volume:Number;
		
		private var decoder:WaveDecoder;
		private var resampler:Resampler;

		public function MixerChannel() {
			// constructor code
		}
		
		public function loadWave(w:Wave):void {
			decoder=new WaveDecoder(w);
			resampler=new HoldResampler(0,0,decoder.render);
		}
		
		public function reset():void {
			psgMode=false;
			pan=0;
			volume=1;
			decoder=null;
			resampler=null;
		}
		
		public final function genSamples(b:ByteArray,l:uint):void {
			if(psgMode) {
				psgGen(b,l);
			} else {
				sampleGen(b,l);
			}
		}
		
		private function sampleGen(b:ByteArray,l:uint):void {
			
		}
		
		private function psgGen(b:ByteArray,l:uint):void {
			for(var i:uint=0;i<l;++i) {
				var sample:Number=nextGenSample();
				b.writeFloat(sample);
				b.writeFloat(sample);
			}
		}
		
		protected function nextGenSample():Number { return 0; }

	}
	
}
