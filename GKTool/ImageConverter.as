package GKTool {
	
	import flash.display.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.*;
	import Nitro.Graphics.*;
	
	public class ImageConverter extends Screen {
		
		private var creator:NCGRCreator;
		
		private var fr:FileReference;
		
		private var loader:Loader;
		
		public var status_txt:TextField;
		public var load_btn:SimpleButton;
		public var palette_btn:SimpleButton;
		public var tiles_btn:SimpleButton;
		
		public function PNGConverter() {
			creator=new NCGRCreator();
			
			fr=new FileReference();
			
			load_btn.addEventListener(MouseEvent.CLICK,selectPicture);
			palette_btn.addEventListener(MouseEvent.CLICK,savePalette);
			tiles_btn.addEventListener(MouseEvent.CLICK,saveTiles);
		}
		
		private function savePalette(e:MouseEvent):void {
			var nclr:NCLR=new NCLR();
			nclr.bitDepth=creator.ncgr.bitDepth;
			nclr.colors=creator.palette;
			fr.save(nclr.save(),"p.nclr");
		}
		
		private function saveTiles(e:MouseEvent):void {
			
			fr.save(creator.ncgr.save(),"p.ncgr");
		}
		
		private function selectPicture(e:Event):void {
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Images","*.jpeg;*.png;*.gif;*.jpg")]);
		}
		
		private function fileSelected(e:Event):void {
			fr.removeEventListener(Event.SELECT,fileSelected);
			fr.addEventListener(Event.COMPLETE,fileLoaded);
			fr.load();
		}
		
		private function fileLoaded(e:Event):void {
			
			loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,picLoaded);
			loader.loadBytes(fr.data);
		}
		
		private function picLoaded(e:Event):void {
			creator.pic=Bitmap(loader.content).bitmapData;
			creator.findPalette();
			
			var b:Bitmap=new Bitmap(drawPalette(creator.palette,true));
			b.scaleX=4;
			b.scaleY=b.scaleX;
			addChild(b);
			
			creator.buildTiles(true);
			
			var render:DisplayObject=creator.ncgr.render(creator.palette);
			render.x=b.width;
			addChild(render);
		}
	}
	
}
