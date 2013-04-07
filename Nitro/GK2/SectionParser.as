﻿package Nitro.GK2 {
	
	import flash.utils.*;
	
	public class SectionParser {
		
		private var section:ByteArray;

		public function SectionParser(section:ByteArray) {
			this.section=section;
		}
		
		public function parse():XML {
			
			var o:XML=<scriptSection/>;
			
			parseLoop: while(section.position<section.length) {
				var word:uint=section.readUnsignedShort();
				
				var type:uint=word >> 8;
				
				var toAppend:*;
				var lastCommand:XML;
				
				switch(type) {
					case 0x00:
					case 0x01:
						if(word==0x000A) {
							toAppend=<br/>;
						} else {
							toAppend=<unknown data={word.toString(16)} />;
						}
					break;
					
					case 0xE0:
					case 0xE1:
					case 0xE2:
					case 0xE3:
					case 0xE4:
					case 0xE5:
					case 0xE6:
					case 0xE7:
					case 0xE8:/*
					case 0xE9:
					case 0xEA:
					case 0xEB:
					case 0xEC:
					case 0xED:
					case 0xEE:
					case 0xEF:*/
						toAppend=parseCommand(word);
					break;
					
					default:
						var text:String=String.fromCharCode(word);
						toAppend=text;
					break;
				}
				
				if(lastCommand) {
					o.insertChildAfter(lastCommand,toAppend);
					lastCommand=null;
				} else {
					o.appendChild(toAppend);
				}
				
				lastCommand=toAppend as XML;
				//trace(word.toString(16));
			}
			
			o.normalize();
			
			return o;
		}
		
		private function parseCommand(commandType:uint):XML {			
			
			switch(commandType) {
				
				case 0xE040: return <whiteText/>;
				case 0xE041: return <orangeText/>;
				case 0xE042: return <blueText/>;
				case 0xE043: return <greenText/>;
				
				case 0xE081:
					return <jumpToSection section={section.readUnsignedShort()} />;
				break;
				
				case 0xE100:
					switch(section.readShort()) {
						case 0:
							return <showTextWindow />;
						break;
						
						case 1:
							return <hideTextWindow />;
						break;
						
						default:
							return <unknownCommand commandType={commandType.toString(16)}  />;
						break;
					}
				break;
					
				case 0xE101:
					return speakerBadge();
				break;
				
				case 0xE102: return <ack/>;
				
				case 0xE104: return <clear/>;
				
				case 0xE107:
					return <textSpeed speed={section.readShort()} />;
				break;
				
				case 0xE108:
					return <wait time={section.readShort()} />;
				break;
					
				case 0xE12F:
					return <charAnim char={section.readShort()} anim={section.readShort()} command="0xE12F"/>;
				break;
				case 0xE150:
					return <charAnim char={section.readShort()} anim={section.readShort()} command="0xE150"/>;
				break
					
				case 0xE151:
					return <miniAnim char={section.readShort()} dir={section.readShort()} anim={section.readShort()} command="0xE151"/>;
				break;					
				case 0xE155:
					return <miniAnim char={section.readShort()} dir={section.readShort()} anim={section.readShort()} command="0xE155"/>;
				break;
					
				case 0xE188:
					return <sound a={section.readShort()} b={section.readShort()} />;
				break;
				
				case 0xE1D1: return <screenShake strength="mild" />;
				case 0xE1D5: return <flash length="medium" />;
				case 0xE1DA: return <screenShake strength="moderate" />;
				
				case 0xE20D: return <center/>;
				case 0xE280: return <flashAndShake strength="medium" command="0xE280" />;
				case 0xE281: return <flashAndShake strength="moderate" command="0xE281" />;
				case 0xE285: return <flash length="short" />;
				
				case 0xE254:
					return <fadeToImage a={section.readShort()} b={section.readShort()} c={section.readShort()} d={section.readShort()} />;
				break;
				
				//guessed but not confirmed commands
				
				case 0xE173:
					return <playSoundEffectAndStopMusic a={section.readShort(); } confirmed="educated guess" />;
				break;

				case 0xE17A:
					return <musicThingy />;//music enable/select
				break;
					
				//case 0xE175:
					//return <music confirmed="just a guess"/>;//music change?
					//not music change
				//break;
				
				//case 0xE118: music select or music mute?
				
				//unknown pairs 'n stuff
					
				
				
				case 0xE195://one of these tween in the 
				case 0xE10F://court record button
				
				
				
					
				case 0xE153://one is show fullscreen image
				case 0xE118://one is a moderate/controllable shake
				
				case 0xE148://one of these is fade bg to black
				case 0xE149:
				
				case 0xE106://one of these is show logic to be gained
				case 0xE198://the other is ack
				
				case 0xE158://One of these is the slide in evidcence
				case 0xE1CE://for addition to record anim command
					
				case 0xE106://one of these is the wait for
				case 0xE1CF://screen click command
			
				default:
					return <unknownCommand commandType={commandType.toString(16)}  />;
				break;
			}
		}
		
		private function speakerBadge():XML {
			var flags:uint=section.readShort();
			var speakerId:uint=section.readShort();
			
			var windowPos:String=(flags==-1?"top":"bottom");
			
			var speaker:String;
			
			if(speakerId in speakerNames) {
				speaker=speakerNames[speakerId];
			} else {
				speaker="0x"+speakerId.toString(16);
			}
			
			return <speakerBadge windowPos={windowPos} speaker={speaker} />;
		}
		
		private static const speakerNames:Object = {
			0x00:"Edgeworth",
			0x01:"Gumshoe",
			0x02:"Kay",
			0x03:"Ema Skye",
			0x04:"Karma",
			0x05:"Gregory",
			0x06:"Badd",
			0x07:"Lang",
			0x08:"Judge",
			0x09:"Mikagami",
			0x0A:"Ichiyanagi",
			0x0B:"Shigaraki",
			0x0D:"Larry",
			0x0E:"Lotta Hearth",
			0x0F:"Missile",
			0x10:"Dijun Wang",
			0x11:"Knight",
			0x12:"Hayami",
			0x13:"DeKiller",
			0x14:"John Doe",
			0x15:"Ryouken",
			0x16:"Souta",
			0x17:"orinaka",
			0x18:"Marie",
			0x19:"Sahwit",
			0x1A:"Regina",
			0x1B:"Staff",
			0x1C:"Shimon",
			0x1D:"Issei Tenkai",
			0x1E:"Tsukasa Oyashiki",
			0x1F:"Delish Scone",
			0x20:"kazami",
			0x21:"hyoudou",
			0x22:"Will Powers",
			0x23:"Itami",
			0x24:"bansai",
			0x25:"mutou",
			0x26:"Tojiro",
			0x27:"Kagome",
			0x28:"kamei",
			0x29:"officer",
			0x2A:"Guard",
			0x2B:"kakarikan",
			0x2C:"Forensics",
			0x2D:"Payne",
			0x2E:"audience",
			0x2F:"crowd",
			0x30:"TV Staff",
			0x31:"Bodyguard",
			0x32:"Prisoner",
			0x33:"ajizou",
			0x34:"???",
			0x35:"???",
			0x36:"Driver",
			0x37:"MIB",
			0x38:"Man",
			0x39:"Woman",
			0x3A:"Speaker",
			0x3B:"reporter",
			0x3C:"Shopkeeper",
			0x3D:"???",
			0x3E:"???",
			0x3F:"BLANK",
			0x40:"BLANK",
			0x41:"BLANK",
			0x43:"???",
			0x44:"Kay"
		};
			
		private static const charAnimNames:Object={};

	}
	
}
