package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.text.*;
	
	import Nitro.Apollo.*;
	import Nitro.FileSystem.NDS;
	import Nitro.GhostTrick.*;
	import Nitro.FileSystem.File;
	
	import Nitro.Graphics.*;
	
	import fl.containers.*;
	import fl.controls.*;
	
	public class GhostTrick2 extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var mainPack:CPAC;
		private var subArchive:SubArchive;
		
		public var pane_mc:ScrollPane;
		public var frame_mc:NumericStepper;
		public var drawCells_mc:CheckBox;
		
		public function GhostTrick2() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("GhostTrick.nds"));
			
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			mainPack=new CPAC();
			mainPack.parse(nds.fileSystem.openFileByName("cpac_2d.bin"));
			
			subArchive=new SubArchive();
			subArchive.parse(mainPack.open(3));
			
			//showCell();
			
			//testArchive(14692);
			
			//findPal();
			
			//testCells(14693,116);
			
			//this.showCell(0,14692,14694,14693,0);
			
			frame_mc.addEventListener(Event.CHANGE,showCell);
			drawCells_mc.addEventListener(Event.CHANGE,showCell);
			showCell(null);
		}
		
		private function testCells(cellsFile:uint,len:uint):void {
			var cellBank:CellBank=new CellBank();
			cellBank.parse(subArchive.open(cellsFile),len);
			
			var cell:Cell=cellBank.cells[0];
			
			var boxes:DisplayObject=cell.rendBoxes();
			boxes.x=150;
			boxes.y=150;
			addChild(boxes);
		}
		
		
		/*
		private function findPal():void {

			var subsub:SplitArchive=new SplitArchive();
			subsub.parse(subArchive.open(14692),subArchive.open(14694));
			
			var tileData:ByteArray=subsub.open(0);
			
			palette_mc.addEventListener(Event.CHANGE,nextPal);
			tileSet=new GraphicsBank();
			tileSet.bitDepth=4;
			tileSet.tilesX=8;
			tileSet.tilesY=48;
			
			tileSet.parseTiled(tileData,0,tileData.length);
			
			
		}
		
		private function nextPal(e:Event):void {
			var palData:ByteArray=subArchive.open(palfile_mc.value);
			palData.position=palette_mc.value;
			var pal:Vector.<uint>=RGB555.readPalette(palData,4);
			
			addChild(tileSet.render(pal,0,false));
		}*/
		
		private function testArchive(startId:uint):void {
			var subsub:SplitArchive=new SplitArchive();
			subsub.parse(subArchive.open(startId),subArchive.open(startId+2));
			
			for(var i:uint=0;i<subsub.length;++i) {
				var data:ByteArray=subsub.open(i);
				/*
				var file:File=new File("C:\\Users\\Henrik\\Desktop\\ghost trick\\"+i+".bin");
				var fs:FileStream=new FileStream();
				fs.open(file,FileMode.WRITE);
				fs.writeBytes(data);
				fs.close();
				*/
			}	
		}
		
		private function showCell(e:Event):void {
			var cellId:uint=frame_mc.value;
			var borders:Boolean=drawCells_mc.selected;
			var obj:Sprite=rendCell(0,14692,14694,14693,cellId,borders);
			
			pane_mc.source=obj;
			pane_mc.refreshPane();
		}
			
		private function rendCell(paletteId:uint,pixelsTableId:uint,pixelsDataId:uint,cellBankId:uint,cellId:uint,borders:Boolean):Sprite {
			
			var pal:Vector.<uint>=new <uint> [
				0xFF00FF, 0x00FF00, 0xFF0000, 0x0000FF,
				0xFF00FF, 0xFFFF00, 0x00FFFF, 0xFFAA00,
				0xAAFF00, 0x00AAFF, 0x00FFAA, 0xAA00AA,
				0xAAAA00, 0xAAAAAA, 0xFF00AA, 0xAA00FF
			];
			
			var subsub:SplitArchive=new SplitArchive();
			subsub.parse(subArchive.open(pixelsTableId),subArchive.open(pixelsDataId));
			
			var cellBank:CellBank=new CellBank();
			cellBank.parse(subArchive.open(cellBankId),subsub.length);
			
			var tileData:ByteArray=subsub.open(cellId);
			var tileSet:GraphicsBank=new GraphicsBank();
			tileSet.bitDepth=4;
			tileSet.parseTiled(tileData,0,tileData.length);
			
			var cell:Cell=cellBank.cells[cellId];
			
			var out:Sprite=new Sprite();
			
			var obj:DisplayObject=cell.rend(pal,tileSet,false,true);
			obj.x=180;
			obj.y=150;
			out.addChild(obj);
			
			if(borders) {			
				obj=cell.rendBoxes(0,false);
				obj.x=180;
				obj.y=150;
				out.addChild(obj);
			}
			
			return out;
		}
	}
	
}
