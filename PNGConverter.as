package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.*;
	import Nitro.Graphics.*;
	
	public class PNGConverter extends MovieClip {
		
		private var creator:NCGRCreator;
		
		private var fr:FileReference;
		
		private var loader:Loader;
		
		public var status_txt:TextField;
		
		public function PNGConverter() {
			creator=new NCGRCreator();
			
			fr=new FileReference();
			
			status_txt.text="Click to load picture";
			
			stage.addEventListener(MouseEvent.CLICK,selectPicture);
		}
		
		private function selectPicture(e:Event):void {
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Images","*.jpeg;*.png;*.gif;*.jpg")]);
		}
		
		private function fileSelected(e:Event):void {
			fr.removeEventListener(Event.SELECT,fileSelected);
			fr.addEventListener(Event.COMPLETE,fileLoaded);
			status_txt.text="Generating optimal palette.";
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
		}
	}
	
}
