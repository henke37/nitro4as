package Nitro.SDAT.SequenceEvents {
	
	public class PortamentoKeyEvent extends SequenceEvent {
		
		public var key:uint;

		public function PortamentoKeyEvent(_key:uint) {
			key=_key;
		}
		
		public function toString():String {
			return "[Portamentokey key="+key+"]";
		}

	}
	
}
