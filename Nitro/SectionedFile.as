package Nitro {
	import flash.utils.*;
	
	/** A Nitro SDK standard sectioned file. */
	
	public class SectionedFile {
		
		protected var sections:Object;
		protected var _data:ByteArray;
		
		protected var mainId:String;
		
		public static const sectionHeaderSize:uint=8;
		protected static const headerSize:uint=0x10;

		public function SectionedFile() {
			// constructor code
		}
		
		/** Loads a file from a ByteArray
		@param d The ByteArray to load from*/
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
		
		/** The main id of the file. */
		public function get id():String { return mainId; }
		
		public function get data():ByteArray { return _data; }
		
		/** Returns the position in the raw data where a section is located.
		@param id The id of the section
		*/
		public function getDataOffsetForId(id:String):uint {
			var section:Section=findSection(id);
			return section.offset+sectionHeaderSize;
		}
		
		/** Locates the section data for a given section
		@param id The id of the section
		@return The section entry for the section
		*/
		public function findSection(id:String):Section {
			if(!id) throw new ArgumentError("Id can not be null!");
			if(id.length>4) throw new ArgumentError("Section names are 4 characters long!");
			
			if(!id in sections) throw new ArgumentError("Section id \""+id+"\" does not exist.");
			
			var section:Section=sections[id];
			return section;
		}
																				
		/** Opens a named section
		@param id The four letter id of the section
		@return The contents of the section
		@throw ArgumentError The id was bad*/
		public function open(id:String):ByteArray {			
			var section:Section=findSection(id);
			
			var o:ByteArray=new ByteArray();
			o.writeBytes(_data,section.offset+sectionHeaderSize,section.size-sectionHeaderSize);
			o.position=0;
			return o;
		}
		
		/** Checks if the file has a section with a given name.
		@param id The section name
		@return If the section exists or not*/
		public function hasSection(id:String):Boolean {
			if(!id) throw new ArgumentError("Id can not be null!");
			if(id.length>4) throw new ArgumentError("Section names are 4 characters long!");
			
			return id in sections;
		}
		
		/** Builds a file from the given
		@param id The new main id of the file
		@param sectionList An Object containing ByteArrays for the sections in the file. */
		public function build(id:String,sectionList:Object):void {
			_data=new ByteArray();
			_data.endian=Endian.LITTLE_ENDIAN;
			
			var totalSize:uint=headerSize;
			
			var sectionCount:uint=0;
			
			for each(var sectionData:ByteArray in sectionList) {
				totalSize+=sectionData.length;
				++sectionCount;
			}
			totalSize+=sectionHeaderSize*sectionCount;
			
			_data.writeUTFBytes(id);
			_data.writeUnsignedInt(0x0100FEFF);
			_data.writeUnsignedInt(totalSize);
			_data.writeShort(headerSize);
			_data.writeShort(sectionCount);
			
			for(var sectionID:String in sectionList) {
				_data.writeUTFBytes(sectionID);
				sectionData=sectionList[sectionID];
				_data.writeUnsignedInt(sectionData.length+sectionHeaderSize);
				_data.writeBytes(sectionData);
			}
		}

	}
	
}

