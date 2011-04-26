package Nitro {
	import flash.utils.*;
	
	public class SectionedFile {
		
		private var sections:Object;
		private var _data:ByteArray;
		
		private var mainId:String;
		
		private static const sectionHeaderSize:uint=8;

		public function SectionedFile() {
			// constructor code
		}
		
		public function parse(d:ByteArray):void {
			if(!d) throw new ArgumentError("Data can not be null");
			
			_data=d;
			
			_data.endian=Endian.LITTLE_ENDIAN;
			
			mainId=d.readUTFBytes(4);
			
			var magic:uint=d.readUnsignedInt();
			
			//if(magic!=0x0100FEFF) throw new ArgumentError("Magic has to be 0x0100FEFF, is 0x"+magic.toString(16));
			
			var sectionSize:uint=d.readUnsignedInt();
			
			var headerSize:uint=d.readUnsignedShort();
			
			if(headerSize!=0x10) throw new ArgumentError("Header size has to be 0x10, is 0x"+headerSize.toString(16));
			
			var subSectionCount:uint=d.readUnsignedShort();
			
			sections={};
			
			var sectionOffset:uint=d.position;
			
			for(var i:uint=0;i<subSectionCount;++i) {
				d.position=sectionOffset;
				var section:Section=new Section();
				section.id=d.readUTFBytes(4);
				section.size=d.readUnsignedInt();
				section.offset=sectionOffset;
				
				sections[section.id]=section;
				
				sectionOffset+=section.size;
			}
			
		}
		
		public function get id():String { return mainId; }
		
		public function get data():ByteArray { return _data; }
		
		public function open(id:String):ByteArray {
			
			if(!id) throw new ArgumentError("Id can not be null!");
			if(id.length>4) throw new ArgumentError("Section names are 4 characters long!");
			
			if(!id in sections) throw new ArgumentError("Section id \""+id+"\" does not exist.");
			
			var section:Section=sections[id];
			
			var o:ByteArray=new ByteArray();
			o.writeBytes(_data,section.offset+sectionHeaderSize,section.size-sectionHeaderSize);
			o.position=0;
			return o;
		}

	}
	
}

class Section {
	public var size:uint;
	public var offset:uint;
	public var id:String;
}