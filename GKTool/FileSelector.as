package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	
	public class FileSelector extends Sprite {
		
		public var nclr_txt:TextField;
		public var ncgr_txt:TextField;
		public var ncer_txt:TextField;
		public var frame_txt:TextField;
		
		public function FileSelector() {
			nclr_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
			ncgr_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
			ncer_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
			frame_txt.addEventListener(KeyboardEvent.KEY_DOWN,checkEnter);
		}
		
		private function checkEnter(e:KeyboardEvent):void {
			if(e.keyCode==Keyboard.ENTER) {
				load();
			}
		}
		
		public function load(e:Event=null):void {
			editor.loadFiles(nclr_txt.text,ncgr_txt.text,ncer_txt.text);
			editor.loadCell(parseInt(frame_txt.text));
		}
		
		private function get editor():Editor { return Editor(parent); }
	}
	
}
