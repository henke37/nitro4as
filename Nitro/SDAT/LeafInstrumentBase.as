package Nitro.SDAT {
	import flash.utils.ByteArray;
	
	public class LeafInstrumentBase extends Instrument {
		public var baseNote:uint;
		
		public var attack:uint;// 0..127
		public var decay:uint;
		public var sustain:uint;
		public var release:uint;
		
		public var pan:uint// 0..127, 64 = middle

		public function LeafInstrumentBase() {
			// constructor code
		}
		
		public override function parse(section:ByteArray):void {
			baseNote=section.readUnsignedByte();
			
			attack=section.readUnsignedByte();
			decay=section.readUnsignedByte();
			sustain=section.readUnsignedByte();
			release=section.readUnsignedByte();
			
			pan=section.readUnsignedByte();	

		}
		
		public override function toXML():XML {
			var o:XML=super.toXML();
			o.@baseNote=baseNote;
			o.@attack=attack;
			o.@decay=decay;
			o.@sustain=sustain;
			o.@release=release;
			o.@pan=pan;
			return o;
		}

	}
	
}
