package Nitro.SDAT {
	
	import Nitro.SDAT.InfoRecords.*;
	
	use namespace sdatInternal;
	use namespace strmInternal;
	
	public function sdat2XML(sdat:SDAT,detailLevel:uint=0):XML {
		var i:uint;
		var j:uint;
		
		var rootXML:XML=<sdat />;
		
		var files:XML=<files />;
		rootXML.appendChild(files);
		for each(var fatRecord:FATRecord in sdat.files) {
			var fileXML:XML=<file size={fatRecord.size} offset={"0x"+fatRecord.pos.toString(16)} />
			files.appendChild(fileXML);
		}
		
		/*
		if(sdat.hasSymbols) {
			var symbolRootXML:XML=<symbols />;
			
			symbolRootXML.appendChild(listSymbols("seq",sdat.seqSymbols));
			symbolRootXML.appendChild(listSymbols("instrumentBank",sdat.bankSymbols));
			symbolRootXML.appendChild(listSymbols("waveArchive",sdat.waveArchiveSymbols));
			symbolRootXML.appendChild(listSymbols("player",sdat.playerSymbols));
			symbolRootXML.appendChild(listSymbols("group",sdat.groupSymbols));
			symbolRootXML.appendChild(listSymbols("player2",sdat.player2Symbols));
			symbolRootXML.appendChild(listSymbols("stream",sdat.streamSymbols));
			
			rootXML.appendChild(symbolRootXML);
		}*/
		
		var sampleBankRootXML:XML=<waveBanks />;
		rootXML.appendChild(sampleBankRootXML);
		for(i=0;i<sdat.waveArchiveInfo.length;++i) {
			var waveBankInfo:BaseInfoRecord=sdat.waveArchiveInfo[i];
			var waveBankXML:XML=<waveBank fatId={waveBankInfo.fatId} />;
			
			if(sdat.hasSymbols) {
				waveBankXML.@symbol=sdat.waveArchiveSymbols[i];
			}
			
			if(detailLevel>=1) {
				var waveBank:SWAR=sdat.openSWAR(i);
				for(j=0;j<waveBank.waves.length;++j) {
					waveBankXML.appendChild(waveBank.waves[j].toXML());
				}
			}
			
			sampleBankRootXML.appendChild(waveBankXML);
		}
		
		var instrumentBankRootXML:XML=<instruments />;
		rootXML.appendChild(instrumentBankRootXML);
		for(i=0;i<sdat.bankInfo.length;++i) {
			var instrumentBankInfo:BankInfoRecord=sdat.bankInfo[i];
			var instrumentBankXML:XML=<instrumentBank
				fatId={instrumentBankInfo.fatId}
			/>;
			
			for(j=0;j<4;++j) {
				instrumentBankXML.appendChild(<waveBank id={instrumentBankInfo.swars[j]} />);
			}
			
			if(detailLevel>=1) {
				var instrumentBank:SBNK=sdat.openBank(i);
				for(j=0;j<instrumentBank.instruments.length;++j) {
					if(instrumentBank.instruments[j]) {
						instrumentBankXML.appendChild(instrumentBank.instruments[j].toXML());
					} else {
						instrumentBankXML.appendChild(<null />);
					}
				}
			}
			
			if(sdat.hasSymbols) {
				instrumentBankXML.@symbol=sdat.bankSymbols[i];
			}
			
			instrumentBankRootXML.appendChild(instrumentBankXML);
		}
		
		
		var seqRootXML:XML=<sequences />;
		rootXML.appendChild(seqRootXML);
		for(i=0;i<sdat.sequenceInfo.length;++i) {
			var seqInfo:SequenceInfoRecord=sdat.sequenceInfo[i];
			var seqXML:XML=<sequence
				instrumentBank={seqInfo.bankId}
				volume={seqInfo.vol}
				channelPressure={seqInfo.channelPressure}
				polyPreasure={seqInfo.polyPressure}
				player={seqInfo.player}
				fatId={seqInfo.fatId}
			/>;
			
			if(sdat.hasSymbols) {
				seqXML.@symbol=sdat.seqSymbols[i];
			}
			seqRootXML.appendChild(seqXML);
		}
		
		var seqArcRootXML=<sequenceArchives />;
		rootXML.appendChild(seqArcRootXML);
		for(i=0;i<sdat.sequenceArchiveInfo.length;++i) {
			var archiveXML:XML=<sequenceArchive />;
			var symb:SeqArcSymbRecord=sdat.seqArchiveSymbols[i];
			var archive:SSAR=sdat.openSSAR(i);
			
			if(sdat.hasSymbols) {
				archiveXML.@symbol=symb.symbol;
			}
			
			for(j=0;j<archive.length;++j) {
				seqInfo=archive.sequenceInfo[j];
				seqXML=<sequence
					instrumentBank={seqInfo.bankId}
					volume={seqInfo.vol}
					channelPressure={seqInfo.channelPressure}
					polyPreasure={seqInfo.polyPressure}
					player={seqInfo.player}
					fatId={seqInfo.fatId}
				/>;
				
				if(sdat.hasSymbols && symb.subSymbols && j<symb.subSymbols.length) {
					seqXML.@symbol=symb.subSymbols[j];
				}
				archiveXML.appendChild(seqXML);
			}
			
			
			seqArcRootXML.appendChild(archiveXML);
		}
		
		var groupRootXML:XML=<groups />;
		rootXML.appendChild(groupRootXML);
		for(i=0;i<sdat.groupInfo.length;++i) {
			var group:GroupInfoRecord=sdat.groupInfo[i];
			var groupXML:XML=<group />;
			
			if(sdat.hasSymbols) {
				groupXML.@symbol=sdat.groupSymbols[i];
			}
			
			for(j=0;j<group.entries.length;++j) {
				groupXML.appendChild(group.entries[j].toXML());
			}
			groupRootXML.appendChild(groupXML);
		}
		
		var streamRootXML:XML=<streams />;
		rootXML.appendChild(streamRootXML);
		for(i=0;i<sdat.streamInfo.length;++i) {
			var streamInfo:StreamInfoRecord=sdat.streamInfo[i];
			var streamXML:XML=<stream
				priority={streamInfo.priority}
				player={streamInfo.player}
				fatId={streamInfo.fatId}
			/>;
			
			if(detailLevel>=1) {
				var stream:STRM=sdat.openSTRM(i);
				streamXML.@encoding=Wave.encodingAsString(stream.encoding);
				streamXML.@sampleCount=stream.sampleCount;
				streamXML.@stereo=(stream.stereo?"true":"false");
				streamXML.@sampleRate=stream.sampleRate;
				if(stream.loop) {
					streamXML.@loopPoint=stream.loopPoint;
				}
			}
			
			if(sdat.hasSymbols) {
				streamXML.@symbol=sdat.streamSymbols[i];
			}
			streamRootXML.appendChild(streamXML);
		}
		
		return rootXML;
	}
}

function listSymbols(type:String,symb:Vector.<String>):XML {
	var rootXML:XML=<{type} />;
	
	for each(var name:String in symb) {
		rootXML.appendChild(<symbol name={name} />);
	}
	
	return rootXML;
}