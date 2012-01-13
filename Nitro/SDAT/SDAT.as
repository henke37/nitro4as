package Nitro.SDAT {
	
	import flash.utils.*;
	
	import Nitro.*;
	import Nitro.SDAT.InfoRecords.*;
	
	use namespace sdatInternal;
	
	/** Reader for SDAT files
	
	<p>SDAT files are used by the Nintendo composer library that Nitro games practically always uses for their music and sound effects. They contain a variety of subfiles.</p> */
	
	public class SDAT {
		
		sdatInternal var sdat:ByteArray;
		
		/*
		public var streamInfo:Vector.<STRM>;
		public var soundBanks:Vector.<SBNK>;
		public var waveArchives:Vector.<SWAR>;
		public var sequences:Vector.<SSEQ>;
		public var sequenceArchives:Vector.<SSAR>;*/
		
		public var sequenceInfo:Vector.<SequenceInfoRecord>;
		public var streamInfo:Vector.<StreamInfoRecord>;
		public var sequenceArchiveInfo:Vector.<BaseInfoRecord>;
		public var waveArchiveInfo:Vector.<BaseInfoRecord>;
		
		private var files:Vector.<FATRecord>;
		
		public var seqSymbols:Vector.<String>;
		public var bankSymbols:Vector.<String>;
		public var waveArchiveSymbols:Vector.<String>;
		public var playerSymbols:Vector.<String>;
		public var groupSymbols:Vector.<String>;
		public var player2Symbols:Vector.<String>;
		public var streamSymbols:Vector.<String>;
		
		private static const infoSubSectionCount:uint=8;
		
		public function SDAT() {
			
		}
		
		/** Loads a SDAT file from a ByteArray
		@param _sdat The ByteArray to read from
		*/
		public function parse(_sdat:ByteArray):void {
			sdat=_sdat
			
			/*
			streams=new Vector.<STRM>();
			soundBanks=new Vector.<SBNK>();
			waveArchives=new Vector.<SWAR>();
			sequences=new Vector.<SSEQ>();
			sequenceArchives=new Vector.<SSAR>();*/
			
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
				parseSymb(symbPos,symbSize);
			}
			
			//loadFiles();
			
		}
		
		/* private function loadFiles():void {
			
			
			for each(var file:FATRecord in files) {
				
				var subFileData:ByteArray=new ByteArray();
				subFileData.writeBytes(sdat,file.pos,file.size);
				subFileData.position=0;
				
				var fileType:String=subFileData.readUTFBytes(4);
				subFileData.position=0;
				
				var subFile:SubFile=null;
				var container:*;
				
				switch(fileType) {
					case "STRM":
						subFile=new STRM();
						container=streams;
					break;
					
					case "SBNK":
						subFile=new SBNK();
						container=soundBanks;
					break;
					
					case "SWAR":
						subFile=new SWAR();
						container=waveArchives;
					break;
					
					case "SSAR":
						subFile=new SSAR();
						container=sequenceArchives;
					break;
					
					case "SSEQ":
						subFile=new SSEQ();
						container=sequences;
					break;
					
					default:
					break;
						throw new Error("Unknown filetype encountered");
					break;
				}
				
				try {
					subFile.parse(subFileData);
					container.push(subFile);
				} catch(e:Error) {
					container.push(null);
					trace(e.getStackTrace());
				}
			}
			
			
			streams.fixed=true;
			soundBanks.fixed=true;
			waveArchives.fixed=true;
			sequences.fixed=true;
			sequenceArchives.fixed=true;
		}*/
		
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
		
		private function openFileById(fatId:uint):ByteArray {
			if(fatId>=files.length) throw new RangeError("Can't open a file id higher than the file count!");
			
			var record:FATRecord=files[fatId];
			
			var o:ByteArray=new ByteArray();
			o.writeBytes(sdat,record.pos,record.size);
			
			o.position=0;
			
			return o;
		}
		
		public function openSSEQ(seqId:uint):SSEQ {
			var seq:SSEQ=new SSEQ();
			seq.parse(openFileById(sequenceInfo[seqId].fatId));
			
			return seq;
		}
		
		public function openSTRM(strmId:uint):STRM {
			var strm:STRM=new STRM();
			strm.parse(openFileById(streamInfo[strmId].fatId));
			
			return strm;
		}
		
		public function openSWAR(swarId:uint):SWAR {
			var swar:SWAR=new SWAR();
			swar.parse(openFileById(waveArchiveInfo[swarId].fatId));
			
			return swar;
		}
		
		private function parseInfo(infoPos:uint,infoSize:uint):void {
			var i:uint;
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
				seqRecord.cpr=info.readUnsignedByte();
				seqRecord.ppr=info.readUnsignedByte();
				seqRecord.ply=info.readUnsignedByte();
				info.position+=2;
				
				//trace(seqRecord);
				
				sequenceInfo.push(seqRecord);
			}
			sequenceInfo.fixed=true;
			
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
				streamRecord.pri=info.readUnsignedByte();
				streamRecord.ply=info.readUnsignedByte();
				info.position+=5;
				
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
		}
		
		private function parseSymbNestSubRec(symbPos:uint,recPos:uint):Vector.<Vector.<String>> {
			var o:Vector.<Vector.<String>>=new Vector.<Vector.<String>>();
			
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

class FATRecord {
	public var size:uint,pos:uint;
	
	public function FATRecord(s:uint,p:uint) {
		if(s<4) throw new ArgumentError("Files has a minimum size");
		size=s;pos=p;
	}
}