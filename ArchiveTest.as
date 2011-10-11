package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.Compression.*;
	import Nitro.Graphics.*;
	
	
	public class ArchiveTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public function ArchiveTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loadDone);
			loader.load(new URLRequest("mariokart.nds"));
		}
		
		private function loadDone(e:Event):void {
			var nds:NDS=new NDS();
			nds.parse(loader.data);
			
			var archiveData:ByteArray=nds.fileSystem.openFileByName("data/CharacterKartSelect.carc");
			
			archiveData=Stock.decompress(archiveData);
			archiveData.position=0;
			
			var archive:NARC=new NARC();
			archive.parse(archiveData);
			
			//trace(dumpFs(archive.fileSystem.rootDir));
			
			var nclr:NCLR=new NCLR();
			nclr.parse(archive.fileSystem.openFileByName("select_kart_s_b.NCLR"));
			
			var convertedPalette:Vector.<uint>=RGB555.paletteFromRGB555(nclr.colors);
			
			var ncgr:NCGR=new NCGR();
			ncgr.parse(archive.fileSystem.openFileByName("select_kart_s_b.NCGR"));
			
			var nscr:NSCR=new NSCR();
			nscr.parse(archive.fileSystem.openFileByName("select_kart_s.NSCR"));
			
			addChild(nscr.render(ncgr,convertedPalette,true));
		}
	}
	
}
