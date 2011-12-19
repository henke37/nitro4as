package Nitro.Graphics3D {
	
	import Nitro.*;
	
	import flash.utils.*;
	
	public class SectionedFile3D extends SectionedFile {

		public function SectionedFile3D() {
			// constructor code
		}
		
		/** Loads a file from a ByteArray
		@param d The ByteArray to load from*/
		public override function parse(d:ByteArray):void {
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
			
			var sectionTablePos:uint=d.position;
			
			for(var i:uint=0;i<subSectionCount;++i) {
				
				d.position=sectionTablePos+i*4;
				var sectionOffset:uint=d.readUnsignedInt();
				
				d.position=sectionOffset;
				var section:Section=new Section();
				section.id=d.readUTFBytes(4);
				section.size=d.readUnsignedInt();
				section.offset=sectionOffset;
				
				sections[section.id]=section;
				
				sectionOffset+=section.size;
			}
			
		}
		
		/** Builds a file from the given
		@param id The new main id of the file
		@param sectionList An Object containing ByteArrays for the sections in the file. */
		public function build(id:String,sectionList:Object):void {
			throw new Error("Not implemented!");
		}

	}
	
}
