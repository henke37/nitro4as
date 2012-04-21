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
			
			//outputAnim("badger",0,32,20);
			//outputAnim("15intro",1823768,32,24);
			//outputAnim("securityVideo",2677052,32,24);
			//outputAnim("epiloge",25266104,32,24);
			//outputBin("archive5",27669216);//useless junk, a bunch of way too content free files
			//outputBin("archive6",27727316);/more junk
			//outputBin("archive7",27731420);//junk
			//outputBin("archive8",27741988);//junk
			
			//outputSingleImage("jplogo.png",27753756,32,24,8);
			//outputSingleImage("enlogo.png",27771340,32,24,8);
						
			//saveDecodedChunk("file9.bin",27753756);
			
			//27787188: uncompressed font
			//27789236: message box tiles
			//27793364: name tags
			//27839572: Misc uncompressed tiles
			
			//27925364
			//27988916
			//outputBin("jpprofiledesc",27988948);//japanese profile descriptions, no palette
			//outputBin("enprofiledesc",28192420);//english profile descriptions, no palette
			
			//outputBin("archive12",28356876);//japanese profile titles, no palette
			//outputBin("archive13",28395640);//english profile titles, no palette
			
			//dumpEvidence();
			
			//outputSingleImage("stuff.png",0x1BBC2B4,
			
			outputSingleImage("bottomBg.png",29401108,32,24);
			
			trace(archiveData.position);
		}
		
		private function dumpEvidence():void {
			const evidenceBase:uint=28433332;
			const evidenceEnd:uint=0x1BBC2B4;
			const evidenceSize:uint=16*2+8*8*8*8*0.5;
			var evidencePos:uint=evidenceBase;
			var i:uint;
			for(i=0;evidencePos<evidenceEnd;evidencePos+=evidenceSize,++i) {
				outputSingleImage("evidence"+File.separator+i+".png",evidencePos,8,8,4,false);
			}
		}
		
		private function outputBin(subDir:String,offset:uint):void {
			archiveData.position=offset;
			
			archive=new Archive();
			archive.parse(archiveData);
			
			for(var i:uint=0;i<archive.length;++i) {
				var subFile:ByteArray=archive.open(i);
				
				subFile.position=0;
				subFile.endian=Endian.LITTLE_ENDIAN;
				subFile=Stock.decompress(subFile);
				
				var outFile:File=new File(saveDir.nativePath+File.separator+subDir+File.separator+i+".bin");
				var fs:FileStream=new FileStream();
				fs.open(outFile,FileMode.WRITE);
				fs.writeBytes(subFile);
				fs.close();
			}
		}
		
		private function saveDecodedChunk(fileName:String,offset:uint):void {
			archiveData.position=offset;
			archiveData.endian=Endian.LITTLE_ENDIAN;
			
			var chunk:ByteArray=Stock.decompress(archiveData);
			
			var outFile:File=new File(saveDir.nativePath+File.separator+fileName);
			var fs:FileStream=new FileStream();
			fs.open(outFile,FileMode.WRITE);
			fs.writeBytes(chunk);
			fs.close();
		}
		
		private function outputSingleImage(fileName:String,offset:uint,xTiles:uint,yTiles:uint,bpp:uint=4,compressed:Boolean=true):void {
			
			archiveData.position=offset;
			archiveData.endian=Endian.LITTLE_ENDIAN;
			
			var chunk:ByteArray;
			
			if(compressed) {
				chunk=Stock.decompress(archiveData);
				chunk.endian=Endian.LITTLE_ENDIAN;
			} else {
				chunk=archiveData;
			}
			
			
			var frame:BitmapData=readTiledFrame(chunk,xTiles,yTiles,bpp);
			var png:ByteArray=PNGEncoder.encode(frame);
			
			var outFile:File=new File(saveDir.nativePath+File.separator+fileName);
			var fs:FileStream=new FileStream();
			fs.open(outFile,FileMode.WRITE);
			fs.writeBytes(png);
			fs.close();
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
		
		private function readTiledFrame(data:ByteArray,xTiles:uint,yTiles:uint,bpp:uint=4):BitmapData {
			data.endian=Endian.LITTLE_ENDIAN;
			
			var palette:Vector.<uint>=new Vector.<uint>();
			
			const paletteSize:uint=bpp==4?16:256;
			
			for(var i:uint=0;i<paletteSize;++i) {
				palette[i]=RGB555.read555Color(data);
			}
			
			var ob:BitmapData=new BitmapData(xTiles*8,yTiles*8,true);
			var src:Rectangle=new Rectangle(0,0,8,8);
			var dst:Point=new Point();
			
			for(var yTile:uint=0;yTile<yTiles;++yTile) {
				dst.y=yTile*8;
				for(var xTile:uint=0;xTile<xTiles;++xTile) {
					var tile:Tile=new Tile();
					tile.readTile(bpp,data);
					
					dst.x=8*xTile;
					
					var tileBitmap:BitmapData=tile.toBMD(palette);
					ob.copyPixels(tileBitmap,src,dst);
				}
			}
			
			return ob;
		}
	}
	
}
