package GKTool {
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	
	import Nitro.FileSystem.*;
	
	public class WellcomeScreen extends Screen {
		
		public var text_txt:TextField;
		
		public var load_btn:SimpleButton;
		
		private var fr:FileReference;
		
		public function WellcomeScreen() {
			// constructor code
		}
		
		protected override function init():void {
			text_txt.text=text_txt.text.replace("$version",GKTool.GKTool.version);
			
			load_btn.addEventListener(MouseEvent.CLICK,clickLoad);
		}
		
		private function clickLoad(e:MouseEvent):void {
			
			fr=new FileReference();
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Nitro games","*.nds")]);
		}
		
		private function fileSelected(e:Event):void {
			stage.removeEventListener(MouseEvent.CLICK,clickLoad);
			
			fr.addEventListener(Event.COMPLETE,frLoaded);
			text_txt.text="Loading data...";
			fr.load();
			
		}
		
		private function frLoaded(e:Event):void {
			var nds:NDS;
			try {
				nds=new NDS();
				nds.parse(fr.data);
				
				if(nds.gameCode!="BXOJ") {
					throw new Error("Wrong game loaded");
				}
			} catch(err:Error) {
				text_txt.text="Loading failed:\n"+err.message;
				load_btn.addEventListener(MouseEvent.CLICK,clickLoad);
				return;
			}
			
			gkTool.nds=nds;
			gkTool.section=new MainMenu();
		}
	}
	
}
