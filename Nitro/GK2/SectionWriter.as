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
				
				default:
					throw new ArgumentError("Unknown command! "+name);
				break;
			}
		}

	}
	
}
