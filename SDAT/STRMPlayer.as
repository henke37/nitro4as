﻿package SDAT {
	
	import flash.events.*;
	import flash.utils.*;
	import flash.media.*;
	
	use namespace strmInternal;
	
	public class STRMPlayer {
		
		private var playSound:Sound,playChannel:SoundChannel;
		strmInternal var stream:STRM;
		
		private var decoders:Vector.<ADPCMDecoder>;
		private var decodeBuffers:Vector.<Vector.<Number>>;

		public function STRMPlayer(_stream:STRM) {
			if(!_stream) {
				throw new ArgumentError("The stream can not be null!");
			}
			stream=_stream;
			
			if(stream.encoding==Wave.ADPCM) {
				decoders=new Vector.<ADPCMDecoder>();
				decodeBuffers=new Vector.<Vector.<Number>>();
				
				for(var i:uint;i<stream.channels;++i) {
					decoders.push(new ADPCMDecoder());
					decodeBuffers.push(new Vector.<Number>());
				}
				decoders.fixed=true;
				decodeBuffers.fixed=true;
			}
			
			playSound=new Sound();
			playSound.addEventListener(SampleDataEvent.SAMPLE_DATA,onSampleRequest);
		}
		
		public function play():void {
			reset();
			
			playChannel=playSound.play();
		}
		
		public function stop():void {
			playChannel.stop();
		}
		
		private var position:uint=0;//measured in samples
		private var endOfStream:Boolean=false;
		
		private function onSampleRequest(e:SampleDataEvent):void {
			const renderSize:uint=8000;
			render(e.data,renderSize);
		}
		
		public function reset():void {
			endOfStream=false;
			position=0;
		}

		public function render(ob:ByteArray,renderSize:uint):uint {
			
			const blockHeaderLength:uint=4;
			
			//init the decode count as zero
			var samplesLeftToDecode:uint=renderSize;
			
			stream.sdat.endian=Endian.LITTLE_ENDIAN;
			
			//repeat at least once:
			do {
				
				//find offset into current block and the current block
				var blockCurrentSample:uint=position%stream.blockSamples;
				var blockNumber:uint=position/stream.blockSamples;
				var blockLen:uint;
				var blockSamples:uint;
				
				//trace(blockNumber,stream.nBlock);
				
				if(blockNumber+1==stream.nBlock) {
					blockLen=stream.lastBlockLength;
					blockSamples=stream.lastBlockSamples;
					endOfStream=true;
				} else {
					blockLen=stream.blockLength;
					blockSamples=stream.blockSamples;
					endOfStream=false;
				}
				
				//calculate how many samples there are left in the block and set the samplecount to that
				var samplesLeftInBlock:uint=blockSamples-blockCurrentSample;
				var samplesToDecode:uint=samplesLeftInBlock;
				
				//cap the samplecount to the number of samples that we are doing
				if(samplesToDecode>samplesLeftToDecode) {
					samplesToDecode=samplesLeftToDecode;					
				}
				
				//decode the blocks for each channel
				for(var currentChannel:uint=0;currentChannel<stream.channels;++currentChannel) {
					var blockStartOffset:uint=stream.dataPos+(blockNumber*stream.channels+currentChannel)*stream.blockLength;
					var decoder:ADPCMDecoder=decoders[currentChannel];
					
					//init the decoder if the offset is zero
					if(blockCurrentSample==0) {
						stream.sdat.position=blockStartOffset;
						
						var predictor:uint=stream.sdat.readShort();
						var stepIndex:uint=stream.sdat.readShort();
						decoder.init(predictor,stepIndex);
					}
					
					stream.sdat.position=blockStartOffset+blockHeaderLength+blockCurrentSample/2;
					decoder.decodeBlock(stream.sdat,samplesToDecode,decodeBuffers[currentChannel]);
				}
				//write the decoded data to the output buffer
				for(var i:uint=0;i<samplesToDecode;++i) {
					if(stream.channels==2) {
						ob.writeFloat(decodeBuffers[0][i]);
						ob.writeFloat(decodeBuffers[1][i]);
					} else {
						ob.writeFloat(decodeBuffers[0][i]);
						ob.writeFloat(decodeBuffers[0][i]);
					}
				}
				//update the decode count
				samplesLeftToDecode-=samplesToDecode;
				position+=samplesToDecode;
				
			} while(samplesLeftToDecode>0 && !(endOfStream));//keep repeating while we have not decoded enough samples and not(EOS flag set and not looping)
			
			return renderSize-samplesLeftToDecode;
		}
		
		
		public static function byteToNumber(byte:uint):Number {
			return Number(byte)/256;
		}
		public static function shortToNumber(short:uint):Number {
			return Number(short)/(2<<16);
		}

	}
	
}
