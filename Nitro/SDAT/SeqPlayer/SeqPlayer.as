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

		public function SeqPlayer(sdat:SDAT) {
			if(!sdat) throw new ArgumentError("sdat can't be null!");
			this.sdat=sdat;
			
			mixer=new Mixer();
			chanMgr=new ChannelManager();
			tracker=new Tracker();
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
		

	}
	
}
