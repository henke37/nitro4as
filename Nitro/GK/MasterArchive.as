package Nitro.GK {
	import flash.utils.*;
	
	/** A parser for the romdata.bin file from AAI */
	public class MasterArchive {
		
		private var data:ByteArray;
		
		private var offsets:Vector.<uint>;
		
		private static const rowLen:uint=4;
		private static const tableStart:uint=8;

		public function MasterArchive() {
			// constructor code
		}
		
		/** Loads the archive from a ByteArray
		@param data The ByteArray to load from
		@throws ArgumentError Data can't be null!*/
		public function parse(data:ByteArray):void {
			if(!data) throw new ArgumentError("Data can't be null!");
			this.data=data;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			var tableLen:uint=data.readUnsignedInt();
			var count:uint=tableLen/rowLen-1;
			
			offsets=new Vector.<uint>(count,true);
			
			data.position=tableStart;
			
			for(var i:uint=0;i<count;++i) {
				var offset:uint=data.readUnsignedInt();
				offsets[i]=offset;
			}
		}
		
		/** The number of files in the archive */
		public function get length():uint { return offsets.length-1;}
		
		/**
		Opens a file with a given index
		@param id The file index number
		@return A new ByteArray with the contents of the file
		@throws RangeError Id is too high!*/
		public function open(id:uint):ByteArray {
			if(id>=length) throw new RangeError("ID must be less than the length of the archive!");
			data.position=offsets[id];
			var len:uint=data.readUnsignedInt();
			
			var o:ByteArray=new ByteArray();
			
			data.readBytes(o,0,len);
			
			return o;
		}

	}
	
}
