package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	
	public class MainMenu extends Screen {
		
		public var extractFiles_btn:SimpleButton;
		public var extractChars_btn:SimpleButton;
		
		public var icon_mc:Sprite;
		
		public function MainMenu() {
			// constructor code
		}
		
		protected override function init():void {
			
			icon_mc.addChild(new Bitmap(gkTool.nds.banner.icon));
			
			extractFiles_btn.addEventListener(MouseEvent.CLICK,fileExtract);
			
		}
		
		private function fileExtract(e:MouseEvent):void {
			gkTool.section=new FileExtractScreen();
		}
	}
	
}
