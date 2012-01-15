package Nitro.SDAT.SeqPlayer {
	
	public class PulseChannel extends MixerChannel {
		
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
