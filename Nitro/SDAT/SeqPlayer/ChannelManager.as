﻿package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	import Nitro.SDAT.SequenceEvents.NoteEvent;
	
	/** ChannelManager, resolves note events into channel assignments */
	public class ChannelManager {
		
		/** The control structures for the controlled channels */
		internal var channels:Vector.<ChannelState>;
		
		/** The wave archives used as the sample sources */
		internal var waveArchives:Vector.<SWAR>;
		
		internal var bank:SBNK;

		/** Creates a new channel manager
		@param mixer The mixer whose channels to manage*/
		public function ChannelManager(mixer:Mixer) {
			
			if(!mixer) throw new ArgumentError("Mixer may not be null!");
			
			channels=new Vector.<ChannelState>();
			channels.length=Mixer.channelCount;
			channels.fixed=true;
			
			for(var i:uint=0;i<Mixer.channelCount;++i) {
				channels[i]=new ChannelState(mixer.channels[i]);
			}
		}
		
		public function reset():void {
			for each(var channel:ChannelState in channels) {
				channel.reset();
			}
		}
		
		/** Starts a new note
		@param instrument The instrument with which to play the note
		@param noteEvt The note play event
		@param trackState The tracker state to read details from
		*/
		public function startNote(noteEvt:NoteEvent,trackState:TrackState):void {
			if(!noteEvt) throw new ArgumentError("noteEvnt can not be null!");
			if(!trackState) throw new ArgumentError("trackState can not be null!");
			
			var baseInstrument:Instrument=bank.instruments[trackState.patch];
			if(!baseInstrument) throw new Error("Bad instrument selected!");
			
			var leafInstrument:LeafInstrumentBase=baseInstrument.leafInstrumentForNote(noteEvt.note);
			
			if(!leafInstrument) return;// null instruments should silently be ignored
			
			var chanState:ChannelState=allocateChannel(leafInstrument.instrumentType,trackState.priority);
			if(!chanState) throw new Error("Failed to allocate a channel!");
			
			chanState.track=trackState;
			
			chanState.countDown=noteEvt.duration;
			
			trace("allocated new channel with a duration of",noteEvt.duration,"update ticks");
			
			chanState.attackRate=Tables.cnvAttack(trackState.attack!=-1?trackState.attack:leafInstrument.attack);
			chanState.decayRate =Tables.cnvFall(trackState.decay!=-1?trackState.decay:leafInstrument.decay);
			chanState.sustainLevel=Tables.cnvSustain(trackState.sustain!=-1?trackState.sustain:leafInstrument.sustain);
			chanState.releaseRate=Tables.cnvFall(trackState.release!=-1?trackState.release:leafInstrument.release);
			
			chanState.vel=noteEvt.velocity;
			
			chanState.priority=trackState.priority;
			
			chanState.instrumentPan=leafInstrument.pan;
			
			chanState.mixerChannel.reset();
			
			if(leafInstrument.instrumentType==Instrument.INSTRUMENT_TYPE_PCM) {
				var pcmInstrument:PCMInstrument=PCMInstrument(leafInstrument)
				var wave:Wave=waveArchives[pcmInstrument.swar].waves[pcmInstrument.swav];
				
				chanState.mixerChannel.wave=wave;
				
				chanState.baseTimer = Tables.adjustTimerForNote(wave.timerLen, noteEvt.note, leafInstrument.baseNote);
			} else {
				//TODO: watch further research on this part
				chanState.baseTimer = Tables.adjustTimerForNote(-Tables.freq2Timer(440*8), noteEvt.note, 69);
				chanState.mixerChannel.psgMode=true;
				
				if(leafInstrument.instrumentType==Instrument.INSTRUMENT_TYPE_PULSE) {
					var pulseChan:PulseChannel=chanState.mixerChannel as PulseChannel;
					pulseChan.duty=PulseInstrument(leafInstrument).duty;
				}
			} 
			
			chanState.timer = Tables.adjustTimerForPitchBend(chanState.timer, trackState.pitchBend, trackState.pitchBendRange);
			
			chanState.start();
			
		}
		
		public function updatePitchBend(trackState:TrackState):void {
			for each(var chanState:ChannelState in channels) {
				if(chanState.track!=trackState) continue;
				
				chanState.timer = Tables.adjustTimerForPitchBend(chanState.baseTimer, trackState.pitchBend, trackState.pitchBendRange);
			}
		}
		
		/** Updates the mixer state every few samples 
		*/
		internal function updateTick():void {
			
			for each(var channel:ChannelState in channels) {
				if(!channel.active) continue;
				channel.tick();
			}
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
		
		
		private static const pcmChnArray:Vector.<uint> = new <uint> [ 4, 5, 6, 7, 2, 0, 3, 1, 8, 9, 10, 11, 14, 12, 15, 13 ];
		private static const psgChnArray:Vector.<uint> = new <uint> [ 13, 12, 11, 10, 9, 8 ];
		private static const noiseChnArray:Vector.<uint> = new <uint> [ 15, 14 ];
		private static const chnArrayArray:Vector.<Vector.<uint>>=new Vector.<Vector.<uint>>();
		{
			initStatics();
		}
		
		private static function initStatics():void {
			pcmChnArray.fixed=true;
			psgChnArray.fixed=true;
			noiseChnArray.fixed=true;
			chnArrayArray[0]=pcmChnArray;
			chnArrayArray[1]=psgChnArray;
			chnArrayArray[2]=noiseChnArray;
			chnArrayArray.fixed=true;
		}
		
		private function allocateChannel(type:uint,prio:uint):ChannelState {
			var bestChannel:ChannelState;
			
			var candidates:Vector.<uint>=chnArrayArray[type];
			
			var bestIndex:uint;
			
			for each(var candidateIndex:uint in candidates) {
				var candidateChannel:ChannelState=channels[candidateIndex];
				
				if(!candidateChannel.active) {
					bestChannel=candidateChannel;
					bestIndex=candidateIndex;
					break;
				}
				
				if(bestChannel) {
					if(bestChannel.priority>candidateChannel.priority) {
						bestChannel=candidateChannel;
						bestIndex=candidateIndex;
					} else if(bestChannel.priority==candidateChannel.priority) {
						if(bestChannel.ampl>candidateChannel.priority) {
							bestChannel=candidateChannel;
							bestIndex=candidateIndex;
						}
					}
				} else {
					if(prio>candidateChannel.priority) {
						bestChannel=candidateChannel;
						bestIndex=candidateIndex;
					}
				}
			}
			
			trace(bestIndex);
			
			return bestChannel;
		}

	}
	
}
