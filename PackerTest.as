package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.GK.*;
	
	public class PackerTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public function PackerTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("game.nds"));
		}
		
		private function loaded(e:Event):void {
			var nds:NDS=new NDS();
			nds.parse(loader.data);
			
			var originalArchive:GKArchive=new GKArchive();
			originalArchive.parse(nds.fileSystem.openFileByName("com/idcom.bin"));
			
			trace("file loaded with",originalArchive.length,"files");
			
			var initialFiles:Vector.<ByteArray>=new Vector.<ByteArray>();
			initialFiles.length=originalArchive.length;
			initialFiles.fixed=true;
			for(var i:uint=0;i<originalArchive.length;++i) {
				initialFiles[i]=originalArchive.open(i);
			}
			
			trace("all files initially unpacked");
			
			var encoderArchive:GKArchive=new GKArchive();
			encoderArchive.build(initialFiles);
			
			trace("files repackaged, size change is",(encoderArchive.data.length/originalArchive.data.length));
			
			var decoderArchive:GKArchive=new GKArchive();
			decoderArchive.parse(encoderArchive.data);
			
			trace("repacked data parsed");
			
			if(decoderArchive.length!=originalArchive.length) throw new Error("The file counts doesn't even match!");
			
			for(i=0;i<originalArchive.length;++i) {
				trace("Testing subfile",i);
				compareByteArrays(initialFiles[i],decoderArchive.open(i));
			}
			
			trace("All base archive tests passed");
			
			trace("Starting sub archive tests");
			
			for(i=0;i<originalArchive.length;++i) {
				var subArchiveData:ByteArray=initialFiles[i];
				subArchiveData.position=0;
				if(sniffExtension(subArchiveData,"")=="subarchive") {
					subArchiveData.position=0;
					trace("Testing sub file",i,"as subarchive");
					testSubarchive(subArchiveData);
				}
			}
			
			trace("All sub archive tests passed");
		}
		
		private function compareByteArrays(a:ByteArray,b:ByteArray):void {
			a.position=0;
			b.position=0;
			
			if(a.length!=b.length) throw new Error("File lengths does not match");
			
			for(var i:uint=0;i<a.length;++i) {
				if(a.readUnsignedByte()!=b.readUnsignedByte()) throw new Error("Data missmatch");
			}
		}
		
		private function testSubarchive(subArchiveData:ByteArray):void {
			var originalSubArchive:GKSubarchive=new GKSubarchive();
			originalSubArchive.parse(subArchiveData);
			
			trace("subarchive parsed");
			
			var initialSubFiles:Vector.<ByteArray>=new Vector.<ByteArray>();
			initialSubFiles.length=originalSubArchive.length;
			initialSubFiles.fixed=true;
			for(var i:uint=0;i<originalSubArchive.length;++i) {
				initialSubFiles[i]=originalSubArchive.open(i);
			}
			
			trace("subsub files loaded");
			
			var encoderSubArchive:GKSubarchive=new GKSubarchive();
			encoderSubArchive.build(initialSubFiles);
			
			trace("subsub files repackaged, size change is",(encoderSubArchive.data.length/originalSubArchive.data.length));
			
			var decoderSubArchive:GKSubarchive=new GKSubarchive();
			decoderSubArchive.parse(encoderSubArchive.data);
			
			trace("repacked data parsed");
			
			if(decoderSubArchive.length!=originalSubArchive.length) throw new Error("The file counts doesn't even match!");
			
			for(i=0;i<originalSubArchive.length;++i) {
				trace("Testing subsubfile",i);
				initialSubFiles[i].position=0;
				compareByteArrays(initialSubFiles[i],decoderSubArchive.open(i));
			}
			
			trace("subfile passed tests");
		}
	}
	
}
