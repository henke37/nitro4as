package Nitro.GK2 {
	import flash.utils.*;
	
	/** Reader and writer for GK2 script files */
	public class SPT {
		
		private var _data:ByteArray;
		
		private var sections:Vector.<SPTEntry>;
		
		private var version:uint;
		private var sizeThing:uint;
		
		internal var scramblingKey:uint=0x55AA;

		public function SPT() {
			// constructor code
		}
		
		public function get data():ByteArray { return _data; }
		/** The number of sections in the file */
		public function get length():uint { return sections.length; }
		
		/** Loads a script file from a ByteArray
		@param d The ByteArray to load from
		*/
		public function parse(d:ByteArray):void {
			if(!d) throw new ArgumentError("Data can not be null!");
			
			_data=d;
			_data.endian=Endian.LITTLE_ENDIAN;
			
			var header:String=d.readUTFBytes(4);
			if(header!=" TPS") throw new ArgumentError("File header should be \" TPS\", but is \""+header+"\"!");
			
			version=d.readUnsignedShort();
			
			var sectionCount:uint=d.readUnsignedShort();
			
			sizeThing=d.readUnsignedShort();
			
			//trace(sizeThing,d.length);
			
			scramblingKey=d.readUnsignedShort();
			
			sections=new Vector.<SPTEntry>();
			sections.length=sectionCount;
			sections.fixed=true;
			
			for(var i:uint=0;i<sectionCount;++i) {
				var entry:SPTEntry=new SPTEntry();
				entry.offset=d.readUnsignedShort();
				entry.size=d.readUnsignedShort();
				entry.flag1=d.readUnsignedShort();
				entry.flag2=d.readUnsignedShort();
				
				sections[i]=entry;
				
				if(true) {
					entry.offset<<=1;
				}
			}
		}
		
		public function build():void {
			_data=new ByteArray();
			_data.endian=Endian.LITTLE_ENDIAN;
			
			_data.writeUTFBytes(" TPS");
			
			_data.writeShort(version);
			_data.writeShort(sections.length);
			_data.writeShort(sizeThing);
			_data.writeShort(scramblingKey);
			
			const dataStart:uint=_data.position+sections.length*SPTEntry.entryLength;
			var dataPosition:uint=dataStart;
			
			for(var i:uint=0;i<sections.length;++i) {
				var entry:SPTEntry=sections[i];
				_data.writeShort(dataPosition);
				_data.writeShort(bytesToSize(entry.encodedScript.length));
				_data.writeShort(entry.flag1);
				_data.writeShort(entry.flag2);
				
				dataPosition+=entry.encodedScript.length;
			}
			
			for(i=0;i<sections.length;++i) {
				entry=sections[i];
				_data.writeBytes(entry.encodedScript);
			}
		}
		
		/** Generates an XML document that lists all the sections in the file
		@return The XML document */
		public function headerToXML():XML {
			var o:XML=<SPT version={version} sizeThing={sizeThing.toString(16)} scramblingKey={scramblingKey.toString(16)} />
			
			for each(var entry:SPTEntry in sections) {
				o.appendChild(<section flag1={ entry.flag1.toString(16) } flag2={ entry.flag2.toString(16) } /> );
			}
			
			return o;
		}
		
		/** Loads a section list from an XML document
		
		<p>Note: The contents of the sections are not loaded.</p>
		
		@param header The XML document to load from
		*/
		public function loadHeader(header:XML):void {
			version= parseInt(header.@version);
			sizeThing= parseInt(header.@sizeThing,16);
			scramblingKey = parseInt(header.@scramblingKey,16);
			
			var xmlSections:XMLList=header.section;
			
			sections=new Vector.<SPTEntry>(xmlSections.length());
			
			for(var i:uint=0;i<sections.length;++i) {
				var xmlSection:XML=xmlSections[i];
				var section:SPTEntry=new SPTEntry();
				section.flag1=parseInt(xmlSection.@flag1,16);
				section.flag2=parseInt(xmlSection.@flag2,16);
				sections[i]=section;
			}
		}
		
		public function loadSection(sectionID:uint,sectionXML:XML):void {
			if(sectionID>=sections.length) throw new ArgumentError("SectionID is larger than the list of sections!");
			if(!sectionXML) throw new ArgumentError("SectionXML can not be null!");
			
			var section:SPTEntry=sections[sectionID];
			
			section.loadScript(sectionXML,this);
		}
		
		private static function bytesToSize(bytes:uint):uint {
			return bytes/2-1;
		}
		
		private function readSection(id:uint):ByteArray {
			if(id>=sections.length) throw new RangeError("id is too high, max is "+sections.length+" but tried to read "+id+".");
			
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			var entry:SPTEntry=sections[id];
			
			_data.endian=Endian.LITTLE_ENDIAN;
			_data.position=entry.offset;
			const length:uint=entry.size;
			for(var i:uint=0;i<length;++i) {
				var v:uint=_data.readUnsignedShort();
				v^=scramblingKey;
				o.writeShort(v);
			}
			o.position=0;
			return o;
		}
		
		public function parseSection(id:uint):XML {
			var section:ByteArray=readSection(id);
			section.endian=Endian.LITTLE_ENDIAN;
			
			var parser:SectionParser=new SectionParser(section);
			
			var sectionXML:XML=parser.parse();
			
			sectionXML.@id=id;
			
			return sectionXML;
		}

		private function pad(str:String,leftSide:Boolean=false,len:uint=2,padding:String=" "):String {
			while(str.length<len) {
				if(leftSide) {
					str=padding+str;
				} else {
					str+=padding;
				}
			}
			return str;
		}
	}
	
}
