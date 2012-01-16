package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	public class SeqPlayer {
		
		private var sdat:SDAT;
		
		private var bank:SBNK;
		private var seq:SSEQ;
		private var waveArchives:Object;
		
		internal var mixer:Mixer;
		internal var chanMgr:ChannelManager;
		internal var tracker:Tracker;
		
		private static const UPDATE_RATE:uint=42;

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
			
			tracker.loadTracks(seq);
		}
		
		private function loadBank(bankId:uint):void {
			var swars:Vector.<uint>=sdat.bankInfo[bankId].swars;
			
			waveArchives={};
			
			for(var i:uint=0;i<4;++i) {
				var swarId:uint=swars[i];
				if(swarId!=0x0000FFFF) {
					waveArchives[swarId]=sdat.openSWAR(swarId);
				}
			}
			
			bank=sdat.openBank(bankId);
		}
		
		/** Runs every few samples to update the channel status
		@return How many samples until it needs to be run again*/
		private function updateTick():uint {
			chanMgr.updateTick();
			tracker.updateTick();
			
			return UPDATE_RATE;
		}
		

	}
	
}
