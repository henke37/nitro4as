package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	public class MainMenu extends Screen {
		
		public var header_txt:TextField;
		
		public var loadRom_mc:Button;
		public var extractFiles_mc:Button;
		public var extractChars_mc:Button;
		public var rebuild_mc:Button;
		
		public var icon_mc:Sprite;
		
		public var status_txt:TextField;
		
		private var romLoader:RomLoader;
		
		public function MainMenu() {
			
		}
		
		protected override function init():void {
			
			romLoader=new RomLoader(this);
			romLoader.addEventListener(Event.COMPLETE,loaded);
			
			header_txt.text=header_txt.text.replace("$v",GKTool.GKTool.version)
			
			loadRom_mc.label="Load ROM";
			extractFiles_mc.label="Extract Files";
			extractFiles_mc.addEventListener(MouseEvent.CLICK,fileExtract);
			extractFiles_mc.enabled=false;
			extractChars_mc.label="Extract Graphics";
			extractChars_mc.addEventListener(MouseEvent.CLICK,graphicsExtract);
			extractChars_mc.enabled=false;
			rebuild_mc.label="Rebuild archive";
			rebuild_mc.addEventListener(MouseEvent.CLICK,rebuild);
		}
		
		private function fileExtract(e:MouseEvent):void {
			gkTool.screen="FileExtractScreen";
		}
		
		private function graphicsExtract(e:MouseEvent):void {
			gkTool.screen="GraphicsExtractScreen";
		}
		
		private function rebuild(e:MouseEvent):void {
			gkTool.screen="RepackScreen";
		}
		
		private function loaded(e:Event):void {
			icon_mc.addChild(new Bitmap(gkTool.nds.banner.icon));
			loadRom_mc.enabled=false;
			extractFiles_mc.enabled=true;
			extractChars_mc.enabled=true;
		}
	}
	
}
