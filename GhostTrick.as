package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.filesystem.*;
	import flash.text.*;
	
	import fl.controls.*;
	import fl.containers.*;
	
	import com.adobe.images.PNGEncoder;
	
	import Nitro.Apollo.*;
	import Nitro.FileSystem.NDS;
	import Nitro.GhostTrick.*;
	
	public class GhostTrick extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDS;
		
		private var bitmapDisplay:Bitmap;
		private var bmd:BitmapData;
		
		/** @private */
		public var imageIndex_mc:NumericStepper;
		/** @private */
		public var imageHolder_mc:ScrollPane;
		/** @private */
		public var status_txt:TextField;
		
		/** @private */
		public var ripSingle_mc:Button;
		/** @private */
		public var ripAll_mc:Button;
		
		private var outputDestination:File;
		
		private var mainPack:CPAC;
		private var subArchive:SubArchive;
		
		public function GhostTrick() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("GhostTrick.nds"));
			
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			
			ripSingle_mc.enabled=false;
			ripAll_mc.enabled=false;
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			mainPack=new CPAC();
			mainPack.parse(nds.fileSystem.openFileByName("cpac_2d.bin"));
			
			/*var fr:FileReference=new FileReference();
			fr.save(mainPack.open(5),"5.bin");*/
			
			subArchive=new SubArchive();
			subArchive.parse(mainPack.open(4));
			
			bitmapDisplay=new Bitmap();
			imageHolder_mc.source=bitmapDisplay;
			imageHolder_mc.visible=false;
			
			showImage(1);
			
			imageIndex_mc.minimum=0;
			imageIndex_mc.maximum=subArchive.length-1;
			imageIndex_mc.value=1;
			imageIndex_mc.addEventListener(Event.CHANGE,indexChange);
			
			ripAll_mc.enabled=true;
			ripAll_mc.addEventListener(MouseEvent.CLICK,ripAllClick);
			
			ripSingle_mc.addEventListener(MouseEvent.CLICK,ripSingleClick);
			
			//dumpArchive("cpac_2d.bin",0);
			
			//dumpFile(3,21288);
		}
		
		private function ripSingleClick(e:MouseEvent):void {
			outputDestination=new File();
			outputDestination.save(PNGEncoder.encode(bmd),imageIndex_mc.value.toString()+".png");
		}
		
		private function ripAllClick(e:MouseEvent):void {
			outputDestination=new File();
			outputDestination.browseForDirectory("Output directory");
			outputDestination.addEventListener(Event.SELECT,outputSelected);
		}
		
		private function outputSelected(e:Event):void {
			for(var index:uint=0;index<subArchive.length;++index) {
				try {
					var imageData:ByteArray=subArchive.open(index);
					
					if(!imageData) continue;
				
				
					var image:TiledImage=new TiledImage();
					image.parse(imageData);
					
					var img:BitmapData=image.toBMD(false);
					
					saveImage(img,"cpac_2d/4/"+index+".png");
					
				} catch(err:Error) {
					trace(err.getStackTrace());
				}
			}
		}
		
		protected function saveImage(img:BitmapData,fileName:String):void {
			var png:ByteArray=PNGEncoder.encode(img);
			
			saveFile(png,fileName);
		}
		
		protected function saveFile(data:ByteArray,fileName:String):void {
			fileName=String("/"+fileName).replace(/\//,File.separator);
			
			var outFile:File=new File(outputDestination.nativePath+fileName);
			var fs:FileStream=new FileStream();
			fs.open(outFile,FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
		private function indexChange(e:Event):void {
			showImage(imageIndex_mc.value);
		}
		
		private function showImage(imageIndex:uint):void {
			try {
				var imageData:ByteArray=subArchive.open(imageIndex);
				
				if(!imageData) {
					imageHolder_mc.visible=false;
					status_txt.visible=true;
					ripSingle_mc.enabled=false;
					status_txt.text="Unused archive slot.";
					return;
				}
				
				var image:TiledImage=new TiledImage();
				
				image.parse(imageData);
				
				bmd=image.toBMD(false);
				bitmapDisplay.bitmapData=bmd;
				
				imageHolder_mc.update();
				imageHolder_mc.visible=true;
				ripSingle_mc.enabled=true;
				status_txt.visible=false;
			} catch(err:Error) {
				imageHolder_mc.visible=false;
				status_txt.visible=true;
				ripSingle_mc.enabled=false;
				status_txt.text=err.getStackTrace();
			}
		}
		
		private function dumpFile(archive:uint,id:uint):void {
			var subArchive:SubArchive=new SubArchive();
			subArchive.parse(mainPack.open(archive));
			
			var data:ByteArray=subArchive.open(id);
			var fr:FileReference=new FileReference();
			fr.save(data,id+".bin");
		}
		
		private function dumpArchive(fileName:String,id:uint):void {
			
			var cpack:CPAC=new CPAC();
			cpack.parse(nds.fileSystem.openFileByName(fileName));
			
			var subfile:ByteArray=cpack.open(id);
			
			var subarchive:SubArchive=new SubArchive();
			subarchive.parse(subfile);
			
			trace(subarchive.length);
			
			for(var subid:uint=0;subid<subarchive.length;++subid) {
			
				subfile=subarchive.open(subid);
				
				if(!subfile) continue;
			
				var fs:FileStream=new FileStream();
				fs.open(new File("C:\\Users\\Henrik\\Desktop\\ds reverse engineering\\unpacked\\ghost trick unpacked\\data\\"+fileName.match(/^[^\.]+/)[0]+"\\"+id+"\\"+subid+".bin"),FileMode.WRITE);
				
				fs.writeBytes(subfile);
				
				fs.close();
			}
			
		}
	}
	
}
