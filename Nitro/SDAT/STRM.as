package Nitro.SDAT {
	
	import flash.utils.*;
	
	use namespace strmInternal;
	
	public class STRM {
		
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
			
			var type:String;
			
			type=sdat.readUTFBytes(4);
			if(type!="STRM") {
				throw new ArgumentError("Invalid STRM block, wrong type id "+type);
			}
			
			sdat.position=strmPos+16;
			type=sdat.readUTFBytes(4);
			if(type!="HEAD") {
				throw new ArgumentError("Invalid STRM block, wrong head id "+type);
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
			type=sdat.readUTFBytes(4);
			if(type!="DATA") {
				throw new ArgumentError("Invalid STRM block, incorrect DATA header type "+type);
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
