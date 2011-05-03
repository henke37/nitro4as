package Nitro.Animation {
	
	import Nitro.Graphics.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	public class NANRPlayer extends Sprite {

		private var anim:NANRAnim;
		private var tiles:NCGR;
		private var palette:NCLR;
		private var cells:NCER;
		
		private var cellCache:Object;
		
		private var nextFrame:uint;
		private var frameDelay:uint;
		
		private var currentCell:DisplayObject;

		public function NANRPlayer(p:NCLR,t:NCGR,c:NCER,a:NANRAnim) {
			
			if(!p || !t || !c || !a) throw new ArgumentError();
			
			anim=a;
			cells=c;
			tiles=t;
			palette=p;
			
			cellCache={};
		}
		
		public function play():void {
			addEventListener(Event.ENTER_FRAME,runAnim);
		}
		
		public function stop():void {
			removeEventListener(Event.ENTER_FRAME,runAnim);
		}
		
		private function runAnim(e:Event):void {
			
			if(frameDelay==0) {
				loadNextFrame();
			} else {
				--frameDelay;
			}
		}
		
		private function loadNextFrame():void {
			loadFrame(nextFrame);
			
			if(nextFrame+1>=anim.frames.length) {
				nextFrame=0;
			} else {
				++nextFrame;
			}
		}
		
		private function loadFrame(frnr:uint):void {
			if(currentCell) {
				removeChild(currentCell);
			}
			
			var frame:NANRFrame=anim.frames[frnr];
			var pos:NANRPosition=frame.position;
			var ci:uint=pos.cellIndex;
			
			if(ci in cellCache) {
				currentCell=cellCache[ci];
			} else {
				currentCell=cells.rend(ci,palette,tiles);
				cellCache[ci]=currentCell;
			}
			
			currentCell.transform.matrix=pos.transform;
			
			frameDelay=frame.frameTime;
			
			addChild(currentCell);
		}

	}
	
}
