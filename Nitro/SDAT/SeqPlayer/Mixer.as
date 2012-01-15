package Nitro.SDAT.SeqPlayer {
	import flash.utils.*;
	
	public class Mixer {
		
		public static const channelCount:uint=16;
		
		public var channels:Vector.<MixerChannel>;
		
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
		}
		
		/** Resets the mixer to the pre playback state */
		public function reset():void {
			for each(var channel:MixerChannel in channels) {
				channel.reset();
			}
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
		
		/** Rends a chunk of samples uninterupted by the callback. */
		private function rendChunk(b:ByteArray,s:uint):uint {
			return s;
		}

	}
	
}
