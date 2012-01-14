package Nitro.SDAT.SeqPlayer {
	import Nitro.SDAT.*;
	import Nitro.SDAT.SequenceEvents.*;
	
	public class SeqPlayer {
		
		private var sdat:SDAT;
		
		private var bank:SBNK;
		private var seq:SSEQ;
		private var waveArchives:Vector.<SWAR>;

		public function SeqPlayer(sdat:SDAT) {
			if(!sdat) throw new ArgumentError("sdat can't be null!");
			this.sdat=sdat;
		}
		
		public function loadSeqByName(name:String):void {
			var seqId:int=sdat.seqSymbols.indexOf(name);
			
			if(seqId<0) throw new ArgumentError("No sequence with the name \""+name+"\"!");
			
			loadSeqById(seqId);
		}
		
		public function loadSeqById(seqId:uint):void {
			seq=sdat.openSSEQ(seqId);
			
			var bankId:uint=sdat.sequenceInfo[seqId].bankId;
			loadBank(bankId);
			
			
		}
		
		private function loadBank(bankId:uint):void {
			var swars:Vector.<uint>=sdat.bankInfo[bankId].swars;
			
			waveArchives=new Vector.<SWAR>();
			waveArchives.length=4;
			waveArchives.fixed=true;
			
			for(var i:uint=0;i<4;++i) {
				var swarId:uint=swars[i];
				if(swarId!=0x0000FFFF) {
					waveArchives[i]=sdat.openSWAR(swarId);
				}
			}
			
			bank=sdat.openBank(bankId);
		}
		

	}
	
}
