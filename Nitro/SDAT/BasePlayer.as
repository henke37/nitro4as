package Nitro.SDAT {
	
	import flash.events.*;
	import flash.utils.*;
	import flash.media.*;
	
	import HTools.Audio.*;
	import flash.text.TextField;
	
	/** Playsback a a decoded audio sample */
	
	public class BasePlayer {
		
		private var decoder:BaseDecoder;
		private var resampler:Resampler;
		
		private var playSound:Sound,playChannel:SoundChannel;

		/** Creates a new STRMPlayer
		@param strm The Stream to play
		*/
		public function BasePlayer(decoder:BaseDecoder,rate:uint) {
			this.decoder=decoder;
			//trace(strm.sampleRate);
			resampler=new HoldResampler(rate,44100,decoder.render);
			
			playSound=new Sound();
			playSound.addEventListener(SampleDataEvent.SAMPLE_DATA,onSampleRequest);
		}
		
		/** Begins playback of the stream */
		public function play():void {
			decoder.reset();
			resampler.reset();
			
			playChannel=playSound.play();
		}
		
		/** Halts playback of the stream */
		public function stop():void {
			playChannel.stop();
		}
		
		/** The position of the stream, measured in non resampled samples */
		public function get position():uint {
			return decoder.playbackPosition;
		}
		
		public function set position(p:uint):void {
			decoder.seek(p);
		}
		
		public function set allowLooping(l:Boolean):void { decoder.loopAllowed=l; }
		public function get allowLooping():Boolean { return decoder.loopAllowed; }
		
		private function onSampleRequest(e:SampleDataEvent):void {
			const renderSize:uint=8000;
			resampler.generate(e.data,renderSize);
			//decoder.render(e.data,renderSize);
		}

	}
	
}
