package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import Nitro.*;
	import Nitro.FileSystem.NDS;
	import Nitro.Font.*;
	
	public class FontTest extends MovieClip {
		
		private var loader:URLLoader;
		private var nds:NDS;
		
		private var font:NFTR;
		
		public function FontTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("ph.nds"));
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			font=new NFTR();
			font.parse(nds.fileSystem.openFileByName("Font/zeldaDS_15.nftr"));
			
			showTiles();
		}
		
		private function showTiles():void {
			var xPos:Number=0;
			var yPos:Number=0;
			const xMax=stage.stageWidth;
			for(var i:uint=0;i<font.tileCount;++i) {
				var tile:FontTile=font.getTile(i);
				
				var b:DisplayObject=tile.getDebugView();
				
				addChild(b);
				
				var rightEdge:Number=xPos+b.width;
				if(rightEdge>xMax) {
					xPos=0;
					yPos+=b.height;
				}
				
				b.x=xPos;
				b.y=yPos;
				
				xPos+=b.height;
			}
		}
	}
	
}
