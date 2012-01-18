package Nitro.SDAT.SeqPlayer {
	
	import flash.utils.*;
	
	import Nitro.SDAT.*;
	
	import HTools.Audio.*;
	
	/** A normal mixer channel that can play sampled audio */
	public class MixerChannel {
		
		/** If the channel is in pulse generation mode or not */
		public var psgMode:Boolean;
		
		/** The pan of the channel
		<p>-1 is fully left, 0 is balanced and 1 is fully right</p> */
		public var pan:Number;
		
		/** The volume of the channel
		<p>Measured in zero to one, where zero is effiectly muted.</p>*/
		public var volume:Number;
		
		private var decoder:WaveDecoder;
		private var resampler:Resampler;
		
		private var _timer:uint;

		public function MixerChannel() {
			// constructor code
		}
		
		/** Loads an audio sample for playback into the channel
		@param w The wave to load*/
		public function loadWave(w:Wave):void {
			decoder=new WaveDecoder(w);
			resampler=new HoldResampler(0,0,decoder.render);
		}
		
		/** Resets the channel */
		public function reset():void {
			psgMode=false;
			pan=0;
			volume=1;
			decoder=null;
			resampler=null;
		}
		
		/** Generates samples for the channel
		@param b The ByteArray to write the samples into
		@param l The number of samples to generate
		@return The number of samples written*/
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
		
		public function set timer(t:uint):void {
			_timer=t;
		}
		
		public function get timer():uint { return _timer; }

	}
	
}
