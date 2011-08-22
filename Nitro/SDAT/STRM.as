package Nitro.SDAT {
	
	import flash.utils.*;
	
	import Nitro.*;
	
	use namespace strmInternal;
	
	public class STRM extends SubFile {
		
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
		
		strmInternal var sampleData:ByteArray;

		public function STRM() {
			
		}
		
		public override function parse(data:ByteArray):void {
			if(!data) {
				throw new ArgumentError("data can not be null!");
			}
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="STRM") {
				throw new ArgumentError("Invalid STRM block, wrong type id "+sections.id);
			}

			readHEAD(sections.open("HEAD"));

			sampleData=sections.open("DATA");
		}
		
		private function readHEAD(section:ByteArray):void {
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			encoding=section.readUnsignedByte();
			loop=section.readBoolean();
			channels=section.readUnsignedByte();
			section.position+=1;
			sampleRate=section.readUnsignedShort();
			section.position+=2;
			loopPoint=section.readUnsignedInt();
			sampleCount=section.readUnsignedInt();
			dataPos=section.readUnsignedInt();
			nBlock=section.readUnsignedInt();
			blockLength=section.readUnsignedInt();
			blockSamples=section.readUnsignedInt();
			lastBlockLength=section.readUnsignedInt();
			lastBlockSamples=section.readUnsignedInt();
			
			if(loop) {
				if(loopPoint>sampleCount) {
					throw new ArgumentError("Invalid STRM, loopPoint>sampleCount");
				}
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
