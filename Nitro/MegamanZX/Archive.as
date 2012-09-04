package Nitro.MegamanZX {
	
	import flash.utils.*;
	
	import Nitro.Compression.*;
	
	public class Archive {

		private var slots:Vector.<ArchiveSlot>;
		
		private var data:ByteArray;

		public function Archive() {
			// constructor code
		}
		
		public function parse(ba:ByteArray):void {
			if(!ba) throw new ArgumentError("ba can't be null!");
			data=ba;
			
			ba.endian=Endian.LITTLE_ENDIAN;
			var slotCount:uint=ba.readUnsignedInt();
			
			slots=new Vector.<ArchiveSlot>(slotCount+1,true);
			
			for(var i:uint=0;i<=slotCount;++i) {
				var field:uint=ba.readUnsignedInt();
				var slot:ArchiveSlot=new ArchiveSlot();
				slot.compressed=Boolean(field & 0x80000000);
				slot.offset=field & ~0x80000000;
				slots[i]=slot;
			}
		}
		
		public function get length():uint { return slots.length-1; }
		
		/**
		Opens a file with a given index
		@param id The file index number
		@return A new ByteArray with the contents of the file
		@throws RangeError Id is too high!*/
		public function open(id:uint):ByteArray {
			
			if(id>=length) throw new RangeError("Id is too high!");
			
			var ba:ByteArray=new ByteArray();
			var thisSlot:ArchiveSlot=slots[id];
			var nextSlot:ArchiveSlot=slots[id+1];
			var len:uint=nextSlot.offset-thisSlot.offset;
			ba.writeBytes(data,thisSlot.offset,len);
			
			ba.endian=Endian.LITTLE_ENDIAN;
			ba.position=0;
			
			if(thisSlot.compressed) {
				ba=Stock.decompress(ba);
			}
			
			return ba;
		}

	}
	
}

class ArchiveSlot {
	public var compressed:Boolean;
	public var offset:uint;
}