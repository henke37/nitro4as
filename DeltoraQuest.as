package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.filesystem.*;
	import flash.text.TextField;
	
	import Nitro.FileSystem.NDS;
	import Nitro.Deltora.*;
	import Nitro.Compression.*;
	
	import fl.controls.Button;
	import fl.events.ComponentEvent;
	
	public class DeltoraQuest extends MovieClip {
		
		private var loader:URLLoader;
		private var nds:NDS;
		
		private var archive:MasterArchive;
		
		public var loadROM_mc:Button;
		public var pickPath_mc:Button;
		public var extract_mc:Button;
		public var path_txt:TextField;
		
		private var fr:FileReference;
		
		private var dumpDir:File;
		
		public function DeltoraQuest() {
			/*
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("DeltoraQuest.nds"));*/
			loadROM_mc.addEventListener(ComponentEvent.BUTTON_DOWN,selectRom);
			pickPath_mc.addEventListener(ComponentEvent.BUTTON_DOWN,pickPath);
			extract_mc.addEventListener(ComponentEvent.BUTTON_DOWN,extract);
		}
		
		private function selectRom(e:Event):void {
			fr=new FileReference();
			fr.addEventListener(Event.CANCEL,cancelLoad);
			fr.addEventListener(Event.SELECT,romSelected);
			fr.browse([new FileFilter("The rom (*.nds)","*.nds")]);
		}
		
		private function romSelected(e:Event):void {
			fr.addEventListener(Event.COMPLETE,romLoaded);
			fr.load();
		}
		
		private function romLoaded(e:Event) {
			try {
				nds=new NDS();
				nds.parse(fr.data);
				
				if(nds.gameCode!="AQUJ") {
					trace(nds.gameCode);
					throw new Error("Wrong game!");
				}
			
				if(dumpDir) extract_mc.enabled=true;
			} catch(err:Error) {
				nds=null;
				extract_mc.enabled=false;
			}
		}
		
		private function pickPath(e:Event):void {
			dumpDir=new File();
			dumpDir.addEventListener(Event.SELECT,pathSelected);
			dumpDir.addEventListener(Event.CANCEL,cancelLoad);
			dumpDir.browseForDirectory("Output dir");
		}
		
		private function cancelLoad(e:Event):void {
			e.currentTarget.cancel();
		}
		
		private function pathSelected(e:Event):void {
			dumpDir.cancel();
			if(nds) extract_mc.enabled=true;
			path_txt.text=dumpDir.nativePath;
		}
		
		private function extract(e:Event):void {
			var archiveData:ByteArray=nds.fileSystem.openFileByName("FILEDATA.BIN");
			trace(archiveData.length);
			
			archive=new MasterArchive();
			archive.parse(archiveData);
			
			dumpFiles();
		}
		
		private function dumpFiles():void {
			for(var entryIndex:uint=0;entryIndex<archive.length;++entryIndex) {
				var data:ByteArray=archive.open(entryIndex);
				var ext:String=sniffExtension(data);
				var filename:String=entryIndex.toString()+"."+ext;
				data.position=0;
				
				var file:File;
				var fs:FileStream;
				
				if(ext=="bin" && data[0]==0x10) {
					var decmp:ByteArray=Stock.decompress(data);
					filename=entryIndex.toString()+"_dec."+ext;
					file=new File(dumpDir.nativePath+File.separator+filename);
					fs=new FileStream();
					fs.open(file,FileMode.WRITE);
					fs.writeBytes(decmp);
					fs.close();
				} else {
					file=new File(dumpDir.nativePath+File.separator+filename);
					fs=new FileStream();
					fs.open(file,FileMode.WRITE);
					fs.writeBytes(data);
					fs.close();
				}
			}
		}
		
		public function sniffExtension(data:ByteArray):String {
		
			if(data.length<4) return "bin";
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			var id:String=data.readUTFBytes(4);
			
			if(!id.match(/[ a-z0-9]{4}/i)) {
				return "bin";
			}
			
			id=id.replace(" ","").toLowerCase();
			
			switch(id) {
				case "bmd0":
					return "nsbmd";
				break;
				
				case "btx0":
					return "nsbtx";
				break;
				
				case "bca0":
					return "nsbca";
				break;
				
				case "scr0":
					return "script";
				
				default:
					return (id.charAt(3)+id.charAt(2)+id.charAt(1)+id.charAt(0));
				break;
			}
		}
	}
	
}
