package Nitro.SDAT.SeqPlayer {
	
	public class NoiseChannel extends MixerChannel {
		
		private static const START_NOISE=0x7FFF;
		
		private var noise:uint;

		public function NoiseChannel() {
			// constructor code
		}
		
		
		public override function reset():void {
			noise=START_NOISE;
			super.reset();
		}

		protected override function nextGenSample():Number {
			var out:Boolean=Boolean(noise & 0x01);
			
			if(out) {
				noise=(noise >> 1) ^ 0x6000;
			} else {
				noise=noise >> 1;
			}
			
			return noise?-1:1;
		}

	}
	
}
