package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.filesystem.*;
	import flash.text.*;
	
	import Nitro.FileSystem.NDS;
	import Nitro.GK.*;
	import Nitro.Graphics.*;
	import Nitro.Compression.*;
	
	import fl.controls.*;
	import fl.events.*;
	import fl.containers.*;
	
	import com.adobe.images.PNGEncoder;
	
	
	public class GKTest extends MovieClip {
		
		private var romSelector:File;
		
		private var masterArchive:MasterArchive;
		
		private var outDir:File;
		
		/** @private */
		public var dumpBins_mc:Button;
		/** @private */
		public var dumpScreen_mc:Button;
		
		public var graphicsCompressed_mc:CheckBox;
		public var transparent_mc:CheckBox;
		
		public var screen_mc:NumericStepper;
		public var palette_mc:NumericStepper;
		public var graphics_mc:NumericStepper;
		
		public var cols_mc:NumericStepper;
		public var rows_mc:NumericStepper;
		
		public var bpp_mc:ComboBox;
		public var graphicsMode_mc:ComboBox;
		public var tilemapMode_mc:ComboBox;
		
		public var loadRom_mc:Button;
		public var decode_mc:Button;
		public var save_mc:Button;
		
		public var output_mc:ScrollPane;
		
		private static const screens:Array=[
			{palId:4527,gfxId:4529,scrnId:4528,bpp:8},
			{palId:4531,gfxId:4532,scrnId:4530,bpp:8}
		];
		
		private static const bitmaps:Array=[
			{palId:4525,gfxId:4526,bpp:8}
		];
		
		public function GKTest() {
			loadRom_mc.addEventListener(ComponentEvent.BUTTON_DOWN,loadClick);
		}
		
		private function loadClick(e:Event):void {
			romSelector=new File();
			romSelector.addEventListener(Event.SELECT,romSelected);
			romSelector.browseForOpen("Select rom to load",[ new FileFilter("NDS rom","*.nds") ]);
		}
		
		private function romSelected(e:Event):void {
			var fs:FileStream=new FileStream();
			fs.open(romSelector,FileMode.READ);
			
			var romData:ByteArray=new ByteArray();
			
			fs.readBytes(romData);
			fs.close();
			
			loaded(romData);
		}
		
		private function loaded(data:ByteArray):void {
			var nds:NDS=new NDS();
			nds.parse(data);
			
			var archiveData:ByteArray=nds.fileSystem.openFileByName("files/romfile.bin");
			
			masterArchive=new MasterArchive();
			masterArchive.parse(archiveData);
			
			enableUI();
		}
		
		private function enableUI():void {
			dumpBins_mc.enabled=true;
			dumpBins_mc.addEventListener(MouseEvent.CLICK,binDumpClick);
			
			const maxFileId:uint=masterArchive.length-1;
			
			//screen_mc.enabled=true;
			screen_mc.maximum=maxFileId;
			
			graphics_mc.enabled=true;
			graphics_mc.maximum=maxFileId;
			
			palette_mc.enabled=true;
			palette_mc.maximum=maxFileId;
			
			cols_mc.enabled=true;
			rows_mc.enabled=true;
			bpp_mc.enabled=true;
			graphicsCompressed_mc.enabled=true;
			
			tilemapMode_mc.enabled=true;
			tilemapMode_mc.addEventListener(Event.CHANGE,tilemapModeChange);
			
			loadRom_mc.enabled=false;
			
			decode_mc.addEventListener(MouseEvent.CLICK,decodeClick);
			decode_mc.enabled=true;
			
			graphicsMode_mc.enabled=true;
			graphicsMode_mc.addEventListener(Event.CHANGE,graphicsModeChange);
			
			transparent_mc.enabled=true;
			
			save_mc.addEventListener(ComponentEvent.BUTTON_DOWN,saveClick);
		}
		
		private function get useTilemap():Boolean {
			return tilemapMode_mc.selectedItem.data!="off" && graphicsMode_mc.selectedItem.data=="tiled";
		}
		
		private function tilemapModeChange(e:Event):void {
			screen_mc.enabled=useTilemap;
			graphicsMode_mc.enabled=tilemapMode_mc.selectedItem.data=="off";
		}
		
		private function graphicsModeChange(e:Event):void {
			screen_mc.enabled=useTilemap;
			tilemapMode_mc.enabled=graphicsMode_mc.selectedItem.data=="tiled";
		}
		
		private function decodeClick(e:Event):void {
			try {
				var content:DisplayObject;
				
				if(useTilemap) {
				
					content=decodeScreenInternal(
						palette_mc.value,
						bpp_mc.selectedItem.data,
						graphics_mc.value,
						graphicsCompressed_mc.selected,
						transparent_mc.selected,
						screen_mc.value,
						cols_mc.value,
						rows_mc.value,
						tilemapMode_mc.selectedItem.data=="advanced"
					);
				} else {
					content=decodeBitmapInternal(
						palette_mc.value,
						bpp_mc.selectedItem.data,
						graphics_mc.value,
						graphicsCompressed_mc.selected,
						transparent_mc.selected,
						graphicsMode_mc.selectedItem.data=="linear",
						cols_mc.value,
						rows_mc.value
					);
				}
				
				save_mc.enabled=true;
				
				output_mc.source=content;
			} catch(err:Error) {
				var tf:TextField=new TextField();
				tf.text=err.message;
				tf.autoSize=TextFieldAutoSize.LEFT;
				output_mc.source=tf;
				
				save_mc.enabled=false;
			}
			
			output_mc.refreshPane();
		}
		
		private function saveClick(e:Event):void {
			var png:ByteArray=encodeImage(DisplayObject(output_mc.source));
			
			outDir=new File();
			outDir.save(png,graphics_mc.value+".png");
		}
		
		private function binDumpClick(e:MouseEvent):void {
			outDir=new File();
			outDir.addEventListener(Event.SELECT,selected);
			outDir.browseForDirectory("Save dir");
		}
		
		private function screenDumpClick(e:MouseEvent):void {
			var screen:DisplayObject=decodeScreen(0);
			addChild(screen);
			
			var fr:FileReference=new FileReference();
			fr.save(encodeImage(screen),"screen.png");
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
		
		private function decodeScreen(id:uint):DisplayObject {
			var scrn:Object=screens[id];
			return decodeScreenInternal(scrn.palId,scrn.bpp,scrn.gfxId,scrn.compressedGfx,scrn.transparent,scrn.scrnId);
		}
		
		private function decodeBitmap(id:uint):DisplayObject {
			var pic:Object=bitmaps[id];
			return decodeBitmapInternal(pic.palId,pic.bpp,pic.gfxId,pic.compressedGfx,pic.transparent,pic.linear,pic.cols,pic.rows);
		}
		
		private function encodeImage(drawable:DisplayObject):ByteArray {
			var bmd:BitmapData=new BitmapData(drawable.width,drawable.height);
			bmd.draw(drawable);
			return PNGEncoder.encode(bmd);
		}
		
		private function decodeScreenInternal(palId:uint,bpp:uint,gfxId:uint,compressedGfx:Boolean,transparent:Boolean,scrnId:uint,cols:uint=32,rows:uint=24,advanced:Boolean=true):DisplayObject {
			var palData:ByteArray=masterArchive.open(palId);
			palData.endian=Endian.LITTLE_ENDIAN;
			var decodedPal:Vector.<uint>=RGB555.readPalette(palData,bpp);
			
			var gfxData:ByteArray=masterArchive.open(gfxId);
			gfxData.endian=Endian.LITTLE_ENDIAN;
			if(compressedGfx) {
				gfxData=Stock.decompress(gfxData);
			}
			
			var gfx:GraphicsBank=new GraphicsBank();
			gfx.bitDepth=bpp;
			gfx.parseTiled(gfxData,0,gfxData.length);
			
			var scrnData:ByteArray=masterArchive.open(scrnId);
			var scrn:TileMappedScreen=new TileMappedScreen();
			scrn.loadEntries(scrnData,cols,rows,advanced);
			
			return scrn.render(gfx,decodedPal,transparent);
		}
		
		private function decodeBitmapInternal(palId:uint,bpp:uint,gfxId:uint,compressedGfx:Boolean,transparent:Boolean=false,linearMode:Boolean=false,cols:uint=32,rows:uint=24):DisplayObject {
			var palData:ByteArray=masterArchive.open(palId);
			palData.endian=Endian.LITTLE_ENDIAN;
			var decodedPal:Vector.<uint>=RGB555.readPalette(palData,bpp);
			
			var gfxData:ByteArray=masterArchive.open(gfxId);
			gfxData.endian=Endian.LITTLE_ENDIAN;
			if(compressedGfx) {
				gfxData=Stock.decompress(gfxData);
			}
			
			var gfx:GraphicsBank=new GraphicsBank();
			gfx.bitDepth=bpp;
			gfx.tilesX=cols;
			gfx.tilesY=rows;
			
			if(linearMode) {
				gfx.parseScaned(gfxData,0,gfxData.length);
			} else {
				gfx.parseTiled(gfxData,0,gfxData.length);
			}
			
			return gfx.render(decodedPal,0,transparent);
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
