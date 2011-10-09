package Nitro.GK {
	import flash.utils.*;
	
	/** Reader and writer for GK 2 subarchives */
	public class GKSubarchive {
		
		private var offsets:Vector.<uint>;
		private var _data:ByteArray;

		public function GKSubarchive() {
			// constructor code
		}
		
		/** Loads a subarchive from a ByteArray
		@param data The ByteArray to load from
		*/
		public function parse(data:ByteArray):void {
			
			_data=data;
			data.endian=Endian.LITTLE_ENDIAN;
			
			offsets=new Vector.<uint>();
			
			var firstFile:uint=data.readUnsignedInt();
			offsets.push(firstFile);
			
			while(data.position<firstFile) {
				var offset:uint=data.readUnsignedInt();
				if(offset>data.length) throw new ArgumentError("Offset that points outside of the file found");
				offsets.push(offset);
			}
			offsets.fixed=true;
		}
		
		/** The number of files in the subarchive */
		public function get length():uint { return offsets.length; }
		
		/** Opens a file in the subarchive
		@param id The numerical index for the file
		@throws RangeError The id argument is bigger than the number of files
		@return A new ByteArray with the conents of the subfile */
		public function open(id:uint):ByteArray {
			if(id>=offsets.length) throw new RangeError("The id argument is bigger than the number of files");
			var o:ByteArray=new ByteArray();
			if(id+1==offsets.length) {
				o.writeBytes(_data,offsets[id]);
			} else {
				var len:uint=offsets[id+1]-offsets[id];
				o.writeBytes(_data,offsets[id],len);
			}
			
			o.position=0;
			return o;
		}
		
		/** Builds an archive from a vector
		@param files The files to inclue in the archive
		*/
		public function build(files:Vector.<ByteArray>):void {
			_data=new ByteArray();
			_data.endian=Endian.LITTLE_ENDIAN;
			
			var offset:uint=(files.length)*4;
			
			offsets=new Vector.<uint>();
			
			for each(var file:ByteArray in files) {
				_data.writeUnsignedInt(offset);
				
				offsets.push(offset);
				
				offset+=file.length;
			}
			
			for each(file in files) {
				_data.writeBytes(file);
			}
			_data.position=0;
		}
		
		public function get data():ByteArray { return _data; }

	}
	
}
