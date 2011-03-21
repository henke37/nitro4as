package SDAT {
	
	import flash.events.*;
	import flash.utils.*;
	import flash.media.*;
	
	public class STRMPlayer {
		
		private var decoder:STRMDecoder;
		
		private var playSound:Sound,playChannel:SoundChannel;

		public function STRMPlayer(strm:STRM) {
			decoder=new STRMDecoder(strm);
			
			playSound=new Sound();
			playSound.addEventListener(SampleDataEvent.SAMPLE_DATA,onSampleRequest);
		}
		
		public function play():void {
			decoder.reset();
			
			playChannel=playSound.play();
		}
		
		public function stop():void {
			playChannel.stop();
		}
		
		private function onSampleRequest(e:SampleDataEvent):void {
			const renderSize:uint=8000;
			decoder.render(e.data,renderSize);
		}

	}
	
}
