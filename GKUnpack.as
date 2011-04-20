package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	
	import Nitro.Compression.*;
	import Nitro.FileSystem.*;	
	import Nitro.*;
	
	public class GKUnpack extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		public var status_txt:TextField;
		
		private static const iconZoom:Number=10;
		private static const titleHeight:Number=40;
		
		public function GKUnpack() {			
			
			if(loaderInfo.url.match(/^file:/) && false) {
				status_txt.text="Loading data";
				loader=new URLLoader();
				loader.addEventListener(Event.COMPLETE,loaded);
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.load(new URLRequest("game.nds"));
			} else {
				status_txt.text="Click to load game from disk";
				stage.addEventListener(MouseEvent.CLICK,stageClick);
			}
		}
		
		var fr:FileReference;
		
		private function stageClick(e:MouseEvent):void {
			
			fr=new FileReference();
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Nitro games","*.nds")]);
		}
		
		private function fileSelected(e:Event):void {
			stage.removeEventListener(MouseEvent.CLICK,stageClick);
			
			fr.addEventListener(Event.COMPLETE,frLoaded);
			status_txt.text="Loading data";
			fr.load();
			
		}
		
		private function frLoaded(e:Event):void {	
			nds=new NDS();
			nds.parse(fr.data);
			setup();
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			setup();
		}
		
		private function setup():void {
			
			//testOne();
			listAll();
		}
		
		private function testOne():void {
			var archiveData:ByteArray=nds.fileSystem.openFileByName("com/save.bin");
			var archive:GKArchive=new GKArchive();
			archive.parse(archiveData);
			status_txt.text="Loaded "+archive.length+" files.";
		}
		
		private function listAll():void {
			var binFiles:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.bin$/i,true);
			
			var list:XML=<fileList />;
			
			for each(var archiveFile:File in binFiles) {
				var archive:GKArchive=new GKArchive();
				archive.parse(nds.fileSystem.openFileByReference(archiveFile));
				var archiveXML:XML=<archive fileCount={archive.length} name={nds.fileSystem.getFullNameForFile(archiveFile)} />;
				
				for(var subid in archive.fileList) {
					var subFile=archive.fileList[subid];
					archiveXML.appendChild(<subFile id={subid} compressed={subFile.compressed?"Yes":"No"} size={subFile.size} />);
				}
				
				list.appendChild(archiveXML);
			}
			
			trace(list);
		}
		
		private function t() {
			ExtendedLZ77decoder.decode;
		}
	}
	
}
