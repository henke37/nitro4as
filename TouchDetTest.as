package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.filesystem.*;
	
	import Nitro.FileSystem.NDS;
	
	import Nitro.TouchDetective.*;
	import Nitro.SDAT.SDAT;
	import Nitro.FileSystem.File;
	
	public class TouchDetTest extends MovieClip {
		
		private var loader:URLLoader;
		private var masterArch:MasterArchive;
		
		public function TouchDetTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("touch detective.nds"));
		}
		
		private function loaded(e:Event):void {
			var nds:NDS=new NDS();
			nds.parse(loader.data);
			
			masterArch=new MasterArchive();
			masterArch.parse(nds.fileSystem.openFileByName("data/data.bin"));
			
			//openTest();
			exportMasterFiles();
		}
		
		private function exportMasterFiles():void {
			
			
			for(var i:uint=0;i<masterArch.length;++i) {
				var fileCont:ByteArray=masterArch.open(i);
				
				var fourC:String=fileCont.readUTFBytes(4);
				trace(fourC,i);
				
				fileCont.position=0;
				
				var ext:String;
				
				if(fourC=="") {
					ext="";
				} else if(fourC.match(/[a-z 0-9_-]{4}/i)) {
					ext=fourC.toLowerCase();
				} else {
					ext="bin";
				}
				
				writeFile(fileCont,i+"."+ext);
			}
		}
		
		private function writeFile(contents:ByteArray,name:String):void {
			var outDir:File=new File("c:\\users\\henrik\\desktop\\ds reverse engineering\\unpacked\\touch detective\\data\\data");
			
			name=name.replace("/",File.separator);
			
			var outFile:File=new File();
			outFile.nativePath=outDir.nativePath+File.separator+name;
			
			var fs:FileStream=new FileStream();
			fs.open(outFile,FileMode.WRITE);
			fs.writeBytes(contents);
			fs.close();
		}
		
		private function openTest():void {
			for(var i:uint=0;i<masterArch.length;++i) {
				var fileCont:ByteArray=masterArch.open(i);
				tryParse(fileCont,i);
			}
		}
		
		private function tryParse(fileCont:ByteArray,i:uint):void {
			var fourC:String=fileCont.readUTFBytes(4);
			trace(fourC,i);
			
			fileCont.position=0;
			
			if(fourC=="SDAT") {
				var sdat:SDAT=new SDAT();
				sdat.parse(fileCont);
			}
		}
	}
	
}
