package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.geom.*;
	
	import Nitro.FileSystem.*;
	import Nitro.GS1.*;
	import Nitro.Compression.*;
	import Nitro.Graphics.*;
	
	import com.adobe.images.PNGEncoder;
	
	
	public class GSExtracter extends MovieClip {
		
		private var nds:NDS;
		private var archive:Archive;
		private var archiveData:ByteArray;
		
		private var loader:URLLoader;
		
		public var status_txt:TextField;
		
		private var saveDir:File;
		
		public function GSExtracter() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,startParsing);
			loader.load(new URLRequest("gs1.nds"));
			
			status_txt.text="Loading file...";
		}
		
		private function startParsing(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			archiveData=nds.fileSystem.openFileByName("data.bin");
			
			status_txt.text="File loader, click to save.";
			stage.addEventListener(MouseEvent.CLICK,startSaving);
		}
		
		private function startSaving(e:MouseEvent):void {
			saveDir=new File();
			saveDir.addEventListener(Event.SELECT,outDirSelected);
			saveDir.browseForDirectory("Output dir");
		}
		
		private function outDirSelected(e:Event):void {
			
			outputAnim("badger",0,32,20);
			outputAnim("15intro",1823768,32,24);
			
		}
		
		private function outputAnim(subDir:String,offset:uint,xTiles:uint,yTiles:uint):void {
			archiveData.position=offset;
			
			archive=new Archive();
			archive.parse(archiveData);
			
			for(var i:uint=0;i<archive.length;++i) {
				var subFile:ByteArray=archive.open(i);
				
				subFile.position=0;
				subFile.endian=Endian.LITTLE_ENDIAN;
				subFile=Stock.decompress(subFile);
				
				var frame:BitmapData=readTiledFrame(subFile,xTiles,yTiles);
				var png:ByteArray=PNGEncoder.encode(frame);
				
				var outFile:File=new File(saveDir.nativePath+File.separator+subDir+File.separator+i+".png");
				var fs:FileStream=new FileStream();
				fs.open(outFile,FileMode.WRITE);
				fs.writeBytes(png);
				fs.close();
			}
		}
		
		private function readTiledFrame(data:ByteArray,xTiles:uint,yTiles:uint):BitmapData {
			data.endian=Endian.LITTLE_ENDIAN;
			
			var palette:Vector.<uint>=new Vector.<uint>();
			
			for(var i:uint=0;i<16;++i) {
				palette[i]=RGB555.read555Color(data);
			}
			
			var ob:BitmapData=new BitmapData(xTiles*8,yTiles*8,true);
			var src:Rectangle=new Rectangle(0,0,8,8);
			var dst:Point=new Point();
			
			for(var yTile:uint=0;yTile<yTiles;++yTile) {
				dst.y=yTile*8;
				for(var xTile:uint=0;xTile<xTiles;++xTile) {
					var tile:Tile=new Tile();
					tile.readTile(4,data);
					
					dst.x=8*xTile;
					
					var tileBitmap:BitmapData=tile.toBMD(palette);
					ob.copyPixels(tileBitmap,src,dst);
				}
			}
			
			return ob;
		}
	}
	
}
