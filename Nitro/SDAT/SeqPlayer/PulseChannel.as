package Nitro.SDAT.SeqPlayer {
	
	/** A MixerChannel that can also output a pulsewave */
	public class PulseChannel extends MixerChannel {
		
		public var duty:uint;
		
		private var pulseTimer:uint;

		public function PulseChannel() {
			// constructor code
		}
		
		public override function reset():void {
			pulseTimer=0;
			super.reset();
		}

	}
	
}
