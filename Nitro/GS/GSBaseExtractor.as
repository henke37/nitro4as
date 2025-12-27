package Nitro.GS {
	import flash.display.*;
	import flash.net.*;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.geom.*;
	
	import Nitro.FileSystem.NDS;
	import Nitro.Compression.*;
	import Nitro.Graphics.*;
	
	/** Base class for Ace Attorney game extractors */
	
	public class GSBaseExtractor extends MovieClip {
		
		private var nds:NDS;
		protected var archiveData:ByteArray;
		
		protected var loader:URLLoader;
		
		public var status_txt:TextField;
		
		private var saveDir:File;

		public function GSBaseExtractor(fileName:String) {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,startParsing);
			loader.load(new URLRequest(fileName));
			
			status_txt.text="Loading file...";
		}
		
		private function startParsing(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			archiveData=nds.fileSystem.openFileByName("data.bin");
			
			status_txt.text="File loaded, click to save.";
			stage.addEventListener(MouseEvent.CLICK,startSaving);
		}
		
		private function startSaving(e:MouseEvent):void {
			saveDir=new File();
			saveDir.addEventListener(Event.SELECT,outDirSelected);
			saveDir.browseForDirectory("Output dir");
		}
		
		protected function outDirSelected(e:Event):void {}
		
		protected function get alignedOffset():uint {
			var rounded:uint=archiveData.position;
			
			if(rounded%4!=0) {
				rounded=(uint(rounded/4)+1)*4;
			}
			return rounded;
		}
		
		protected function traceCurrentOffset():void {
			trace(archiveData.position,alignedOffset);
		}
		
		public function outputEvidence(evidenceBase:uint,evidenceEnd:uint):void {
			const evidenceSize:uint=16*2+8*8*8*8*0.5;
			var evidencePos:uint=evidenceBase;
			var i:uint;
			for(i=0;evidencePos<evidenceEnd;evidencePos+=evidenceSize,++i) {
				outputSingleImage("evidence/"+i+".png",evidencePos,8,8,4,false);
			}
		}
		
		public function outputPatch(fileName:String,baseOffset:uint,patchOffset:uint,xTiles:uint,yTiles:uint,singleImage:uint=0,transparent:Boolean=false):void {
			archiveData.position=baseOffset;
			
			var bpp:uint
			
			if(!singleImage) {
				var archive:Archive=new Archive();
				archive.parse(archiveData);
				
				var subFile:ByteArray=archive.open(0);
				subFile.endian=Endian.LITTLE_ENDIAN;
				
				bpp=(subFile.length==16*2)?4:8;
			} else {
				bpp=singleImage;
				subFile=Stock.decompress(archiveData);
			}
			
			var palette:Vector.<uint>=RGB555.readPalette(subFile,bpp);
			
			archiveData.position=patchOffset;
			subFile=Stock.decompress(archiveData);
			
			var patch:BitmapData=readTiles(palette,subFile,xTiles,yTiles,bpp,transparent);
			saveImage(patch,fileName);
		}
		
		public function outputSlicedImage(fileName:String,offset:uint,xTiles:uint=32,yTiles:uint=4,transparent:Boolean=false):void {
			archiveData.position=offset;
			
			var archive:Archive=new Archive();
			archive.parse(archiveData);
			
			var subFile:ByteArray=archive.open(0);
			subFile.endian=Endian.LITTLE_ENDIAN;
			
			const bpp:uint=(subFile.length==16*2)?4:8;
			
			var palette:Vector.<uint>=RGB555.readPalette(subFile,bpp);
			
			var o:BitmapData=new BitmapData(xTiles*8,(archive.length-1)*yTiles*8,false);
			
			const src:Rectangle=new Rectangle(0,0,xTiles*8,yTiles*8);
			var dst:Point=new Point(0,0);
			
			for(var i:uint=1;i<archive.length;++i) {
				subFile=archive.open(i);
				subFile.endian=Endian.LITTLE_ENDIAN;
				
				subFile.position=0;
				subFile.endian=Endian.LITTLE_ENDIAN;
				subFile=Stock.decompress(subFile);
				
				var slice:BitmapData=readTiles(palette,subFile,xTiles,yTiles,bpp,transparent);
				
				dst.y=(i-1)*yTiles*8;
				o.copyPixels(slice,src,dst);
			}
			saveImage(o,fileName);
		}
		
		public function outputBin(subDir:String,offset:uint,decompress:Boolean=true):void {
			archiveData.position=offset;
			
			var archive:Archive=new Archive();
			archive.parse(archiveData);
			
			for(var i:uint=0;i<archive.length;++i) {
				var subFile:ByteArray=archive.open(i);
				
				if(decompress) {
					subFile.position=0;
					subFile.endian=Endian.LITTLE_ENDIAN;
					subFile=Stock.decompress(subFile);
				}
				
				saveFile(subFile,subDir+"/"+i+".bin");
			}
		}
		
		public function saveDecodedChunk(fileName:String,offset:uint):void {
			archiveData.position=offset;
			archiveData.endian=Endian.LITTLE_ENDIAN;
			
			var chunk:ByteArray=Stock.decompress(archiveData);
			
			saveFile(chunk,fileName);
		}
		
		public function outputSingleImage(fileName:String,offset:uint,xTiles:uint=32,yTiles:uint=24,bpp:uint=4,compressed:Boolean=true,transparent:Boolean=false):void {
			
			archiveData.position=offset;
			archiveData.endian=Endian.LITTLE_ENDIAN;
			
			var chunk:ByteArray;
			
			if(compressed) {
				chunk=Stock.decompress(archiveData);
				chunk.endian=Endian.LITTLE_ENDIAN;
			} else {
				chunk=archiveData;
			}
			
			
			var frame:BitmapData=readTiledFrame(chunk,xTiles,yTiles,bpp,transparent);
			saveImage(frame,fileName);
		}
		
		private static const encodingOptions:PNGEncoderOptions=new PNGEncoderOptions();
		
		protected function saveImage(img:BitmapData,fileName:String):void {
			
			var png:ByteArray;
			
			//png=PNGEncoder.encode(img);
			png=img.encode(new Rectangle(0,0,img.width,img.height),encodingOptions);
			
			saveFile(png,fileName);
		}
		
		protected function saveFile(data:ByteArray,fileName:String):void {
			fileName=String("/"+fileName).replace(/\//,File.separator);
			
			var outFile:File=new File(saveDir.nativePath+fileName);
			var fs:FileStream=new FileStream();
			fs.open(outFile,FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
		public function outputVideo(subDir:String,offset:uint,xTiles:uint=32,yTiles:uint=24):void {
			archiveData.position=offset;
			
			var archive:Archive=new Archive();
			archive.parse(archiveData);
			
			for(var i:uint=0;i<archive.length;++i) {
				var subFile:ByteArray=archive.open(i);
				
				subFile.position=0;
				subFile.endian=Endian.LITTLE_ENDIAN;
				subFile=Stock.decompress(subFile);
				
				var frame:BitmapData=readTiledFrame(subFile,xTiles,yTiles);
				
				saveImage(frame,subDir+"/"+i+".png");
			}
		}
		
		protected function readTiledFrame(data:ByteArray,xTiles:uint,yTiles:uint,bpp:uint=4,transparent:Boolean=false):BitmapData {
			data.endian=Endian.LITTLE_ENDIAN;
			
			var palette:Vector.<uint>=RGB555.readPalette(data,bpp);
			
			return readTiles(palette,data,xTiles,yTiles,bpp,transparent);
		}
			
		protected function readTiles(palette:Vector.<uint>,data:ByteArray,xTiles:uint,yTiles:uint,bpp:uint=4,transparent:Boolean=false):BitmapData {
			
			var ob:BitmapData=new BitmapData(xTiles*8,yTiles*8,transparent);
			var src:Rectangle=new Rectangle(0,0,8,8);
			var dst:Point=new Point();
			
			for(var yTile:uint=0;yTile<yTiles;++yTile) {
				dst.y=yTile*8;
				for(var xTile:uint=0;xTile<xTiles;++xTile) {
					var tile:Tile=new Tile();
					tile.readTile(bpp,data);
					
					dst.x=8*xTile;
					
					var tileBitmap:BitmapData=tile.toBMD(palette,0,transparent);
					ob.copyPixels(tileBitmap,src,dst);
				}
			}
			
			return ob;
		}

	}
	
}
