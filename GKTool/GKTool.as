package GKTool {
	
	import flash.display.*;
	
	import Nitro.FileSystem.*;
	
	
	public class GKTool extends Sprite {
		
		internal var nds:NDS;
		
		private var _section:Screen;
		
		public static const version:String="v 1.0";

		public function GKTool() {
			section=new WellcomeScreen();
			
			stage.align=StageAlign.TOP_LEFT;
		}
		
		public function set section(s:Screen):void {
			
			if(_section) {
				removeChild(_section);
			}
			
			_section=s;
			
			addChild(_section);
			
		}

	}
	
}
