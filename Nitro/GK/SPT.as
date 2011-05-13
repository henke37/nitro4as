package Nitro.GK {
	import flash.utils.*;
	
	public class SPT {
		
		private var _data:ByteArray;
		
		public var sections:Vector.<Entry>;

		public function SPT() {
			// constructor code
		}
		
		public function get data():ByteArray { return _data; }
		public function get length():uint { return sections.length; }
		
		public function parse(d:ByteArray):void {
			if(!d) throw new ArgumentError("Data can not be null!");
			
			_data=d;
			_data.endian=Endian.LITTLE_ENDIAN;
			
			var header:String=d.readUTFBytes(4);
			if(header!=" TPS") throw new ArgumentError("File header should be \" TPS\", but is \""+header+"\"!");
			
			var version:uint=d.readUnsignedShort();
			
			var sectionCount:uint=d.readUnsignedShort();
			
			var sizeThing:uint=d.readUnsignedShort();
			
			var unknown:uint=d.readUnsignedShort();
			
			sections=new Vector.<Entry>();
			sections.length=sectionCount;
			sections.fixed=true;
			
			for(var i:uint=0;i<sectionCount;++i) {
				var entry:Entry=new Entry();
				entry.offset=d.readUnsignedShort();
				entry.size=d.readUnsignedShort();
				entry.flag1=d.readUnsignedShort();
				entry.flag2=d.readUnsignedShort();
				
				sections[i]=entry;
			}
		}

	}
	
}

class Entry {
	public var offset:uint;
	public var size:uint;
	public var flag1:uint;
	public var flag2:uint;
}
