package Nitro.SDAT.SeqPlayer {
	import flash.utils.*;
	
	/** An aproximation of the Nitro hardware mixer */
	public class Mixer {
		
		public static const channelCount:uint=16;
		
		public static const internalSamplerate:uint=33513982;
		
		/** The channels in the mixer */
		public var channels:Vector.<MixerChannel>;
		
		/** The automatic update callback responsible for playing notes on the mixer */
		public var callback:Function;
		
		private var callbackTimer:int;

		public function Mixer() {
			channels=new Vector.<MixerChannel>();
			channels.length=channelCount;
			channels.fixed=true;
			
			for(var i:uint=0;i<channelCount;++i) {
				if(i>=14) {
					channels[i]=new NoiseChannel();
				} else if(i>=8) {
					channels[i]=new PulseChannel();
				} else {
					channels[i]=new MixerChannel();
				}
			}
			
			readScratchBuffer=new ByteArray();
		}
		
		/** Resets the mixer to the pre playback state */
		public function reset():void {
			for each(var channel:MixerChannel in channels) {
				channel.reset();
			}
			callbackTimer=0;
		}
		
		/** Rends the audio stream and invokes the update callback as needed
		@param b The bytearray to output to
		@param s The number of samplers to output*/
		public function rend(b:ByteArray,s:uint):uint {
			
			var totalSamples:uint=0;
			
			do {
				
				if(callbackTimer==0) {
					callbackTimer=callback();
				}
				
				var chunkSamples:uint=(s<callbackTimer?s:callbackTimer);
				var renderedSamples:uint=rendChunk(b,chunkSamples);
				totalSamples+=renderedSamples;
				
				if(callbackTimer>0) {
					callbackTimer-=renderedSamples;
				}
				
				
			} while(totalSamples<s && renderedSamples==chunkSamples);
			
			return totalSamples;
		}
		
		private var readScratchBuffer:ByteArray;
		
		/** Rends a chunk of samples uninterupted by the callback. */
		private function rendChunk(b:ByteArray,s:uint):uint {
			var i:uint;
			var sample:Number;
			var startOffset:uint=b.position;
			
			for(i=0;i<s;++i) {
				b.writeFloat(0);
				b.writeFloat(0);
			}
			
			for each (var channel:MixerChannel in channels) {
				if(!channel.enabled) continue;
				
				readScratchBuffer.position=0
				
				var readSamples:uint=channel.genSamples(readScratchBuffer,s);
				
				var loopEnd:uint=readSamples*2;
				b.position=startOffset;
				for(i=0;i<loopEnd;++i) {
					sample=b.readFloat();
					sample+=readScratchBuffer.readFloat();
					b.position-=4;
					b.writeFloat(sample);
				}
			}
			
			return s;
		}

	}
	
}
