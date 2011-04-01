package SDAT {
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;
	
	public class WavePlayer {
		
		private var wave:Wave;
		
		private var playSound:Sound,playChannel:SoundChannel;
		
		private var decoder:ADPCMDecoder;
		
		private var blockPos:uint;

		public function WavePlayer(_wave:Wave) {
			if(!_wave) {
				throw new ArgumentError("_wave can not be null!");
			}
			wave=_wave;
			
			if(wave.encoding==Wave.ADPCM) {
				decoder=new ADPCMDecoder();
			}
			
			playSound=new Sound();
			playSound.addEventListener(SampleDataEvent.SAMPLE_DATA,render);
		}
		
		public function play():void {
			//position=0;
			
			blockPos=wave.dataPos;
			
			if(wave.encoding==Wave.ADPCM) {
				var predictor:uint=wave.sdat.readShort();
				var stepIndex:uint=wave.sdat.readShort();
				decoder.init(predictor,stepIndex);
			}
			
			playChannel=playSound.play();
		}
		
		private function render(e:SampleDataEvent):void {
			var sampleBuffer:Vector.<Number>=new Vector.<Number>();
			
			wave.sdat.position=blockPos;
			
			
			
			decoder.decodeBlock(wave.sdat,wave.duration,sampleBuffer);
			
			for each(var sample:Number in sampleBuffer) {
				e.data.writeFloat(sample);
				e.data.writeFloat(sample);
			}
		}

	}
	
}
