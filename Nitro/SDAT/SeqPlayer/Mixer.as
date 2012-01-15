package Nitro.SDAT.SeqPlayer {
	
	public class Mixer {
		
		public static const channelCount:uint=16;
		
		public var channels:Vector.<MixerChannel>;

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

	}
	
}
