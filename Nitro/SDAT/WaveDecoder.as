package Nitro.SDAT {
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;
	
	public class WaveDecoder extends BaseDecoder {
		
		private var wave:Wave;
		
		private var playSound:Sound,playChannel:SoundChannel;
		
		private var decoder:ADPCMDecoder;
		
		private var numSamples:uint;
		
		private var decodeBuffer:Vector.<Number>;

		public function WaveDecoder(_wave:Wave) {
			if(!_wave) {
				throw new ArgumentError("_wave can not be null!");
			}
			wave=_wave;
			
			if(wave.encoding==Wave.ADPCM) {
				decoder=new ADPCMDecoder();
			}
			
			numSamples=wave.nonLoopLength+wave.loopStart;
			
			decodeBuffer=new Vector.<Number>();
			
			decode();
		}
		
		private function decode():void {
				
			wave.data.position=wave.dataPos;
			
			if(wave.encoding==Wave.ADPCM) {
				//trace("block init "+blockNumber+","+position+","+blockStartOffset);
				
				var predictor:uint=wave.data.readShort();
				var stepIndex:uint=wave.data.readShort();
				
				decoder.init(predictor,stepIndex);
				
				decoder.decodeBlock(wave.data,numSamples,decodeBuffer);
			} else {					
				decodePCM(wave.data,numSamples,wave.encoding,decodeBuffer);
			}
		}
		
		public override function reset():void {
			position=0
		}
		
		public override function get playbackPosition():uint { return position; }
		
		private var position:uint;
		
		public override function render(ob:ByteArray,renderSize:uint):uint {
			
			//trace("start");
			
			if(renderSize==0) return 0;
			
			wave.data.endian=Endian.LITTLE_ENDIAN;
			
			var samplesLeftToDecode:uint=renderSize;
			
			while(true) {
				
				var startSample:uint=position;
				var endSample:uint=startSample+samplesLeftToDecode;
				
				if(endSample>numSamples) endSample=numSamples;
				
				var samplesToOutput:uint=endSample-startSample;
				
				var i:uint;
				for(i=startSample;i<endSample;++i) {
					ob.writeFloat(decodeBuffer[i]);
					ob.writeFloat(decodeBuffer[i]);
				}
				
				//trace(samplesToOutput);
				
				samplesLeftToDecode-=samplesToOutput;
				position=endSample;
				
				if(position>=numSamples && samplesLeftToDecode>0) {
					if(wave.loops && loopAllowed) {
						//trace(wave.loopStart,position,numSamples);
						seek(wave.loopStart);
					} else {
						//trace("stop");
						break;
					}
				}
				
				if(samplesLeftToDecode==0) break;
			}// end until enough decoded
			
			return renderSize-samplesLeftToDecode;
		}
		
		public override function seek(pos:uint):void {
			position=pos;
		}

	}
	
}
