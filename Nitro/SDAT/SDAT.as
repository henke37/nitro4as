package Nitro.SDAT {
	
	import flash.utils.*;
	
	import Nitro.*;
	import Nitro.SDAT.InfoRecords.*;
	
	use namespace sdatInternal;
	
	/** Reader for SDAT files
	
	<p>SDAT files are used by the Nintendo composer library that Nitro games practically always uses for their music and sound effects. They contain a variety of subfiles.</p> */
	
	public class SDAT {
		
		sdatInternal var sdat:ByteArray;
		
		/** The info records for all standalone sequences stored in the SDAT file */
		public var sequenceInfo:Vector.<SequenceInfoRecord>;
		/** The info records for all audio streams stored in the SDAT file */
		public var streamInfo:Vector.<StreamInfoRecord>;
		/** The info records for all archived sequences stored in the SDAT file */
		public var sequenceArchiveInfo:Vector.<BaseInfoRecord>;
		/** The info records for all wave archives stored in the SDAT file */
		public var waveArchiveInfo:Vector.<BaseInfoRecord>;
		/** The info records for all instrument banks stored in the SDAT file */
		public var bankInfo:Vector.<BankInfoRecord>;
		/** The info records for all groups stored in the SDAT file */
		public var groupInfo:Vector.<GroupInfoRecord>;
		/** The info records for all sequence players in the SDAT file */
		public var playerInfo:Vector.<PlayerInfoRecord>;
		
		
		sdatInternal var files:Vector.<FATRecord>;
		
		public var seqSymbols:Vector.<String>;
		public var seqArchiveSymbols:Vector.<SeqArcSymbRecord>;
		public var bankSymbols:Vector.<String>;
		public var waveArchiveSymbols:Vector.<String>;
		public var playerSymbols:Vector.<String>;
		public var groupSymbols:Vector.<String>;
		public var player2Symbols:Vector.<String>;
		public var streamSymbols:Vector.<String>;
		
		public var hasSymbols:Boolean;
		
		private static const infoSubSectionCount:uint=8;
		
		public function SDAT() {
			
		}
		
		/** Loads a SDAT file from a ByteArray
		@param _sdat The ByteArray to read from
		*/
		public function parse(_sdat:ByteArray):void {
			sdat=_sdat;
			
			var type:String=sdat.readUTFBytes(4);
			if(type!="SDAT") {
				throw new ArgumentError("Not a SDAT, incorrect header type");
			}
			
			sdat.endian=Endian.LITTLE_ENDIAN;
			
			/*sdat.position=12;
			var structSize:uint=sdat.readUnsignedShort();
			if(structSize!=0x10) {
				throw new ArgumentError("Invalid SDAT, incorrect header size");
			}*/
			
			sdat.position=14;
			var numBlocks:uint=sdat.readUnsignedShort();
			
			var symbSize:uint,symbPos:uint;
			symbPos=sdat.readUnsignedInt();
			symbSize=sdat.readUnsignedInt();
			var hasSymb:Boolean=symbPos!=0;
			
			var infoSize:uint,infoPos:uint;
			infoPos=sdat.readUnsignedInt();
			infoSize=sdat.readUnsignedInt();
			
			var fatSize:uint,fatPos:uint;
			fatPos=sdat.readUnsignedInt();
			fatSize=sdat.readUnsignedInt();
			
			files=parseFat(fatPos);
			
			parseInfo(infoPos,infoSize);
			
			if(hasSymb) {
				hasSymbols=true;
				parseSymb(symbPos,symbSize);
			}
			
		}
		
		private function parseFat(fatPos:uint):Vector.<FATRecord> {
			sdat.position=fatPos;
			var type:String=sdat.readUTFBytes(4);
			if(type!="FAT ") {
				throw new ArgumentError("Invalid FAT block, wrong type");
			}
			
			sdat.position=fatPos+8;
			var numRecords:uint=sdat.readUnsignedInt();
			//trace(numRecords);
			var o:Vector.<FATRecord>=new Vector.<FATRecord>();
			o.length=numRecords;
			o.fixed=true;
			for(var i:uint;i<numRecords;++i) {
				sdat.position=fatPos+12+16*i;
				var pos:uint=sdat.readUnsignedInt();
				var size:uint=sdat.readUnsignedInt();				
				o[i]=new FATRecord(size,pos);
			}
			return o;
		}
		
		/** Opens a subfile by it's FAT index
		@param fatId The orginal index into the FAT table
		@return A new ByteArray containing the data of the subfile
		*/
		public function openFileById(fatId:uint):ByteArray {
			if(fatId>=files.length) throw new RangeError("Can't open a file id higher than the file count!");
			
			var record:FATRecord=files[fatId];
			
			var o:ByteArray=new ByteArray();
			o.writeBytes(sdat,record.pos,record.size);
			
			o.position=0;
			
			return o;
		}
		
		/** Opens a standalone sequence file
		@param seqId The id of the sequence to open
		@return The opened standalone sequence file*/
		public function openSSEQ(seqId:uint):SSEQ {
			var seq:SSEQ=new SSEQ();
			seq.parse(openFileById(sequenceInfo[seqId].fatId));
			
			return seq;
		}
		
		/** Opens a sequence archie file
		@param archId The id of the archive to open
		@return The opened archive file */
		public function openSSAR(archId:uint):SSAR {
			var ssar:SSAR=new SSAR();
			ssar.parse(openFileById(sequenceArchiveInfo[archId].fatId));
			
			return ssar;
		}
		
		/** Opens an audio stream file
		@param strmId The id of the stream to open
		@return The opened stream file*/
		public function openSTRM(strmId:uint):STRM {
			var strm:STRM=new STRM();
			strm.parse(openFileById(streamInfo[strmId].fatId));
			
			return strm;
		}
		
		/** Opens a wave bank file
		@param swarId The id of the wave archive file
		@return The opened wave archive file*/
		public function openSWAR(swarId:uint):SWAR {
			var swar:SWAR=new SWAR();
			swar.parse(openFileById(waveArchiveInfo[swarId].fatId));
			
			return swar;
		}
		
		/** Opens an instrument bank file
		@param bankId The id of the instrument bank file
		@return The opened instrument bank file*/
		public function openBank(bankId:uint):SBNK {
			var bank:SBNK=new SBNK();
			bank.parse(openFileById(bankInfo[bankId].fatId));
			
			return bank;
		}
		
		private function parseInfo(infoPos:uint,infoSize:uint):void {
			var i:uint,j:uint;
			var offset:uint;
			
			var info:ByteArray=new ByteArray();
			info.writeBytes(sdat,infoPos,infoSize);
			info.position=0;
			info.endian=Endian.LITTLE_ENDIAN;
			
			var type:String=info.readUTFBytes(4);
			if(type!="INFO") throw new ArgumentError("Invalid INFO block, wrong type!");
			
			var internalSize:uint=info.readUnsignedInt();
			if(internalSize!=infoSize) throw new ArgumentError("Invalid INFO block, internal size does not match with external size!");
			
			var infoSectionOffsets:Vector.<uint>=new Vector.<uint>();
			infoSectionOffsets.length=infoSubSectionCount;
			infoSectionOffsets.fixed=true;
			
			for(i=0;i<infoSubSectionCount;++i) {
				infoSectionOffsets[i]=info.readUnsignedInt();
			}
			
			
			//read the sequence info
			info.position=infoSectionOffsets[0];
			var sequenceCount:uint=info.readUnsignedInt();
			
			var sequenceInfoOffsets:Vector.<uint>=readInfoRecordPtrTable(info,sequenceCount);
			
			sequenceInfo=new Vector.<SequenceInfoRecord>;
			
			for(i=0;i<sequenceCount;++i) {
				var seqRecord:SequenceInfoRecord=new SequenceInfoRecord();
				
				offset=sequenceInfoOffsets[i];
				if(offset==0) continue;
				info.position=offset;
				
				seqRecord.fatId=info.readUnsignedShort();
				info.position+=2;
				seqRecord.bankId=info.readUnsignedShort();
				seqRecord.vol=info.readUnsignedByte();
				seqRecord.channelPriority=info.readUnsignedByte();
				seqRecord.playerPriority=info.readUnsignedByte();
				seqRecord.player=info.readUnsignedByte();
				info.position+=2;
				
				//trace(seqRecord);
				
				sequenceInfo.push(seqRecord);
			}
			sequenceInfo.fixed=true;
			
			
			
			
			//read the sequence archive info
			info.position=infoSectionOffsets[1];
			var sequenceArchiveCount:uint=info.readUnsignedInt();
			
			var sequenceArchiveInfoOffsets:Vector.<uint>=readInfoRecordPtrTable(info,sequenceArchiveCount);
			
			sequenceArchiveInfo=new Vector.<BaseInfoRecord>;
			for(i=0;i<sequenceArchiveCount;++i) {
				var sequenceArchiveRecord:BaseInfoRecord=new BaseInfoRecord();
				
				offset=sequenceArchiveInfoOffsets[i];
				if(offset==0) continue;
				info.position=offset;
				
				sequenceArchiveRecord.fatId=info.readUnsignedShort();
				
				sequenceArchiveInfo.push(sequenceArchiveRecord);
			}
			sequenceArchiveInfo.fixed=true;
			
			
			
			//read the bank info
			info.position=infoSectionOffsets[2];
			var bankCount:uint=info.readUnsignedInt();
			
			var bankInfoOffsets:Vector.<uint>=readInfoRecordPtrTable(info,bankCount);
			
			bankInfo=new Vector.<BankInfoRecord>;
			
			for(i=0;i<bankCount;++i) {
				var bankRecord:BankInfoRecord=new BankInfoRecord();
				
				offset=bankInfoOffsets[i];
				if(offset==0) continue;
				info.position=offset;
				
				bankRecord.fatId=info.readUnsignedShort();
				info.position+=2;
				
				for(j=0;j<4;++j) {
					bankRecord.swars[j]=info.readShort();
				}
				
				//trace(bankRecord);
				
				bankInfo.push(bankRecord);
			}
			bankInfo.fixed=true;
			
			
			
			//read the wave archive info
			info.position=infoSectionOffsets[3];
			var waveArchiveCount:uint=info.readUnsignedInt();
			
			var waveArchiveInfoOffsets:Vector.<uint>=readInfoRecordPtrTable(info,waveArchiveCount);
			
			waveArchiveInfo=new Vector.<BaseInfoRecord>;
			for(i=0;i<waveArchiveCount;++i) {
				var waveArchiveRecord:BaseInfoRecord=new BaseInfoRecord();
				
				offset=waveArchiveInfoOffsets[i];
				if(offset==0) continue;
				info.position=offset;
				
				waveArchiveRecord.fatId=info.readUnsignedShort();
				
				waveArchiveInfo.push(waveArchiveRecord);
			}
			waveArchiveInfo.fixed=true;
			
			
			
			info.position=infoSectionOffsets[4];
			var playerCount:uint=info.readUnsignedInt();
			var playerInfoOffsets:Vector.<uint>=readInfoRecordPtrTable(info,playerCount);
			
			playerInfo=new Vector.<PlayerInfoRecord>(playerCount);
			for(i=0;i<playerCount;++i) {
				offset=playerInfoOffsets[i];
				if(offset==0) continue;
				info.position=offset;				
				
				var playerRecord:PlayerInfoRecord=new PlayerInfoRecord();
				playerRecord.maxSequences=info.readUnsignedByte();
				info.position+=1;
				playerRecord.channels=info.readUnsignedShort();
				playerRecord.heapSize=info.readUnsignedInt();
				
				playerInfo[i]=playerRecord;
			}
			
			
			
			
			//read the group info
			info.position=infoSectionOffsets[5];
			const groupCount:uint=info.readUnsignedInt();
			
			const groupInfoOffsets:Vector.<uint>=readInfoRecordPtrTable(info,groupCount);
			groupInfo=new Vector.<GroupInfoRecord>();
			for(i=0;i<groupCount;++i) {
				offset=groupInfoOffsets[i];
				if(offset==0) continue;
				info.position=offset;
				
				var groupInfoRecord:GroupInfoRecord=new GroupInfoRecord();
				groupInfo.push(groupInfoRecord);
				
				var groupElementCount:uint=info.readUnsignedInt();
				for(j=0;j<groupElementCount;++j) {
					var itemType:uint=info.readUnsignedByte();
					var loadFlags:uint=info.readUnsignedByte();
					info.position+=2
					var itemId:uint=info.readUnsignedInt();
					var groupInfoSubRecord:GroupInfoSubRecord=new GroupInfoSubRecord(itemType,loadFlags,itemId);
					
					groupInfoRecord.entries.push(groupInfoSubRecord);
				}
			}
			
			//read the stream info
			info.position=infoSectionOffsets[7];
			var streamCount:uint=info.readUnsignedInt();
			
			var streamInfoOffsets:Vector.<uint>=readInfoRecordPtrTable(info,streamCount);
			
			streamInfo=new Vector.<StreamInfoRecord>();
			
			for(i=0;i<streamCount;++i) {
				var streamRecord:StreamInfoRecord=new StreamInfoRecord();
				
				offset=streamInfoOffsets[i];
				if(offset==0) continue;
				info.position=streamInfoOffsets[i];
				
				streamRecord.fatId=info.readUnsignedShort();
				info.position+=2;
				streamRecord.vol=info.readUnsignedByte();
				streamRecord.priority=info.readUnsignedByte();
				streamRecord.player=info.readUnsignedByte();
				streamRecord.forceStereo=info.readBoolean();
				info.position+=4;
				
				//trace(streamRecord);
				
				streamInfo.push(streamRecord);
			}
			streamInfo.fixed=true;
		}
		
		private function readInfoRecordPtrTable(info:ByteArray,count:uint):Vector.<uint> {
			var sectionRecordOffsets:Vector.<uint>=new Vector.<uint>();
			sectionRecordOffsets.length=count;
			sectionRecordOffsets.fixed=true;
			for(var i:uint=0;i<count;++i) {
				sectionRecordOffsets[i]=info.readUnsignedInt();
			}
			return sectionRecordOffsets;
		}
		
		private function parseSymb(symbPos:uint,symbSize:uint):void {
			sdat.position=symbPos;
			
			var symbType:String=sdat.readUTFBytes(4);
			sdat.endian=Endian.LITTLE_ENDIAN;
			if(symbType!="SYMB") {
				throw new ArgumentError("Invalid SYMB block, has wrong type id :"+symbType);
			}
			
			/*var symbSizeHeader:uint=sdat.readUnsignedInt();
			if(symbSize!=symbSizeHeader) {
				throw new ArgumentError("Invalid SYMB block, size does not match with header size");
			}*/
			
			
			sdat.position=symbPos+8;			
			var seqPos:uint=symbPos+sdat.readUnsignedInt();
			var seqarcPos:uint=symbPos+sdat.readUnsignedInt();
			var bankPos:uint=symbPos+sdat.readUnsignedInt();
			var waveArchivePos:uint=symbPos+sdat.readUnsignedInt();
			var playerPos:uint=symbPos+sdat.readUnsignedInt();
			var groupPos:uint=symbPos+sdat.readUnsignedInt();
			var player2Pos:uint=symbPos+sdat.readUnsignedInt();
			var strmPos:uint=symbPos+sdat.readUnsignedInt();
			
			seqSymbols         = parseSymbSubRec(symbPos,seqPos);
			bankSymbols        = parseSymbSubRec(symbPos,bankPos);
			waveArchiveSymbols = parseSymbSubRec(symbPos,waveArchivePos);
			playerSymbols      = parseSymbSubRec(symbPos,playerPos);
			groupSymbols       = parseSymbSubRec(symbPos,groupPos);
			player2Symbols     = parseSymbSubRec(symbPos,player2Pos);
			streamSymbols      = parseSymbSubRec(symbPos,strmPos);
			seqArchiveSymbols  = parseSymbNestSubRec(symbPos,seqarcPos);
		}
		
		private function parseSymbNestSubRec(symbPos:uint,recPos:uint):Vector.<SeqArcSymbRecord> {
			sdat.position=recPos;
			var numRecs:uint=sdat.readUnsignedInt();
			
			var o:Vector.<SeqArcSymbRecord>=new Vector.<SeqArcSymbRecord>(numRecs);
			
			for(var i:uint;i<numRecs;++i) {
				sdat.position=recPos+4+8*i;
				
				var arcRec:SeqArcSymbRecord=new SeqArcSymbRecord();
				
				var stringPos:uint=symbPos+sdat.readUnsignedInt();
				if(stringPos==symbPos) {
					arcRec.symbol=null;
				} else {
					arcRec.symbol=readNullString(sdat,stringPos);
				}
				
				sdat.position=recPos+4+8*i+4;
				
				var subPos:uint=sdat.readUnsignedInt()
				
				if(subPos) {
					arcRec.subSymbols=parseSymbSubRec(symbPos,subPos+symbPos);
				}
				
				o[i]=arcRec;
			}
			return o;
			
		}
		
		private function parseSymbSubRec(symbPos:uint,recPos:uint):Vector.<String> {
			sdat.position=recPos;
			var numRecs:uint=sdat.readUnsignedInt();
			var o:Vector.<String>=new Vector.<String>();
			for(var i:uint;i<numRecs;++i) {
				sdat.position=recPos+4+4*i;
				var stringPos:uint=symbPos+sdat.readUnsignedInt();
				if(stringPos==symbPos) {
					o[i]=null;
					continue;
				}
				var s:String=readNullString(sdat,stringPos);
				//trace(s);
				o[i]=s;
			}
			return o;
		}
		
		private function readVarLengthInt(b:ByteArray):uint {
			var c:uint,value:uint;
			if ( (value = b.readByte()) & 0x80 ) {
				 value &= 0x7F;
				 do
				 {
					 value = (value << 7) + ((c = b.readByte()) & 0x7F);
				 } while (c & 0x80);
			}
	
			return(value);
		}
		
		/** Finds a stream by it's symbol name
		@param name The symbol name
		@return The stream
		@throw ArgumentError There is no stream with that symbol name */
		public function getStreamByName(name:String):STRM {
			var i:uint;
			for each(var symbName:String in streamSymbols) {
				if(symbName==name) {
					return openSTRM(i);
				}
				++i;
			}
			throw new ArgumentError("Unknown stream name");
		}
	}
	
}