package GKTool {
	
	import flash.display.*;
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	
	
	public class GKTool extends Sprite {
		
		internal var nds:NDS;
		
		private var _screen:Screen;
		private var _screenId:String;
		private var screens:Object;
		
		public static const version:String="v 2.1";

		public function GKTool() {			
			stage.align=StageAlign.TOP_LEFT;
			
			screens={};
			
			screen="MainMenu";
		}
		
		public function set screen(s:String):void {
			
			if(_screen) {
				removeChild(_screen);
			}
			
			_screenId=s;
			
			if(s in screens) {
				_screen=screens[s];
			} else {
				_screen=new (getDefinitionByName("GKTool."+s) as Class);
				screens[s]=_screen;
			}
			
			addChild(_screen);
			
		}
		
		private function screenList():void {
			throw new Error();
			FileExtractScreen;
			GraphicsExtractScreen;
			RepackScreen;
		}

	}
	
}
