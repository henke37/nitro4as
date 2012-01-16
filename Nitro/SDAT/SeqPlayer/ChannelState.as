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
		
		private var modDelayCnt:uint;
		private var modCounter:uint;
		
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
		
		public function reset():void {
			ampl=-ADSR_THRESHOLD;
		}
		
		public function start():void {
			adsrState=STATE_ATTACK;
			ampl=-ADSR_THRESHOLD;
			
			active=true;
			
			modDelayCnt=0;
			
			tick();
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
						killSound();
						return;
					}
				break;
			}
			
			var modParam:uint=0;
			
			if (modDelayCnt < modDelay) {
				modDelayCnt ++;
			} else {
			
				var speed:uint = (modSpeed & 0x0000FFFF) << 6;
				var counter:uint = (modCounter + speed) >>> 8;
				
				counter %= 0x80;
				
				modCounter += speed;
				modCounter &= 0x00FF;
				modCounter |= counter << 8;
				
				modParam = GetSoundSine(modCounter >>> 8) * modRange * modDepth;
			}
			
			var totalVolume:uint=vol+vel+expr+ampl;
			
			if(modType==MOD_VOL) {
				totalVolume+=modParam;
			}
		}
		
		public function GetSoundSine(x:uint):uint {return 42; }
		
		public function killSound():void {
			active=false;
		}

	}
	
}
