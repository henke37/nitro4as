﻿package Nitro.SDAT {
	import flash.utils.*;
	
	/** Decodes ADPCM encoded audio */
	
	public class ADPCMDecoder {
		
		private var predictor:int;
		private var stepIndex:int;
		private var step:uint;

		public function ADPCMDecoder() {
		}
		
		/** Initializes the decoder
		@param p The new predictor value
		@param si The new step index value
		*/
		public function init(p:int=0,si:int=0):void {
			predictor=p;
			stepIndex=si;
			step=stepTable[stepIndex];
		}
		
		/** Decodes a chunk of samples
		<p>Note: block headers are not understood, only raw samples.</p>
		@param block The ByteArray to read from.
		@param blockSamples How many samples to decode
		@param outBuff The buffer to place the decoded samples in
		*/
		public function decodeBlock(block:ByteArray,blockSamples:uint,outBuff:Vector.<Number>):void {
			
			var sample:Number;
			var i:uint=0;
			
			for(;i<blockSamples;) {
				
				var byte:uint=block.readByte();
				var nibble:uint;
				nibble=byte & 0x0F;
											
				sample=parseNibble(nibble);
				outBuff[i++]=sample;
				
				nibble=(byte>>4) & 0x0F;
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
		
		private static const stepTable:Vector.<int>= new <int>[
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
		
		private static const indexTable:Vector.<int>= new <int>[
			-1, -1, -1, -1, 2, 4, 6, 8,
			-1, -1, -1, -1, 2, 4, 6, 8
		];
		
		/*private static const nibbleTable:Vector.<int>= new <int>[
			0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1
		];*/
		
		{
			indexTable.fixed=true;
			stepTable.fixed=true;
			//nibleTable.fixed=true;
		}

		/*
		private static function nibbleToNumber(nibble:uint):Number {
			return nibleTable[nibble];
		}*/

	}
	
}
