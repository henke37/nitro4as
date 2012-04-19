package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	
	import Nitro.FileSystem.NDS;
	import Nitro.FileSystem.Overlay;
	
	public class LZOverlayTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var decodedData:ByteArray;
		private var fr:FileReference;
		
		public function LZOverlayTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loadDone);
			loader.load(new URLRequest("layton3.nds"));
		}
		
		private function loadDone(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			trace("File loaded");
			
			decodedData=nds.openOverlayById(9,0);
			
			trace("overlay opened!");
			stage.addEventListener(MouseEvent.CLICK,save);
			
			//testOverlays(7,nds.arm7Overlays);
			//testOverlays(9,nds.arm9Overlays);
		}
		
		private function save(e:MouseEvent):void {
			fr=new FileReference();
			fr.save(decodedData,"overlay.bin");
		}
		
		private function testOverlays(cpu:uint,overlays:Vector.<Overlay>):void {
			if(!overlays) return;
			for each(var overlay:Overlay in overlays) {
				nds.openOverlayByReference(overlay);
			}
		}
	}
	
}
