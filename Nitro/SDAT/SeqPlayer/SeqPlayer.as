package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	import flash.media.*;
	import flash.events.*;
	import flash.utils.*;
	
	/** A player for sequences */	
	public class SeqPlayer {
		
		private var sdat:SDAT;
		
		private var seq:SSEQ;
		
		private var mixer:Mixer;
		private var chanMgr:ChannelManager;
		private var tracker:Tracker;
		
		private var outSnd:Sound;
		
		private static const UPDATE_RATE:uint=64 * 2728 * 44100 / Mixer.internalSamplerate;//note, not a nice integer
		
		private static const PLAYBACK_SAMPLES:uint=8192

		/** Creates a new Sequence player
		@param sdat The SDAT to load data from */
		public function SeqPlayer(sdat:SDAT) {
			if(!sdat) throw new ArgumentError("sdat can't be null!");
			this.sdat=sdat;
			
			mixer=new Mixer();
			chanMgr=new ChannelManager(mixer);
			tracker=new Tracker(chanMgr);
			
			mixer.callback=updateTick;
		}
		
		/** Loads a standalone sequence by it's symbolic name
		@param name The symbolic name of the sequence
		@throws ArgumentError There was no sequence with that name
		*/
		public function loadSeqByName(name:String):void {
			var seqId:int=sdat.seqSymbols.indexOf(name);
			
			if(seqId<0) throw new ArgumentError("No sequence with the name \""+name+"\"!");
			
			loadSeqById(seqId);
		}
		
		/** Clears out all state */
		public function reset():void {
			mixer.reset();
			chanMgr.reset();
			tracker.reset();
		}
		
		/** Loads a standalone sequence by its id number
		@param seqId The id number of the sequence
		*/
		public function loadSeqById(seqId:uint):void {
			seq=sdat.openSSEQ(seqId);
			
			var bankId:uint=sdat.sequenceInfo[seqId].bankId;
			loadBank(bankId);
			
			tracker.loadTracks(seq.sequence);
		}
		
		private function loadBank(bankId:uint):void {
			var swars:Vector.<int>=sdat.bankInfo[bankId].swars;
			
			var waveArchives:Vector.<SWAR>=new Vector.<SWAR>();
			
			for(var i:uint=0;i<4;++i) {
				var swarId:uint=swars[i];
				if(swarId!=-1) {
					waveArchives[i]=sdat.openSWAR(swarId);
				}
			}
			
			chanMgr.waveArchives=waveArchives;
			
			chanMgr.bank=sdat.openBank(bankId);
		}
		
		/** Runs every few samples to update the channel status
		@return How many samples until it needs to be run again*/
		private function updateTick():uint {
			chanMgr.updateTick();
			tracker.updateTick();
			
			return UPDATE_RATE;
		}
		
		/** Starts playing the loaded sequence */
		public function play():void {
			
			if(!seq) throw new Error("No sequence loaded!");
			
			reset();
			
			outSnd=new Sound();
			outSnd.addEventListener(SampleDataEvent.SAMPLE_DATA,playbackListener);
			outSnd.play();
		}
		
		private function playbackListener(e:SampleDataEvent):void {
			mixer.rend(e.data,PLAYBACK_SAMPLES);
		}
		
		public function rend(b:ByteArray,s:uint):uint {
			if(!seq) throw new Error("No sequence loaded!");
			return mixer.rend(b,s);
		}
		

	}
	
}
