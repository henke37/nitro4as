package Nitro.SDAT {
	
	import flash.utils.*;
	
	public class BaseDecoder {

		/** If looping streams should loop */
		public var loopAllowed:Boolean=true;
		
		/** If mono tracks should be rendered as mono */
		public var rendAsMono:Boolean;

		public function reset():void {}
		public function render(ob:ByteArray,samples:uint):uint { return 0;}
		public function seek(position:uint):void {}
		
		public function get playbackPosition():uint { return 0; }
		
		private static function byteToNumber(byte:int):Number {
			return (Number(byte)/128);
		}
		private static function shortToNumber(short:int):Number {
			return Number(short)/0x8000;
		}
		
		protected function decodePCM(ib:ByteArray,blockSamples:uint,encoding:uint,outBuf:Vector.<Number>):void {
			var sample:Number;
			var i:uint;
			
			if(encoding==1) {
				for(i=0;i<blockSamples;++i) {
					sample=shortToNumber(ib.readShort());
					outBuf[i]=sample;
				}
			} else {
				for(i=0;i<blockSamples;++i) {
					sample=byteToNumber(ib.readByte());
					outBuf[i]=sample;
				}
			}
		}

	}
	
}
