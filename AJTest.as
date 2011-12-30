package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	
	import flash.filesystem.*;
	
	import Nitro.*;
	import Nitro.FileSystem.NDS;
	import Nitro.Apollo.*;
	
	public class AJTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		public function AJTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("aj.nds"));
		}
		
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var b:Bitmap=new Bitmap(loadImage(4,400));
			addChild(b);
			
			b=new Bitmap(loadImage(4,339));
			b.x=256;
			addChild(b);
		}
		
		private function loadImage(id:uint,subid:uint):BitmapData {
			var cpack:CPAC=new CPAC();
			cpack.parse(nds.fileSystem.openFileByName("cpac_2d.bin"));
			
			var subfile:ByteArray=cpack.open(id);
			
			var subarchive:SubArchive=new SubArchive();
			subarchive.parse(subfile);
			
			subfile=subarchive.open(subid);
			
			var pict:IndexedBitmap=new IndexedBitmap();
			pict.parse(subfile);
			
			return pict.toBMD();
		}
			
		private function dumpArchive(fileName:String,id:uint):void {
			
			var cpack:CPAC=new CPAC();
			cpack.parse(nds.fileSystem.openFileByName(fileName));
			
			var subfile:ByteArray=cpack.open(id);
			
			var subarchive:SubArchive=new SubArchive();
			subarchive.parse(subfile);
			
			for(var subid:uint=0;subid<subarchive.length;++subid) {
			
				subfile=subarchive.open(subid);
			
				var fs:FileStream=new FileStream();
				fs.open(new File("C:\\Users\\Henrik\\Desktop\\ds reverse engineering\\unpacked\\aj unpacked\\data\\cpack_2d\\"+id+"\\"+subid+".bin"),FileMode.WRITE);
				
				fs.writeBytes(subfile);
				
				fs.close();
			}
			
		}
	}
	
}
