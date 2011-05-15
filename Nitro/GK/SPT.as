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
		
		private function readSection(id:uint):ByteArray {
			if(id>=sections.length) throw new RangeError("id is too high, max is "+sections.length+" but tried to read "+id+".");
			var o:ByteArray=new ByteArray();
			var entry:Entry=sections[id];
			//_data.positon=entry.offset;
			o.writeBytes(_data,entry.offset,(entry.size+1)*2);
			o.position=0;
			return o;
		}
		
		public function parseSection(id:uint) {
			
			var section:ByteArray=readSection(id);
			section.endian=Endian.LITTLE_ENDIAN;
			
			var cBuff:Vector.<uint>=new Vector.<uint>();
			var cBuffPos:uint=0;
			var inCommand:Boolean=false;
			
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
							parseCommand(cBuff);
							cBuff.length=0;
							cBuffPos=0;
						}
						inCommand=true;
						cBuff[cBuffPos++]=word;
					break;
					
					default:
						if(cBuffPos) {
							parseCommand(cBuff);
							inCommand=false;
							cBuff.length=0;
							cBuffPos=0;
						}
					break;
				}
				//trace(word.toString(16));
			}
			if(cBuffPos) {
				parseCommand(cBuff);
			}
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
					trace("newline");
				break;
				
				case 0xB422:
					trace("sound",args);
				break;
				
				case 0xB47F:
					trace("flash");
				break;
				
				case 0xB4A2:
					trace("wait",commandData[0]);
				break;
				
				case 0xB4AA:
					switch(commandData[0]) {
						case 0xAA:
							trace("show text window");
						break;
						
						case 0xAB:
							trace("hide text window");
						break;
						
						default:
							trace("unknown command",commandType.toString(16),args);
						break;
					}
				break;
				
				case 0xB4Ab:
					trace("speaker badge",args);
				break;
				
				case 0xB4A8:
					trace("wait for advance button");
				break;
				
				case 0xB4AD:
					trace("text speed="+commandData[0]);
				break;
				
				case 0xb4AE:
					trace("clear window");
				break;
				
				case 0xB5E8:
					trace("blue text");
				break;
				
				case 0xB5E9:
					trace("green text");
				break;
				
				case 0xB5EA:
					trace("white text");
				break;
				
				case 0xB5EB:
					trace("orange text");
				break;
				
				case 0xB7A7:
					trace("center text");
				break;
				
				case 0xB7FE:
					trace("fade",args);
				break;
			
				default:
					trace("unknown command",commandType.toString(16),args);
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
