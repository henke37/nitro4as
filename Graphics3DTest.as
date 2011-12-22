package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.system.*;
	
	import Nitro.FileSystem.*;
	import Nitro.FileSystem.EasyFileSystem.*;
	import Nitro.Graphics3D.*;
	
	public class Graphics3DTest extends MovieClip {
		
		private var loader:URLLoader;
		
		public function Graphics3DTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("gk2.nds"));
		}
		
		private function loaded(e:Event):void {
			var nds:NDS=new NDS();
			nds.parse(loader.data);
			
			var fs:IEasyFileSystem=new GK2(nds);
			
			var texture:NSBTX=new NSBTX();
			texture.parse(fs.openFile("jpn/modelitemlocal.bin/1"));
			
			var entry:PaletteEntry=texture.getPaletteByName("bag_01_pl");
			
			var b:Bitmap=new Bitmap(entry.draw());
			b.scaleX=8;
			b.scaleY=8;
			addChild(b);
			
			entry=texture.getPaletteByName("bag_02_pl");
			b=new Bitmap(entry.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8;
			addChild(b);
			
			entry=texture.getPaletteByName("bag_03_pl");
			b=new Bitmap(entry.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			addChild(b);
			
			entry=texture.getPaletteByName("bag_gan_02_pl");
			b=new Bitmap(entry.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			b.y=8;
			addChild(b);
			
			entry=texture.getPaletteByName("bag_gan_04_pl");
			b=new Bitmap(entry.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			b.y=8*2;
			addChild(b);
			
			entry=texture.getPaletteByName("bag_gan_05_pl");
			b=new Bitmap(entry.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			b.y=8*3;
			addChild(b);
		}
	}
	
}
