package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	
	/** ChannelManager, resolves note events into channel assignments */
	public class ChannelManager {
		
		private var channels:Vector.<ChannelState>;

		public function ChannelManager() {
			channels=new Vector.<ChannelState>();
			channels.length=Mixer.channelCount;
			channels.fixed=true;
			
			for(var i:uint=0;i<Mixer.channelCount;++i) {
				channels[i]=new ChannelState();
			}
		}
		
		private static const pcmChnArray:Vector.<uint> = new <uint> [ 4, 5, 6, 7, 2, 0, 3, 1, 8, 9, 10, 11, 14, 12, 15, 13 ];
		private static const psgChnArray:Vector.<uint> = new <uint> [ 13, 12, 11, 10, 9, 8 ];
		private static const noiseChnArray:Vector.<uint> = new <uint> [ 15, 14 ];
		private static const chnArrayArray:Vector.<Vector.<uint>>=new Vector.<Vector.<uint>>([ pcmChnArray, psgChnArray, noiseChnArray ]);;
		{
			initStatics();
		}
		
		private static function initStatics():void {
			pcmChnArray.fixed=true;
			psgChnArray.fixed=true;
			noiseChnArray.fixed=true;
			chnArrayArray.fixed=true;
		}
		
		public function startNote(instrument:Instrument):void {
			
			var channelId:uint=allocateChannel(instrument.noteType,0);//TODO- find the priority
			
		}
		
		/** Updates the mixer state every few samples 
		@return How many samples until it needs to be run again*/
		internal function updateTick():int {
			
			return 10;
		}
		
		/*
		int ds_allocchn(int type, int prio)
		{
			u8* chnArray = arrayArray[type];
			u8 arraySize = arraySizes[type];
			
			int i;
			int curChnNo = -1;
			for (i = 0; i < arraySize; i ++)
			{
				int thisChnNo = chnArray[i];
				ADSR_stat_t* thisChn = ADSR_ch + thisChnNo;
				ADSR_stat_t* curChn = ADSR_ch + curChnNo;
				if (curChnNo != -1 && thisChn->prio >= curChn->prio)
				{
					if (thisChn->prio != curChn->prio)
						continue;
					if (ADSR_vol[curChnNo] <= ADSR_vol[thisChnNo])
						continue;
				}
				curChnNo = thisChnNo;
			}
			
			if (curChnNo == -1 || prio < ADSR_ch[curChnNo].prio) return -1;
			return curChnNo;
		}*/
		
		
		private function allocateChannel(type:uint,prio:uint):uint {
			var bestChannel:int=-1;
			
			var candidates:Vector.<uint>=chnArrayArray[type];
			
			for each(var candidateIndex:uint in candidates) {
				
			}
			
			return bestChannel;
		}

	}
	
}
