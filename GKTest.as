package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.filesystem.*;
	
	import Nitro.FileSystem.NDS;
	import Nitro.GK.*;
	import Nitro.Graphics.*;
	
	public class GKTest extends MovieClip {
		
		private var loader:URLLoader;
		
		private var masterArchive:MasterArchive;
		
		private var outDir:File;
		
		public function GKTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("gk1.nds"));
		}
		
		private function loaded(e:Event):void {
			var nds:NDS=new NDS();
			nds.parse(loader.data);
			
			var archiveData:ByteArray=nds.fileSystem.openFileByName("files/romfile.bin");
			
			masterArchive=new MasterArchive();
			masterArchive.parse(archiveData);
			
			dumpBins_mc.addEventListener(MouseEvent.CLICK,binDumpClick);
			dumpScreen_mc.addEventListener(MouseEvent.CLICK,screenDumpClick);
		}
		
		private function binDumpClick(e:MouseEvent):void {
			outDir=new File();
			outDir.addEventListener(Event.SELECT,selected);
			outDir.browseForDirectory("Save dir");
		}
		
		private function screenDumpClick(e:MouseEvent):void {
			var screen:DisplayObject=decodeScreen(4531,8,4532,4530);
			addChild(screen);
		}
		
		private function selected(e:Event):void {
			extractArchive();
		}
		
		private function extractArchive():void {
			
			try {
			
				for(var id:uint=0;id<masterArchive.length;++id) {
				
					var subFile:ByteArray=masterArchive.open(id);
					
					saveFile("files/romfile_bin/"+id+".bin",subFile);
				}
			
			} catch(err:Error) {
				trace("Error unpacking file # "+id);
				trace(err.getStackTrace());
			}
			
		}
		
		private function decodeScreen(palId:uint,bpp:uint,gfxId:uint,scrnId:uint):DisplayObject {
			var palData:ByteArray=masterArchive.open(palId);
			palData.endian=Endian.LITTLE_ENDIAN;
			var decodedPal:Vector.<uint>=RGB555.readPalette(palData,bpp);
			
			var gfxData:ByteArray=masterArchive.open(gfxId);
			var gfx:GraphicsBank=new GraphicsBank();
			gfx.bitDepth=bpp;
			gfx.parseTiled(gfxData,0,gfxData.length);
			
			var scrnData:ByteArray=masterArchive.open(scrnId);
			var scrn:TileMappedScreen=new TileMappedScreen();
			scrn.loadEntries(scrnData,32,24,true);
			
			return scrn.render(gfx,decodedPal,false);
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
