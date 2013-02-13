package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	
	import Nitro.FileSystem.*;
	import Nitro.SDAT.*;
	
	public class SDATInfoDumper extends MovieClip {
		
		private var loader:URLLoader
		
		private var nds:NDS;
		private var sdat:SDAT;
		
		public function SDATInfoDumper() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("gk1.nds"));
		}
		
		private function loaded(e:Event):void {
			
			nds=new NDS();
			nds.parse(loader.data);
			
			var files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(nds.fileSystem.rootDir,/\.(?:sdat|dsxe)$/i,true,false);
			
			sdat=new SDAT();
			sdat.parse(nds.fileSystem.openFileByReference(File(files[0])));
			
			var fr:FileReference=new FileReference();
			XML.prettyIndent=2;
			XML.prettyPrinting=true;
			var xml:XML=(sdat2XML(sdat,1));
			fr.save(xml,"sdatInfo.xml");
		}
	}
	
}
