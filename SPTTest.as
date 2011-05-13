package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import Nitro.*;
	import Nitro.FileSystem.*;
	import Nitro.GK.*;	
	
	public class SPTTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		public function SPTTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,parse);
			loader.load(new URLRequest("game.nds"));
			
			stage.align=StageAlign.TOP_LEFT;
		}
		
		private function parse(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var archive:GKArchive=new GKArchive();
			archive.parse(nds.fileSystem.openFileByName("jpn/spt.bin"));
			
			var spt:SPT=new SPT();
			spt.parse(archive.open(0));
			
			for each(var ent in spt.sections)  {
				trace(ent.offset,ent.size,ent.flag1,ent.flag2);
			}
		}
	}
}