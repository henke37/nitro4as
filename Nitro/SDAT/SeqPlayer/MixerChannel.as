package Nitro.SDAT.SeqPlayer {
	
	import flash.utils.*;
	import flash.events.*;
	
	import Nitro.SDAT.*;
	
	import HTools.Audio.*;
	
	
	/** A normal mixer channel that can play sampled audio */
	public class MixerChannel extends EventDispatcher {
		
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
		private var _freq:uint;
		
		private var _wave:Wave;
		
		public var enabled:Boolean;

		public function MixerChannel() {
			// constructor code
		}
		
		/** Loads an audio sample for playback into the channel
		@param w The wave to load*/
		public function set wave(w:Wave):void {
			_wave=w;
			if(w) {
				decoder=new WaveDecoder(w);
				resampler=new HoldResampler(0,44100,decoder.render);
				setResamplerInput();
			} else {
				decoder=null;
				resampler=null;
			}
		}
		
		/** Resets the channel */
		public function reset():void {
			psgMode=false;
			pan=0;
			volume=1;
			decoder=null;
			resampler=null;
			enabled=false;
		}
		
		/** Generates samples for the channel
		@param b The ByteArray to write the samples into
		@param l The number of samples to generate
		@return The number of samples written*/
		public final function genSamples(b:ByteArray,l:uint):uint {
			if(psgMode) {
				psgGen(b,l);
				return l;
			} else {
				return sampleGen(b,l);
			}
		}
		
		private function sampleGen(b:ByteArray,s:uint):uint {
			
			const startPos:uint=b.position;
			
			var generatedSamples:uint=resampler.generate(b,s);
			
			b.position=startPos;
			
			const left:Number=volume;
			const right:Number=volume;

			for(var i:uint;i<generatedSamples;++i) {
				//left
				var sample:Number=b.readFloat();
				
				sample*=left;
				
				b.position-=4;
				b.writeFloat(sample);
				
				//right
				sample=b.readFloat();
				
				sample*=right;
				
				b.position-=4;
				b.writeFloat(sample);
				
				
			}
			
			if(generatedSamples<s) {
				enabled=false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
			
			//todo: acount for pan and volume
			return generatedSamples;
		}
		
		private function psgGen(b:ByteArray,l:uint):void {
			
			const left:Number=volume;
			const right:Number=volume;
			
			for(var i:uint=0;i<l;++i) {
				var sample:Number=nextGenSample();
				
				b.writeFloat(sample*left);
				b.writeFloat(sample*right);
			}
		}
		
		protected function nextGenSample():Number { return 0; }
		
		public function set timer(t:int):void {
			freq=Tables.timer2Freq(t);
		}
		
		public function get timer():int { return Tables.freq2Timer(_freq); }
		
		public function get freq():uint {return _freq;}
		
		public function set freq(f:uint):void {
			
			//if(f>44100) throw new RangeError("That's a silly high frequency!");
			if(f<=0) throw new RangeError("The frequency must be higher than zero!");
			
			if(resampler) {
				setResamplerInput();
			}
			
			_freq=f;
		}
		
		private function setResamplerInput():void {
			resampler.inputRate=_wave.samplerate;
		}
		
		

	}
	
}
