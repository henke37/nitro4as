package GKTool {
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class ExtractBaseScreen extends Screen {
		
		protected var outDir:File;
		
		public var errors:uint;
		
		private var realScreen:ExtractScreen;
		
		protected var fileCount:uint;
		private var _progress:uint;
		
		private var startTime:uint;

		public function ExtractBaseScreen() {
			realScreen=new ExtractScreen();
			addChild(realScreen);
		}
		
		protected override function init():void {
			realScreen.selectDir_btn.addEventListener(MouseEvent.CLICK,selectDir);
			realScreen.abort_btn.visible=false;
			realScreen.abort_btn.addEventListener(MouseEvent.CLICK,abort);
			realScreen.menu_btn.addEventListener(MouseEvent.CLICK,menu);
		}
		
		private function selectDir(e:MouseEvent):void {
			outDir=new File();
			outDir.addEventListener(Event.SELECT,dirSelected);
			outDir.browseForDirectory("Output dir");
		}
		
		private function dirSelected(e:Event):void {
			realScreen.selectDir_btn.visible=false;
			initExtraction();
		}
		
		private function initExtraction():void {
			
			realScreen.abort_btn.visible=true;
			realScreen.menu_btn.visible=false;
			
			startTime=getTimer();
			
			fileCount=beginExtraction();
			
			realScreen.status_txt.text="";
			
			if(extractSomeFiles()) {
				addEventListener(Event.ENTER_FRAME,extractMoreFiles);
			}
		}
		
		private function abort(e:MouseEvent):void {
			endOperation();
			log("Operation aborted!");
		}
		
		private function menu(e:MouseEvent):void {
			gkTool.section=new MainMenu();
		}
		
		private function endOperation():void {
			removeEventListener(Event.ENTER_FRAME,extractMoreFiles);
			realScreen.abort_btn.visible=false;
			realScreen.menu_btn.visible=true;
		}
		
		protected function beginExtraction():uint { return 0}
		
		protected function processNext():Boolean {
			return false;
		}
		
		private function extractMoreFiles(e:Event):void {
			if(!extractSomeFiles()) {
				endOperation();
			}
		}
		
		private function extractSomeFiles():Boolean {
			var stopTime:uint=getTimer()+20;
			do {
				if(!processNext()) {
					log("Done, had "+errors+" errors and took "+Math.ceil((getTimer()-startTime)/1000)+" seconds.");
					return false;
				}
			} while(getTimer()<stopTime);
			return true;
		}
		
		protected function log(t:String):void {
			realScreen.status_txt.appendText(t+"\n");
			realScreen.status_txt.scrollV=realScreen.status_txt.maxScrollV;
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
		
		protected function get progress():uint { return _progress; }
		protected function set progress(p:uint):void {
			
			_progress=p;
			
			var g:Graphics=realScreen.progress_mc.graphics;
			
			g.clear();
			
			var pc:Number=Number(p)/fileCount;
			
			const w:Number=540;
			const h:Number=40;
			
			g.lineStyle(1);
			g.drawRect(0,0,w,h);
			g.beginFill(0x0040FF);
			g.drawRect(0,0,w*pc,h);
			g.endFill();
		}
	}
	
}
