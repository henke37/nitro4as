package  {
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	
	import flash.filesystem.*;
	
	import fl.controls.*;
	import fl.events.*;
	
	import Nitro.*;
	import Nitro.FileSystem.NDS;
	import Nitro.Apollo.*;
	import Nitro.Compression.*;
	

	
	public class AJTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var cpack:CPAC;
		private var subarchive:SubArchive;
		
		public var subid_mc:NumericStepper;
		public var transparent_mc:CheckBox;
		
		public var error_txt:TextField;
		
		private var b:Bitmap;
		
		public function AJTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("aj.nds"));
		}
		
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			b=new Bitmap();
			addChild(b);
			
			cpack=new CPAC();
			cpack.parse(nds.fileSystem.openFileByName("cpac_2d.bin"));
			
			loadSubArchive();
			
			subid_mc.addEventListener(Event.CHANGE,change);
			transparent_mc.addEventListener(Event.CHANGE,change);
		}
		
		private function loadSubArchive():void {
			var subfile:ByteArray=cpack.open(4);
			
			subarchive=new SubArchive();
			subarchive.parse(subfile);
			
			subid_mc.maximum=subarchive.length-1;
			subid_mc.value=0;
			
			change(null);
		}
		
		private function change(e:Event):void {
			try {
				loadImage(subid_mc.value,transparent_mc.selected);
				error_txt.visible=false;
				b.visible=true;
			} catch(e:Error) {
				error_txt.visible=true;
				error_txt.text=e.message;
				b.visible=false;
			}
		}
		
		private function loadImage(subid:uint,transparent:Boolean):void {
			
			var subfile:ByteArray=subarchive.open(subid);
			
			var pict:IndexedBitmap=new IndexedBitmap();
			pict.parse(subfile);
			
			b.bitmapData=pict.toBMD(transparent);
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
