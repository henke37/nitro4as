package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	
	import flash.events.*;
	
	/** ChannelState, deals with the state of a single audio channel */
	public class ChannelState {
		
		public var active:Boolean;
		
		/** The velocity of the channel */
		public var vel:uint;
		
		public var instrumentPan:uint;
		
		/** The countdown before the modulation begins */
		private var modDelayCnt:uint;
		/** The modulation progress */
		private var modCounter:uint;
		
		public static const MOD_FREQ:uint=0;
		public static const MOD_VOL:uint=1;
		public static const MOD_PAN:uint=2;
		
		/** The priority of the sound playing on the channel */
		public var priority:uint;
		
		public var attackRate:int;
		public var decayRate:int;
		public var sustainLevel:int;
		public var releaseRate:int;
		public var adsrState:uint;
		
		/** The ADSR attunuation */
		internal var ampl:int;

		private static const STATE_ATTACK:uint=1;
		private static const STATE_DECAY:uint=2;
		private static const STATE_SUSTAIN:uint=3;
		private static const STATE_RELEASE:uint=4;
		
		private static const ADSR_K_AMP2VOL:uint=723;
		private static const ADSR_THRESHOLD:uint=ADSR_K_AMP2VOL*128;
		
		/** The timer value, before pitch shifting*/
		public var baseTimer:int;
		/** The timer value, after pitch shifting*/
		public var timer:int;
		
		/** The MixerChannel that is being controlled */
		internal var mixerChannel:MixerChannel;
		
		/** The track that started the current sound */
		internal var track:TrackState;
		
		/** The time the sound has left to play */
		internal var countDown:uint;

		public function ChannelState(mixerChannel:MixerChannel) {
			if(!mixerChannel) throw new ArgumentError("mixerChannel can not be null!");
			this.mixerChannel=mixerChannel;
			
			mixerChannel.addEventListener(Event.COMPLETE,soundOver);
		}
		
		public function reset():void {
			ampl=-ADSR_THRESHOLD;
		}
		
		public function start():void {
			adsrState=STATE_ATTACK;
			ampl=-ADSR_THRESHOLD;
			
			active=true;
			mixerChannel.enabled=true;
			
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
			
			if (modDelayCnt < track.modDelay) {
				modDelayCnt ++;
			} else {
			
				var speed:uint = (track.modSpeed & 0x0000FFFF) << 6;
				
				
				/* var counter:uint = (modCounter + speed) >>> 8;
				
				counter %= 0x80;
				
				modCounter += speed;
				modCounter &= 0x00FF;
				modCounter |= counter << 8;*/
				
				
				modCounter=(modCounter+speed) % 0x8000;
				
				modParam = Tables.soundSin(modCounter >>> 8) * track.modRange * track.modDepth;
			}
			
			/*
			int totalvol = CONV_VOL(ADSR_mastervolume);
			totalvol += CONV_VOL(VOL);
			totalvol += CONV_VOL(EXPR);
			totalvol += CONV_VOL(VEL);
			totalvol += AMPL >> 7;*/
			
			var totalVolume:int=Tables.cnvVol(127);
			totalVolume+=Tables.cnvVol(track.volume);
			totalVolume+=Tables.cnvVol(track.expression);
			totalVolume+=Tables.cnvVol(vel);
			totalVolume+=ampl >> 7;
			
			if(track.modType==MOD_VOL) {
				totalVolume+=modParam;
				if (totalVolume > 0) totalVolume = 0;
			}
			
			totalVolume += 723;
			
			if (totalVolume < 0) totalVolume = 0;
			
			var pan:uint = track.pan + instrumentPan - 64;
			if (track.modType == 2) pan += modParam;
			if (pan < 0) pan = 0;
			if (pan > 127) pan = 127;
			
			trace(totalVolume,ampl,ampl>>7);
			
			mixerChannel.volume=totalVolume/723.0;
			mixerChannel.pan=(pan-64)/64.0;
			
			var totalTimer:int=baseTimer;
			
			if(track.modType==MOD_FREQ) {
				totalTimer=Tables.adjustTimer(totalTimer,modParam);
			}
			
			mixerChannel.timer=totalTimer;
			
			if(countDown) {
				countDown--;
			} else {
				endNote();
			}
			
			//trace(adsrState,ampl,totalVolume,sustainLevel);
		}
		
		/** Called when the note has played long enough */
		private function endNote():void {
			//trace("Note released");
			adsrState=STATE_RELEASE;
			priority=1;
		}
		
		/** Called when the adsr curve hits the end */
		private function killSound():void {
			active=false;
			priority=1;
			mixerChannel.enabled=false;
		}
		
		private function soundOver(e:Event):void {
			active=false;
			priority=1;
		}

	}
	
}
