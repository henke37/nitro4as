package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.filesystem.*;
	
	import Nitro.FileSystem.*;
	import Nitro.*;
	
	public class PACTest extends MovieClip {
		
		
		var loader:URLLoader;
		
		public function PACTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,startParsing);
			loader.load(new URLRequest("game.nds"));
		}
		
		private function startParsing(e:Event):void {
			
			var nds:NDSParser=new NDSParser(loader.data);
			
			var baseDir:flash.filesystem.File=new flash.filesystem.File(loaderInfo.url);
			baseDir=new flash.filesystem.File(baseDir.parent.nativePath+flash.filesystem.File.separator+nds.gameCode);
			
			trace(baseDir.nativePath);
			
			
			if(baseDir.exists) {
				baseDir.deleteDirectory(true);
			}
			
			baseDir.createDirectory();
			
			var pacs:Vector.<AbstractFile>;
			pacs=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.pac$/i,true,false);
			
			for each(var match:Nitro.FileSystem.File in pacs) {
				var fileName:String=nds.fileSystem.getFullNameForFile(match);
				var pacData:ByteArray=nds.fileSystem.openFileByReference(match);
				
				var pacDir:flash.filesystem.File=new flash.filesystem.File(baseDir.nativePath+flash.filesystem.File.separator+fileName);
				pacDir.createDirectory();
				
				var pac:PAC=new PAC(pacData);
				
				for(var i:uint=0;i<pac.fileCount;++i) {
				
					var outData:ByteArray=pac.openFile(i);
				
					var outputFile:flash.filesystem.File=new flash.filesystem.File(pacDir.nativePath+flash.filesystem.File.separator+String(i));
					
					var outputStream:FileStream=new FileStream();
					outputStream.open(outputFile,FileMode.WRITE);
					
					outputStream.writeBytes(outData);
					
					outputStream.close();
				}
				
				trace(fileName);
			}
		}
	}
	
}
