package Nitro.SDAT {
	
	import flash.events.*;
	import flash.utils.*;
	import flash.media.*;
	
	import HTools.Audio.*;
	import flash.text.TextField;
	
	/** Playsback a STRM */
	
	public class STRMPlayer extends BasePlayer {
		
		private var playSound:Sound,playChannel:SoundChannel;

		/** Creates a new STRMPlayer
		@param strm The Stream to play
		*/
		public function STRMPlayer(strm:STRM) {
			super(new STRMDecoder(strm),strm.sampleRate);			
		}

	}
	
}
