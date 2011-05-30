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
			
			//trace(sizeThing,d.length);
			
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
		
		private function readSection(id:uint):ByteArray {
			if(id>=sections.length) throw new RangeError("id is too high, max is "+sections.length+" but tried to read "+id+".");
			var o:ByteArray=new ByteArray();
			var entry:Entry=sections[id];
			//_data.positon=entry.offset;
			o.writeBytes(_data,entry.offset,(entry.size+1)*2);
			o.position=0;
			return o;
		}
		
		public function parseSection(id:uint,table:Table=null) {
			
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
							var text:String=(word & 0xFF).toString(16)+type.toString(16);//byte order swap and hex encoding
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
		
		private function parseCommand(commandData:Vector.<uint>) {
			var commandType:uint=commandData.shift();
			
			var args:String="";
			
			for(var i:uint=0;i<commandData.length;++i) {
				args+=commandData[i].toString(16)+",";
			}
			args=args.substr(0,-1);
			
			switch(commandType) {
				
				case 0x55A0:
					return <newline/>;
				break;
				
				case 0xB422:
					return <sound args={args}/>;
				break;
				
				case 0xB47F:
					return <flash/>;
				break;
				
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
				
				case 0xB4Ab:
					return <speakerBadge args={args} />;
				break;
				
				case 0xB4A8:
					return <waitForAdvanceButton/>;
				break;
				
				case 0xB4AD:
					return <textSpeed speed={commandData[0]} />;
				break;
				
				case 0xB4AE:
					return <clearTextWindow/>;
				break;
				
				case 0xB4FA:
					return <charAnim char={commandData[0]} anim={commandData[1]} />;
				break;
				
				case 0xB5E8:
					return <blueText/>;
				break;
				
				case 0xB5E9:
					return <greenText/>;
				break;
				
				case 0xB5EA:
					return <whiteText/>;
				break;
				
				case 0xB5EB:
					return <orangeText/>;
				break;
				
				case 0xB7A7:
					return <centerText/>;
				break;
				
				case 0xB7FE:
					return <fade args={args}/>;
				break;
			
				default:
					return <unknownCommand commandType={commandType.toString(16)} args={args} />;
				break;
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
