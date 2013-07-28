package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	
	import Nitro.FileSystem.NDS;
	import Nitro.FileSystem.Overlay;
	
	public class LZOverlayTest extends MovieClip {
		
		private var loader:URLLoader;
		private var loader2:URLLoader;
		
		private var nds:NDS;
		
		private var decodedData:ByteArray;
		private var fr:FileReference;
		
		public function LZOverlayTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loadDone);
			loader.load(new URLRequest("layton3.nds"));
			
			loader2=new URLLoader();
			loader2.dataFormat=URLLoaderDataFormat.BINARY;
			loader2.addEventListener(Event.COMPLETE,checkCmp);
			loader2.load(new URLRequest("overlay_0000_dec.bin"));
		}
		
		private function loadDone(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			trace("File loaded");
			
			decodedData=nds.openOverlayById(9,0);
			
			trace("overlay opened!");
			stage.addEventListener(MouseEvent.CLICK,save);
			
			//testOverlays(7,nds.arm7Overlays);
			testOverlays(9,nds.arm9Overlays);
			
			checkCmp();
		}

		var cmpCnt:uint=0;
		private function checkCmp(e:Event=null):void {
			cmpCnt++;
			if(cmpCnt==2) {
				trace(compareByteArrays(loader2.data,decodedData));
			}
		}
		
		private function compareByteArrays(a:ByteArray,b:ByteArray):int {
			if(a.length<b.length) return 1;
			if(a.length>b.length) return -1;
			
			a.position=0;
			b.position=0;
			
			while(a.bytesAvailable>0) {
				var aByte:int=a.readByte();
				var bByte:int=b.readByte();
				if(aByte<bByte) {
					return 1;
				}
				if(aByte>bByte) {
					return -1;
				}
			}
			
			return 0;
		}
		
		private function save(e:MouseEvent):void {
			fr=new FileReference();
			fr.save(decodedData,"overlay.bin");
		}
		
		private function testOverlays(cpu:uint,overlays:Vector.<Overlay>):void {
			if(!overlays) return;
			for each(var overlay:Overlay in overlays) {
				trace("opening overlay #",overlay.id," compressed",overlay.compressed);
				try {
					nds.openOverlayByReference(overlay);
				} catch(err:Error) {
					trace(err.message);
				}
			}
		}
	}
	
}
