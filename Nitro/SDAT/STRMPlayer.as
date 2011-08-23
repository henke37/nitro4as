package Nitro.SDAT {
	
	import flash.events.*;
	import flash.utils.*;
	import flash.media.*;
	
	import HTools.Audio.*;
	import flash.text.TextField;
	
	public class STRMPlayer {
		
		private var decoder:STRMDecoder;
		private var resampler:Resampler;
		
		private var playSound:Sound,playChannel:SoundChannel;

		public function STRMPlayer(strm:STRM) {
			decoder=new STRMDecoder(strm);
			//trace(strm.sampleRate);
			resampler=new HoldResampler(strm.sampleRate,44100,decoder.render);
			
			playSound=new Sound();
			playSound.addEventListener(SampleDataEvent.SAMPLE_DATA,onSampleRequest);
		}
		
		public function set debug(t:TextField):void {
			decoder.debug=t;
		}
		
		public function play():void {
			decoder.reset();
			resampler.reset();
			
			playChannel=playSound.play();
		}
		
		public function stop():void {
			playChannel.stop();
		}
		
		public function get position():uint {
			return decoder.playbackPosition;
		}
		
		public function set position(p:uint):void {
			decoder.seek(p);
		}
		
		private function onSampleRequest(e:SampleDataEvent):void {
			const renderSize:uint=8000;
			resampler.generate(e.data,renderSize);
			//decoder.render(e.data,renderSize);
		}

	}
	
}
