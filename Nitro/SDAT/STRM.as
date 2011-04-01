package Nitro.SDAT {
	
	import flash.utils.*;
	
	use namespace strmInternal;
	
	public class STRM {
		
		private var type:String;
		strmInternal var encoding:uint;
		public var loop:Boolean;
		strmInternal var channels:uint;
		public var sampleRate:uint;
		strmInternal var loopPoint:uint;
		strmInternal var sampleCount:uint;
		strmInternal var nBlock:uint;
		strmInternal var blockLength:uint;
		strmInternal var blockSamples:uint;
		strmInternal var lastBlockLength:uint;
		strmInternal var lastBlockSamples:uint;
		
		strmInternal var dataPos:uint;
		
		strmInternal var sdat:ByteArray;

		public function STRM(strmPos:uint,_sdat:ByteArray) {
			sdat=_sdat;
			if(!sdat) {
				throw new ArgumentError("sdat can not be null!");
			}
			sdat.position=strmPos;
			type=sdat.readUTFBytes(4);
			if(type!="STRM") {
				throw new ArgumentError("Invalid STRM block, wrong type id");
			}
			
			sdat.position=strmPos+16;
			var headType:String=sdat.readUTFBytes(4);
			if(headType!="HEAD") {
				throw new ArgumentError("Invalid STRM block, wrong head id");
			}
			sdat.position+=4;
			encoding=sdat.readUnsignedByte();
			loop=sdat.readBoolean();
			channels=sdat.readUnsignedByte();
			sdat.position+=1;
			sampleRate=sdat.readUnsignedShort();
			sdat.position+=2;
			loopPoint=sdat.readUnsignedInt();
			sampleCount=sdat.readUnsignedInt();
			dataPos=sdat.readUnsignedInt()+strmPos;
			nBlock=sdat.readUnsignedInt();
			blockLength=sdat.readUnsignedInt();
			blockSamples=sdat.readUnsignedInt();
			lastBlockLength=sdat.readUnsignedInt();
			lastBlockSamples=sdat.readUnsignedInt();
			
			if(loop) {
				if(loopPoint>sampleCount) {
					throw new ArgumentError("Invalid STRM, loopPoint>sampleCount");
				}
			}
			
			sdat.position=dataPos-8;//header before raw data
			var dataType:String=sdat.readUTFBytes(4);
			if(dataType!="DATA") {
				throw new ArgumentError("Invalid STRM block, incorrect DATA header type");
			}
		}
		
		public function get length():Number {
			return sampleCount/sampleRate;
		}
		
		public function get stereo():Boolean {
			return channels==2;
		}
		
		strmInternal function get sampleLength():uint {
			return encoding==1?2:1;
		}

	}
	
}
