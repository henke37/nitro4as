package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.filesystem.*;
	
	import Nitro.FileSystem.NDS;
	
	import Nitro.MegamanZX.*;
	
	public class MMZX extends MovieClip {
		
		private var loader:URLLoader;
		private var nds:NDS;
		
		public function MMZX() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("megaman zx E.nds"));
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			stage.addEventListener(MouseEvent.CLICK,click);
		}
		
		private var outDir:File;
		
		private function click(e:MouseEvent):void {
			outDir=new File();
			outDir.addEventListener(Event.SELECT,selected);
			outDir.browseForDirectory("Save dir");
		}
		
		private function selected(e:Event):void {
			extractArchive("bbom.bin");
			extractArchive("d05.bin");
			extractArchive("l01.bin");
		}
		
		private function extractArchive(path:String):void {
			var archive:Archive=new Archive();
			archive.parse(nds.fileSystem.openFileByName(path));
			
			path=path.replace(".","_");
			
			try {
			
			for(var id:uint=0;id<archive.length;++id) {
			
				var subFile:ByteArray=archive.open(id);
				
				saveFile(path+"/"+id+".bin",subFile);
			}
			
			} catch(err:Error) {
				trace("Error unpacing file \""+path+"\" # "+id);
				trace(err.getStackTrace());
			}
			
		}
		
		private function saveFile(path:String,data:ByteArray):void {
			path=path.replace(/\//,File.separator);
			var file:File=new File();
			file.nativePath=outDir.nativePath+File.separator+path;
			
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
	}
	
}
