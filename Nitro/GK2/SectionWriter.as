package Nitro.GK2 {
	import flash.utils.*;
	
	public class SectionWriter {
		
		private var spt:SPT;

		public function SectionWriter(spt:SPT) {
			this.spt=spt;
		}
		
		internal function buildSection(script:XML):ByteArray {
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			for each(var child:XML in script.children()) {
				switch(child.nodeKind()) {
					case "element":
						writeElement(o,child);
					break;
					
					case "text":
						writeText(o,String(child));
					break;
					
					case "comment":
					break;
					
					default:
						throw new ArgumentError("Unknown nodekind:"+child.nodeKind());
					break;
				}
			}
			
			const dataLen:uint=o.length;			
			for(var i:uint=0;i<dataLen;i+=2) {
				var s:uint=o.readUnsignedShort();
				s^=spt.scramblingKey;
				o.position-=2;
				o.writeShort(s);
			}
			
			return o;
		}
		
		private function writeText(o:ByteArray,text:String):void {
			
			for(var pos:uint=0;pos<text.length;++pos) {
				var char:uint=text.charCodeAt(pos);
				o.writeShort(char);
			}
		}
		
		private function writeElement(o:ByteArray,node:XML):void {
			const name:String=node.name();
			switch(name) {
				case "br":
					o.writeShort(0x000A);
				break;
				
				case "unknown":
					o.writeShort(parseInt(node.@data,16));
				break;
				
				default:
					writeCommand(o,node);
				break;
			}
		}
		
		private function writeCommand(o:ByteArray,node:XML):void {
			const name:String=node.name();
			switch(name) {
				case "unknownCommand":
					o.writeShort(parseInt(node.@commandType,16));
				break;
				
				case "whiteText": o.writeShort(0xE040); break;
				case "orangeText": o.writeShort(0xE041); break;
				case "blueText": o.writeShort(0xE042); break;
				case "greenText": o.writeShort(0xE043); break;
				
				case "callSection": o.writeShort(0xE080); o.writeShort(int(node.@section)); break;
				case "JumpToSection": o.writeShort(0xE081); o.writeShort(int(node.@section)); break;
				
				case "showTextWindow": o.writeShort(0xE100); o.writeShort(0); break;
				case "hideTextWindow": o.writeShort(0xE100); o.writeShort(1); break;
				
				case "ack": o.writeShort(0xE102); break;
				case "clear": o.writeShort(0xE104); break;
				case "fullscreenAck": o.writeShort(0xE106); break;
				case "textSpeed": o.writeShort(0xE107); o.writeShort(int(node.@speed)); break;
				case "wait": o.writeShort(0xE108); o.writeShort(int(node.@time)); break;
				
				/*case "fullscreenImage":
					o.writeShort(0xE118);
					o.writeShort(int(node.@a));
					o.writeShort(int(node.@b));
				break;*/
				
				case "checkForPresent":
					o.writeShort(0xE11B);
					o.writeShort(int(node.@evidence));
					o.writeShort(int(node.@section));
				break;
				
				case "ceDefStart": o.writeShort(0xE11E); break;
				
				case "ceStatement":
					o.writeShort(0xE11F);
					o.writeShort(int(node.@index));
					o.writeShort(int(node.@statementSection));
					o.writeShort(int(node.@pressSection));
					o.writeShort(int(node.@presentSection));
					o.writeShort(int(node.@startHidden));
				break;
				
				case "openPipWindow": o.writeShort(0xE1CB); break;
				case "closePipWindow": o.writeShort(0xE1CC); break;
				
				case "logicChessSwapSide":
					o.writeShort(0xE1FA);
					o.writeShort(int(node.@a));
					o.writeShort(int(node.@b));
					o.writeShort(int(node.@c));
					o.writeShort(int(node.@d));
				break;
				
				case "logicChessTimeout":
					o.writeShort(0xE1FB);
					o.writeShort(int(node.@section));
				break;
				
				case "ceAid":
					o.writeShort(0xE120);
					o.writeShort(int(node.@index));
					o.writeShort(int(node.@section));
				break;
				
				case "clearFlag":
					o.writeShort(0xE12C);
					o.writeShort(0);//junk
					o.writeShort(int(node.@flag));
				break;
				
				case "setFlag":
					o.writeShort(0xE12D);
					o.writeShort(1);//junk
					o.writeShort(int(node.@flag));
				break;
				
				case "jumpIfFlag":
					o.writeShort(0xE12E);
					o.writeShort(2);//junk
					o.writeShort(int(node.@flag));
					o.writeShort(int(node.@cond));
					o.writeShort(int(node.@section));
				break;
				
				
				case "longJump":
					o.writeShort(0xE145);
					o.writeShort(int(node.@case));
					o.writeShort(int(node.@part));
					o.writeShort(int(node.@index));
				break;
				
				case "flashHp":	o.writeShort(0xE199); o.writeShort(int(node.@amount)); break;
				case "clearFlashingHp": o.writeShort(0xE19A); break;
				case "penalty": o.writeShort(0xE19C); break;
				
				case "noHPBranch":
					o.writeShort(0xE1C1);
					o.writeShort(int(node.@section));
				break;
				
				case "gameOver": o.writeShort(0xE1C3); break;
				case "returnToTitleScreen": o.writeShort(0xE1C4); break;
				
				default:
					throw new ArgumentError("Unknown command! "+name);
				break;
			}
		}

	}
	
}
