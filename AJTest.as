package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	
	import Nitro.*;
	import Nitro.FileSystem.*;
	import Nitro.Apollo.*;
	
	public class AJTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public function AJTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("aj.nds"));
		}
		
		private var subfile:ByteArray;
		private var fr:FileReference;
		
		private function loaded(e:Event):void {
			var nds:NDS=new NDS();
			nds.parse(loader.data);
			
			var cpack:CPAC=new CPAC();
			cpack.parse(nds.fileSystem.openFileByName("cpac_3d.bin"));
			
			var id:uint=1;
			
			subfile=cpack.open(id);
			
			var subarchive:SubArchive=new SubArchive();
			subarchive.parse(subfile);
			
			for(var subid:uint=0;subid<subarchive.length;++subid) {
			
				subfile=subarchive.open(subid);
			
				trace(subfile.readUTFBytes(4));
			}
			
			//fr=new FileReference();
			//fr.save(subfile,subid+".bin");
		}
	}
	
}
