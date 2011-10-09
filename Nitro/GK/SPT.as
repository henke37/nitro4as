package Nitro.GK {
	import flash.utils.*;
	
	/** Reader and writer for GK2 script files */
	public class SPT {
		
		private var _data:ByteArray;
		
		private var sections:Vector.<SPTEntry>;
		
		private var version:uint;
		private var sizeThing:uint;
		private var unknownHeader:uint;

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
			
			unknownHeader=d.readUnsignedShort();
			
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
			}
		}
		
		public function build():void {
			_data=new ByteArray();
			_data.endian=Endian.LITTLE_ENDIAN;
			
			_data.writeUTFBytes(" TPS");
			
			_data.writeShort(version);
			_data.writeShort(sections.length);
			_data.writeShort(sizeThing);
			_data.writeShort(unknownHeader);
			
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
			var o:XML=<SPT version={version} sizeThing={sizeThing.toString(16)} unknownHeader={unknownHeader.toString(16)} />
			
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
			unknownHeader = parseInt(header.@unknownHeader,16);
			
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
		
		public function loadSection(sectionID:uint,sectionXML:XML,table:Table):void {
			if(sectionID>=sections.length) throw new ArgumentError("SectionID is larger than the list of sections!");
			if(!sectionXML) throw new ArgumentError("SectionXML can not be null!");
			
			var section:SPTEntry=sections[sectionID];
			
			section.loadScript(sectionXML,table);
		}
		
		private static function bytesToSize(bytes:uint):uint {
			return bytes/2-1;
		}
		
		private function readSection(id:uint):ByteArray {
			if(id>=sections.length) throw new RangeError("id is too high, max is "+sections.length+" but tried to read "+id+".");
			var o:ByteArray=new ByteArray();
			var entry:SPTEntry=sections[id];
			//_data.positon=entry.offset;
			o.writeBytes(_data,entry.offset,(entry.size+1)*2);
			o.position=0;
			return o;
		}
		
		public function parseSection(id:uint,table:Table=null):XML {
			
			var section:ByteArray=readSection(id);
			section.endian=Endian.LITTLE_ENDIAN;
			
			var cBuff:Vector.<uint>=new Vector.<uint>();
			var cBuffPos:uint=0;
			var inCommand:Boolean=false;
			
			var o:XML=<scriptSection id={id} />;
			var lastCommand:XML;//used to dodge a Flash bug
			
			while(section.position<section.length) {
				var word:uint=section.readUnsignedShort();
				
				var type:uint=word >> 8;
				
				switch(type) {
					case 0x55:
					case 0x54:
						if(inCommand) {
							cBuff[cBuffPos++]=word & 0xFF;
							break;
						}
					//not break
					case 0xB7:
					case 0xB6:
					case 0xB5:
					case 0xB4:
						if(inCommand) {
							lastCommand=parseCommand(cBuff);
							o.appendChild(lastCommand);
							cBuff.length=0;
							cBuffPos=0;
						}
						inCommand=true;
						cBuff[cBuffPos++]=word;
					break;
					
					default:
						if(cBuffPos) {
							lastCommand=parseCommand(cBuff)
							o.appendChild(lastCommand);
							inCommand=false;
							cBuff.length=0;
							cBuffPos=0;
						}
						
						if(table) {
							var text:String=((word & 0xFF)<<8|type).toString(16);//byte order swap and hex encoding
							text=pad(text,false,4,"0");
							text=table.matchEntry(text);
							if(lastCommand) {
								o.insertChildAfter(lastCommand,text);
								lastCommand=null;
							} else {
								o.appendChild(text);
							}
						}
					break;
				}
				//trace(word.toString(16));
			}
			if(cBuffPos) {
				lastCommand=parseCommand(cBuff);
				o.appendChild(lastCommand);
			}
			
			o.normalize();
			
			return o;
		}
		
		private function parseCommand(commandData:Vector.<uint>):XML {
			var commandType:uint=commandData.shift();
			
			var args:String="";
			
			for(var i:uint=0;i<commandData.length;++i) {
				args+=commandData[i].toString(16)+",";
			}
			args=args.substr(0,-1);
			
			switch(commandType) {
				
				case 0x55A0: return <newline/>;
				
				case 0xB422:
					return <sound args={args}/>;
				break;
				
				case 0xB47F: return <flash/>;
				
				case 0xB4A2:
					return <wait time={commandData[0]} />;
				break;
				
				case 0xB4AA:
					switch(commandData[0]) {
						case 0xAA:
							return <textWindow show="1"/>;
						break;
						
						case 0xAB:
							return <textWindow show="0"/>;
						break;
						
						default:
							return <unknownCommand commandType={commandType.toString(16)} args={args} />;
						break;
					}
				break;
				
				case 0xB4AB:
					return <speakerBadge args={args} />;
				break;
				
				case 0xB4A8: return <ack/>;
				
				case 0xB4AD:
					return <textSpeed speed={commandData[0]} />;
				break;
				
				case 0xB4AE: return <clear/>;
				
				case 0xB4FA:
					return <charAnim char={commandData[0]} anim={commandData[1]} />;
				break;
				
				case 0xB5E8: return <blue/>;
				case 0xB5E9: return <green/>;
				case 0xB5EA: return <white/>;
				case 0xB5EB: return <orange/>;
				case 0xB7A7: return <center/>;
				
				case 0xB7FE:
					return <fade args={args}/>;
				break;
			
				default:
					return <unknownCommand commandType={commandType.toString(16)} args={args} />;
				break;
			}
		}
		
		internal static function buildSection(script:XML,table:Table):ByteArray {
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			for each(var child:XML in script.children()) {
				switch(child.nodeKind()) {
					case "element":
						writeCommand(o,child);
					break;
					
					case "text":
						writeText(o,table,String(child));
					break;
					
					case "comment":
					break;
					
					default:
						throw new ArgumentError("Unknown nodekind:"+child.nodeKind());
					break;
				}
			}
			
			return o;
		}
		
		private static function writeText(o:ByteArray,table:Table,text:String):void {
			
			for(var pos:uint=0;pos<text.length;++pos) {
				var char:String=text.substr(pos,1);
				
				var hexString:String;
				
				if(char=="<") {
					if(text.substr(pos+1,1)=="$") {
						var endPos:int=text.indexOf(">",pos+2);
						hexString=text.substring(pos+2,endPos);
						pos=endPos;
					}
				} else {
					hexString=table.matchReverseEntry(char);
				}
				
				hexString=hexString.substr(2,2)+hexString.substr(0,2);
				
				var toWrite:uint=parseInt(hexString,16);
				o.writeShort(toWrite);
			}
		}
		
		private static function writeCommand(o:ByteArray,command:XML):void {
			var args:Vector.<uint>;
			
			if(command.@args) {
				args=argsStringToVector(command.@args);
			}
			
			//trace(String(command.name()));
			
			switch(String(command.name())) {//new <uint>[0x55A0]
				case "newline": writeRawCommand(o,0x55A0); break;
				case "sound": writeRawCommand(o,0xB422,args); break;
				case "flash": writeRawCommand(o,0xB47F); break;
				case "wait": writeRawCommand(o,0xB4A2,new <uint>[parseInt(command.@time)]); break;
				case "textWindow":
					if(command.@show=="1") {
						writeRawCommand(o,0xB4AA,new <uint>[0xAA]);
					} else if(command.@show=="0") {
						writeRawCommand(o,0xB4AA,new <uint>[0xAB]);
					} else {
						throw new ArgumentError("Invalid show value for textWindow command");
					}
				break;
				case "speakerBadge": writeRawCommand(o,0xB4A8,args); break;
				case "ack": writeRawCommand(o,0xB4A8); break;
				case "textSpeed": writeRawCommand(o,0xB4AD,new <uint>[parseInt(command.@speed)]); break;
				case "clear": writeRawCommand(o,0xB4AE);
				case "charAnim":
					writeRawCommand(o,0xB4FA,new <uint>[parseInt(command.@char),parseInt(command.@anim)]);
				break;
				case "blue": writeRawCommand(o,0xB5E8); break;
				case "green": writeRawCommand(o,0xB5E9); break;
				case "white": writeRawCommand(o,0xB5EA); break;
				case "orange": writeRawCommand(o,0xB5EB); break;
				case "center": writeRawCommand(o,0xB7A7); break;
				case "fade": writeRawCommand(o,0xB7FE,args); break;
				case "unknownCommand":
					writeRawCommand(o,parseInt(command.@commandType,16),args);
				break;
				
				default:
					throw new ArgumentError("Unknown command \""+command.name()+"\"!");
				break;
			}
		}
		
		private static function argsStringToVector(args:String):Vector.<uint> {
			var pieces:Array=args.split(",");
			var o:Vector.<uint>=new Vector.<uint>(pieces.length);
			for(var i:uint=0;i<o.length;++i) {
				o[i]=parseInt(pieces[i],16);
			}
			return o;
		}
		
		private static function writeRawCommand(o:ByteArray,command:uint,args:Vector.<uint>=null):void {
			o.writeShort(command);
			
			if(!args) return;
			
			for(var i:uint=0;i<args.length;++i) {
				o.writeShort(0x5500|args[i]);
			}

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
