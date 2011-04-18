package Nitro.Graphics {
	
	import flash.utils.*;
	
	public class NCLR {
		
		public var colors:Vector.<uint>;
		
		private const sectionOffset:uint=0x10;
		
		public var bitDepth:uint;

		public function NCLR() {
		}
		
		public function parse(data:ByteArray):void {
			var type:String;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			type=data.readUTFBytes(4);
			if(type!="RLCN") throw new ArgumentError("Incorrect file header, type is "+type);
			
			data.position=sectionOffset;
			type=data.readUTFBytes(4);
			if(type!="TTLP") throw new ArgumentError("Incorrect file header, section type is "+type);
			
			data.position=sectionOffset+8;
			bitDepth=1 << (data.readUnsignedShort()-1);
			
			data.position=sectionOffset+0x14;
			var paletteSize:uint=data.readUnsignedInt();
			
			if(bitDepth==4) {
				paletteSize=256;
			}
			
			colors=new Vector.<uint>();
			colors.length=paletteSize;
			
			for(var i:uint=0;i<paletteSize;++i) {
				colors[i]=read555Color(data);
			}
		}

	}
	
}
