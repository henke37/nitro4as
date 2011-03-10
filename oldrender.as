		private function oldrender(e:SampleDataEvent):void {
			var restart:Boolean=false;
			var sampleCount:uint=8000;
			
			do {
				
				if(progress+sampleCount>stream.sampleCount) {
					sampleCount=stream.sampleCount-progress;
					restart=stream.loop;
				}
				
				var leftBlock:Boolean=true;
				
				do {
					stream.sdat.position=stream.dataPos+block*stream.blockLength;
					
					var blockSamples:uint;
					if(block+stream.channels>=stream.nBlock) {//last block(s)
						blockSamples=stream.lastBlockSamples;
					} else {
						blockSamples=stream.blockSamples;
					}
					
					var sampleBuffer:Vector.<Number>;
					if(leftBlock || stream.channels==1) {
						sampleBuffer=leftBuffer;
					} else {
						sampleBuffer=rightBuffer;
					}
					
					
					if(stream.encoding==Wave.ADPCM) {
						stream.sdat.position+=4;//Skip the ADPCM header
						
						var decoder:ADPCMDecoder=decoders[1-uint(leftBlock || stream.channels==1)];
						
						decoder.decodeBlock(stream.sdat,blockSamples,sampleBuffer);
						
						
					} else {
						var sample:Number;
						var i:uint;
						for(;i<blockSamples;++i) {
							
							if(stream.encoding==1) {
								sample=shortToNumber(stream.sdat.readUnsignedShort());
							} else {
								sample=byteToNumber(stream.sdat.readByte());
							}
							if(i<2) {
								trace(sample);
							}
							
							sampleBuffer[i]=sample;
							
						}
					}
					leftBlock=!leftBlock;
					block++;
					if(leftBlock || stream.channels==1) {
						var toRead:uint=blockSamples;
						if(toRead>sampleCount) {
							toRead=sampleCount;
						}
						sampleCount-=toRead;
						for(i=0;i<toRead;++i) {
							e.data.writeFloat(leftBuffer[i]);
							if(stream.channels==2) {
								e.data.writeFloat(rightBuffer[i]);
							} else {
								e.data.writeFloat(leftBuffer[i]);
							}
						}
						progress+=toRead;
					}
					
				} while(sampleCount>0 && block<stream.nBlock);
				
				
				
				if(restart) {
					progress=stream.loopPoint;
					block=0;//TODO: compute proper block based on looppoint
					restart=false;
				}
			} while(restart);
		}