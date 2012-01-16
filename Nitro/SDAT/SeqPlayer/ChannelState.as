package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	
	public class ChannelState {
		
		public var active:Boolean;
		
		/** The volume of the channel */
		public var vol:uint;
		
		/** The velocity of the channel */
		public var vel:uint;
		
		/** Expression, yet another volume modifier */
		public var expr:uint;
		
		public var notePan:uint;
		public var instrumentPan:uint;
		
		public var modType:uint;
		public var modDepth:uint;
		public var modRange:uint;
		public var modSpeed:uint;
		public var modDelay:uint;
		
		public static const MOD_FREQ:uint=0;
		public static const MOD_VOL:uint=1;
		public static const MOD_PAN:uint=2;
		
		public var priority:uint;
		
		public var attackRate:uint;
		public var decayRate:uint;
		public var sustainLevel:uint;
		public var releaseRate:uint;
		public var adsrState:uint;
		
		private var ampl:uint;

		private static const STATE_ATTACK:uint=1;
		private static const STATE_DECAY:uint=2;
		private static const STATE_SUSTAIN:uint=3;
		private static const STATE_RELEASE:uint=4;
		
		private static const ADSR_K_AMP2VOL:uint=723;
		private static const ADSR_THRESHOLD:uint=ADSR_K_AMP2VOL*128;
		
		internal var mixerChannel:MixerChannel;

		public function ChannelState(mixerChannel:MixerChannel) {
			if(!mixerChannel) throw new ArgumentError("mixerChannel can not be null!");
			this.mixerChannel=mixerChannel;
		}
		
		public function start():void {
			adsrState=STATE_ATTACK;
			ampl=-ADSR_THRESHOLD;
		}
		
		internal function tick():void {
			if(!active) return;
			
			switch(adsrState) {
				case STATE_ATTACK:
					ampl=(ampl*attackRate)/255;
					if(ampl==0) adsrState=STATE_DECAY;
				break;
				
				case STATE_DECAY:
					ampl-=decayRate;
					if(ampl<=sustainLevel) {
						adsrState=STATE_SUSTAIN;
						ampl=sustainLevel;
					}
				break;
				
				case STATE_SUSTAIN:
				break;
				
				case STATE_RELEASE:
					ampl-=releaseRate;
					if(ampl<= -ADSR_THRESHOLD) {
						//TODO: KILL SOUND
					}
				break;
			}
			
			var modParam:uint;
			
			var totalVolume:uint=vol+vel+expr+ampl;
			
			if(modType==MOD_VOL) {
				totalVolume+=modParam;
			}
		}

	}
	
}
