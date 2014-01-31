package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	
	import Nitro.FileSystem.*;
	
	public class MapperTest extends MovieClip {
		
		private var loader:URLLoader;
		private var nds:NDS;
		private var mapper:Mapper;
		
		public function MapperTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("gk2.nds"));
		}
		
		private function loaded(E:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			//mapper=new Mapper(nds);
			
			var fr:FileReference=new FileReference()
			fr.save(nds.arm9Executable,"arm9.bin");
		}
	}
	
}
