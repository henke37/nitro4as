package Nitro.SDAT {
	
	/** Plays back a wave */
	public class WavePlayer extends BasePlayer {

		public function WavePlayer(wave:Wave) {
			super(new WaveDecoder(wave),wave.samplerate);
		}

	}
	
}
