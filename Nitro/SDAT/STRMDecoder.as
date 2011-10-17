package Nitro.SDAT {
	import flash.utils.*;
	import flash.text.TextField;
	
	use namespace strmInternal;
	
	/** A decoder for the samples in a STRM file */
	
	public class STRMDecoder extends BaseDecoder {
		
		strmInternal var stream:STRM;
		
		private var decoders:Vector.<ADPCMDecoder>;
		private var decodeBuffers:Vector.<Vector.<Number>>;
		
		

		private const adpcmHeaderLength:uint=4;

		/** Creates a new STRMDecoder
		@param _stream The stream to decode */
		public function STRMDecoder(_stream:STRM) {
			if(!_stream) {
				throw new ArgumentError("The stream can not be null!");
			}
			stream=_stream;
			
			if(stream.encoding==Wave.ADPCM) {
				decoders=new Vector.<ADPCMDecoder>();
			}
			
			decodeBuffers=new Vector.<Vector.<Number>>();
			
			for(var i:uint;i<stream.channels;++i) {
				if(stream.encoding==Wave.ADPCM) {
					decoders.push(new ADPCMDecoder());
				}
				var buf:Vector.<Number>=new Vector.<Number>();
				buf.length=stream.blockSamples;
				buf.fixed=true;
				decodeBuffers.push(buf);
			}
			decoders.fixed=true;
			if(stream.encoding==Wave.ADPCM) {
				decodeBuffers.fixed=true;
			}
			
		}
		
		/** The playback position, measured in samples */
		public override function get playbackPosition():uint {
			return blockNumber*stream.blockSamples+lastBlockSamplesUsed;
		}
		
		/** Resets decoding to the initial state */
		public override function reset():void {
			blockNumber=0;
			lastBlockSamplesTotal=0;
			lastBlockSamplesUsed=0;
		}
				
		private var lastBlockSamplesTotal:uint, lastBlockSamplesUsed:uint;
		private var blockNumber:uint;
		
		/** Decodes samples
		@param ob The ByteArray to write the decoded samples to
		@param renderSize How many samples to decode
		*/
		public override function render(ob:ByteArray,renderSize:uint):uint {
			
			if(renderSize==0) return 0;
			
			stream.sampleData.endian=Endian.LITTLE_ENDIAN;
			
			var samplesLeftToDecode:uint=renderSize;
			
			while(true) {
	
				//write leftovers from last call
				var samplesLeftOver:uint=lastBlockSamplesTotal-lastBlockSamplesUsed;
				
				var samplesToOutput:uint=samplesLeftOver;
				if(samplesToOutput>samplesLeftToDecode) samplesToOutput=samplesLeftToDecode;
				
				//write the decoded data to the output buffer
				var endSample:uint=lastBlockSamplesUsed+samplesToOutput;
				
				var i:uint;
				if(stream.channels==2) {
					for(i=lastBlockSamplesUsed;i<endSample;++i) {
						ob.writeFloat(decodeBuffers[0][i]);
						ob.writeFloat(decodeBuffers[1][i]);
					}
				} else {
					for(i=lastBlockSamplesUsed;i<endSample;++i) {
						ob.writeFloat(decodeBuffers[0][i]);
						ob.writeFloat(decodeBuffers[0][i]);
					}
				}
				
				samplesLeftToDecode-=samplesToOutput;
				lastBlockSamplesUsed=endSample;
				
				if(blockNumber+1>stream.nBlock && samplesLeftToDecode>0) {
					if(stream.loop && loopAllowed) {
						seek(stream.loopPoint);
					} else {
						break;
					}
				}
				
				if(samplesLeftToDecode==0) break;
				
				for(var currentChannel:uint=0;currentChannel<stream.channels;++currentChannel) {
				
					//decode a full block
					
					//find offset into current block and the current block
					
					var blockLen:uint;
					var blockSamples:uint;
					
					if(blockNumber+1>=stream.nBlock) {
						blockLen=stream.lastBlockLength;
						blockSamples=stream.lastBlockSamples;
					} else {
						blockLen=stream.blockLength;
						blockSamples=stream.blockSamples;
					}
	
					var blockStartOffset:uint=(blockNumber*stream.channels)*stream.blockLength;					
					blockStartOffset += currentChannel*blockLen;
					
					if(stream.encoding==Wave.ADPCM) {
	
						var decoder:ADPCMDecoder=decoders[currentChannel];
						
						stream.sampleData.position=blockStartOffset;
							
						//trace("block init "+blockNumber+","+position+","+blockStartOffset);
						
						var predictor:uint=stream.sampleData.readShort();
						var stepIndex:uint=stream.sampleData.readShort();
						
						decoder.init(predictor,stepIndex);
						
						stream.sampleData.position=blockStartOffset+adpcmHeaderLength;
						decoder.decodeBlock(stream.sampleData,blockSamples,decodeBuffers[currentChannel]);
					} else {
						stream.sampleData.position=blockStartOffset;
						
						decodePCM(stream.sampleData,blockSamples,stream.encoding,decodeBuffers[currentChannel]);
					}
					
				}// end for each channel
				
				lastBlockSamplesUsed=0;
				lastBlockSamplesTotal=blockSamples;
				blockNumber++;
			}// end until enough decoded
			
			return renderSize-samplesLeftToDecode;
		}
		
		
		
		
		/** Seeks to a different position in the stream
		@param newPos The position to seek to, measured in samples */
		public override function seek(newPos:uint):void {
			//position ourself at the begining of the block
			blockNumber=newPos/stream.blockSamples;
			
			lastBlockSamplesTotal=0;
			lastBlockSamplesUsed=0;
			
			trace("seeking to ",newPos,blockNumber);
			
			//and then rend past the stuff in the block we don't need
			var renderSize:uint=newPos % stream.blockSamples;
			if(renderSize>0) {
				var scratch:ByteArray=new ByteArray();
				render(scratch,renderSize);
				scratch.clear();
			}
		}

	}
	
}
