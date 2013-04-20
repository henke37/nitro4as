package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.filesystem.*;
	
	import com.adobe.images.PNGEncoder;
	
	import Nitro.Apollo.*;
	import Nitro.FileSystem.NDS;
	import Nitro.GhostTrick.*;
	import Nitro.FileSystem.File;
	
	public class GhostTrick2 extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var mainPack:CPAC;
		private var subArchive:SubArchive;
		
		public function GhostTrick2() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("GhostTrick.nds"));
			
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			mainPack=new CPAC();
			mainPack.parse(nds.fileSystem.openFileByName("cpac_2d.bin"));
			
			subArchive=new SubArchive();
			subArchive.parse(mainPack.open(3));
			
			//showCell();
			
			testArchive(14692);
		}
		
		private function testArchive(startId:uint):void {
			var subsub:SplitArchive=new SplitArchive();
			subsub.parse(subArchive.open(startId),subArchive.open(startId+2));
			
			for(var i:uint=0;i<subsub.length;++i) {
				var data:ByteArray=subsub.open(i);
				var file:File=new File("C:\\Users\\Henrik\\Desktop\\ghost trick\\"+i+".bin");
				var fs:FileStream=new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.writeBytes(data);
				fs.close();
			}	
		}
		
		private function showCell(paletteId:uint,pixelsId:uint,cellID:uint):void {
			
		}
	}
	
}
