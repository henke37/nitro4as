package GKTool {
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.text.*;
	import flash.utils.*;
	
	public class ExtractBaseScreen extends Screen {
		
		public var selectDir_btn:SimpleButton;
		
		public var status_txt:TextField;
		
		protected var outDir:File;
		
		public var errors:uint;
		
		public var progress_mc:Sprite;
		
		protected var fileCount:uint;
		private var _progress:uint;

		public function ExtractBaseScreen() {
			// constructor code
		}
		
		protected override function init():void {
			selectDir_btn.addEventListener(MouseEvent.CLICK,selectDir);
		}
		
		private function selectDir(e:MouseEvent):void {
			outDir=new File();
			outDir.addEventListener(Event.SELECT,dirSelected);
			outDir.browseForDirectory("Output dir");
		}
		
		private function dirSelected(e:Event):void {
			selectDir_btn.visible=false;
			initExtraction();
		}
		
		private function initExtraction():void {
			
			fileCount=beginExtraction();
			
			status_txt.text="";
			
			if(extractSomeFiles()) {
				addEventListener(Event.ENTER_FRAME,extractMoreFiles);
			}
		}
		
		protected function beginExtraction():uint { return 0}
		
		protected function processNext():Boolean {
			return false;
		}
		
			private function extractMoreFiles(e:Event):void {
			if(!extractSomeFiles()) {
				removeEventListener(Event.ENTER_FRAME,extractMoreFiles);
			}
		}
		
		private function extractSomeFiles():Boolean {
			var stopTime:uint=getTimer()+20;
			do {
				++progress;
				if(!processNext()) {
					log("Done, had "+errors+" errors");
					return false;
				}
			} while(getTimer()<stopTime);
			return true;
		}
		
		protected function log(t:String):void {
			status_txt.appendText(t+"\n");
			status_txt.scrollV=status_txt.maxScrollV;
		}
		
		protected function saveFile(name:String,data:ByteArray):void {
			name=name.replace("/",File.separator);
			var outFile:flash.filesystem.File=new File(outDir.nativePath+File.separator+name);
			var fileStream:FileStream=new FileStream();
			fileStream.open(outFile,FileMode.WRITE);
			fileStream.writeBytes(data,0);
		}
		
		protected static function padNumber(number:uint,size:uint):String {
			var o:String=number.toString();
			while(o.length<size) {
				o="0"+o;
			}
			return o;
		}
		
		private function get progress():uint { return _progress; }
		private function set progress(p:uint):void {
			
			_progress=p;
			
			progress_mc.graphics.clear();
			
			var pc:Number=Number(p)/fileCount;
			
			const w:Number=540;
			const h:Number=40;
			
			progress_mc.graphics.lineStyle(1);
			progress_mc.graphics.drawRect(0,0,w,h);
			progress_mc.graphics.beginFill(0x0040FF);
			progress_mc.graphics.drawRect(0,0,w*pc,h);
			progress_mc.graphics.endFill();
		}
	}
	
}
