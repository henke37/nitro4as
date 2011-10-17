package Nitro.SDAT {
	
	import flash.utils.*;
	
	public class BaseDecoder {

		/** If looping streams should loop */
		public var loopAllowed:Boolean=true;

		public function reset():void {}
		public function render(ob:ByteArray,samples:uint):uint { return 0;}
		public function seek(position:uint):void {}
		
		public function get playbackPosition():uint { return 0; }
		
		private static function byteToNumber(byte:uint):Number {
			return Number(byte)/256;
		}
		private static function shortToNumber(short:uint):Number {
			return Number(short)/(2<<16);
		}
		
		protected function decodePCM(ib:ByteArray,blockSamples:uint,encoding:uint,outBuf:Vector.<Number>):void {
			var sample:Number;
			var i:uint;
			
			if(encoding==1) {
				for(i=0;i<blockSamples;++i) {
					sample=shortToNumber(ib.readUnsignedShort());
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
