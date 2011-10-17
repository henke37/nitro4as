package Nitro.SDAT {
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;
	
	public class WaveDecoder extends BaseDecoder {
		
		private var wave:Wave;
		
		private var playSound:Sound,playChannel:SoundChannel;
		
		private var decoder:ADPCMDecoder;
		
		private var loopTimes:uint;
		
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
		}
		
		public override function reset():void {
			loopTimes=0;			
		}
		
		private var lastBlockSamplesUsed:uint;
		
		public override function render(ob:ByteArray,renderSize:uint):uint {
			
			trace("start");
			
			if(renderSize==0) return 0;
			
			wave.sdat.endian=Endian.LITTLE_ENDIAN;
			
			var samplesLeftToDecode:uint=renderSize;
			
			while(true) {
	
				//write leftovers from last call
				var samplesLeftOver:uint=(loopTimes>0?(numSamples-lastBlockSamplesUsed):0);
				
				var samplesToOutput:uint=samplesLeftOver;
				if(samplesToOutput>samplesLeftToDecode) samplesToOutput=samplesLeftToDecode;
				
				//write the decoded data to the output buffer
				var endSample:uint=lastBlockSamplesUsed+samplesToOutput;
				
				trace("output",samplesToOutput);
				
				var i:uint;
				for(i=lastBlockSamplesUsed;i<endSample;++i) {
					ob.writeFloat(decodeBuffer[i]);
					ob.writeFloat(decodeBuffer[i]);
				}
				
				samplesLeftToDecode-=samplesToOutput;
				lastBlockSamplesUsed=endSample;
				
				if(loopTimes>0 && samplesLeftToDecode>0) {
					if(wave.loops && loopAllowed) {
						seek(wave.nonLoopLength-wave.loopStart);
					} else {
						trace("stop");
						break;
					}
				}
				
				if(samplesLeftToDecode==0) break;
				
				trace("decode");
				
				wave.sdat.position=wave.dataPos;
				
				if(wave.encoding==Wave.ADPCM) {
					//trace("block init "+blockNumber+","+position+","+blockStartOffset);
					
					var predictor:uint=wave.sdat.readShort();
					var stepIndex:uint=wave.sdat.readShort();
					
					decoder.init(predictor,stepIndex);
					
					decoder.decodeBlock(wave.sdat,numSamples,decodeBuffer);
				} else {					
					decodePCM(wave.sdat,numSamples,wave.encoding,decodeBuffer);
				}
				
				lastBlockSamplesUsed=0;
				loopTimes++;
			}// end until enough decoded
			
			return renderSize-samplesLeftToDecode;
		}
		
		public override function seek(pos:uint):void {
			
		}

	}
	
}
