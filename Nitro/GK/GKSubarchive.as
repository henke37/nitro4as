package Nitro.GK {
	import flash.utils.*;
	
	public class GKSubarchive {
		
		private var offsets:Vector.<uint>;
		private var _data:ByteArray;

		public function GKSubarchive() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			
			_data=data;
			data.endian=Endian.LITTLE_ENDIAN;
			
			offsets=new Vector.<uint>();
			
			var firstFile:uint=data.readUnsignedInt();
			offsets.push(firstFile);
			
			while(data.position<firstFile) {
				offsets.push(data.readUnsignedInt());
			}
			offsets.fixed=true;
		}
		
		public function get length():uint { return offsets.length; }
		
		public function open(id:uint):ByteArray {
			var o:ByteArray=new ByteArray();
			if(id+1==offsets.length) {
				o.writeBytes(_data,offsets[id]);
			} else {
				var len:uint=offsets[id+1]-offsets[id]-1;
				o.writeBytes(_data,offsets[id],len);
			}
			
			o.position=0;
			return o;
		}

	}
	
}
