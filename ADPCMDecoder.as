﻿package  {
	import flash.utils.*;
	
	public class ADPCMDecoder {
		
		private var predictor:int;
		private var stepIndex:int;
		private var step:uint;

		public function ADPCMDecoder() {
		}
		
		public function init(p:int=0,si:int=0):void {
			predictor=p;
			stepIndex=si;
			step=stepTable[stepIndex];
		}
		
		public function decodeBlock(block:ByteArray,blockSamples:uint,outBuff:Vector.<Number>):void {
			
			var sample:Number;
			var i:uint=0;
			
			for(;i<blockSamples;) {
				
				var byte:uint=block.readByte();
				var nibble:uint;
				nibble=byte & 15;
											
				sample=parseNibble(nibble);
				outBuff[i++]=sample;
				
				nibble=(byte>>16) & 15;
				sample=parseNibble(nibble);
				outBuff[i++]=sample;

			}
			
		}
		
		private function parseNibble(nibble:uint):Number {
			stepIndex+=indexTable[nibble];
			if(stepIndex<0) {
				stepIndex=0;
			} else if(stepIndex>88) {
				stepIndex=88;
			}
			
			var diff:uint = step >> 3;
			if(nibble & 1) diff += step >> 2;
			if(nibble & 2) diff += step >> 1;
			if(nibble & 4) diff += step;

			if(nibble & 8) {
				predictor-=diff;
				if(predictor<-32767) {
					predictor=-32767;
				}
			} else {
				predictor+=diff;
				if(predictor>32767) {
					predictor=32767;
				}
			}
			
			//predictor+=(nibbleToNumber(nibble) + 0.5) * step / 4;
			
			step=stepTable[stepIndex];
			
			return predictor/32768.0;
		}
		
		private const stepTable:Array= [
			7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 
			19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 
			50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 
			130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
			337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
			876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 
			2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
			5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 
			15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767 
		];
		
		private const indexTable:Array= [
			-1, -1, -1, -1, 2, 4, 6, 8,
			-1, -1, -1, -1, 2, 4, 6, 8
		];

		public static function nibbleToNumber(nibble:uint):Number {
			return [0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1][nibble];
		}

	}
	
}
