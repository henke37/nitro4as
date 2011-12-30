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
			
			var textureBank:NSBTX=new NSBTX();
			textureBank.parse(fs.openFile("jpn/modelitemlocal.bin/1"));
			
			var palette:PaletteEntry=textureBank.getPaletteByName("bag_01_pl");
			
			var b:Bitmap=new Bitmap(palette.draw());
			b.scaleX=8;
			b.scaleY=8;
			addChild(b);
			
			palette=textureBank.getPaletteByName("bag_02_pl");
			b=new Bitmap(palette.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8;
			addChild(b);
			
			palette=textureBank.getPaletteByName("bag_03_pl");
			b=new Bitmap(palette.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			addChild(b);
			
			palette=textureBank.getPaletteByName("bag_gan_02_pl");
			b=new Bitmap(palette.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			b.y=8;
			addChild(b);
			
			palette=textureBank.getPaletteByName("bag_gan_04_pl");
			b=new Bitmap(palette.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			b.y=8*2;
			addChild(b);
			
			palette=textureBank.getPaletteByName("bag_gan_05_pl");
			b=new Bitmap(palette.draw());
			b.scaleX=8;
			b.scaleY=8;
			b.x=16*8*2;
			b.y=8*3;
			addChild(b);
			
			var texture:TextureEntry=textureBank.getTextureByName("bag_01");
			b=new Bitmap(texture.draw(textureBank.getPaletteByName("bag_01_pl")));
			//b.scaleX=8;
			//b.scaleY=8;
			b.y=16*8;
			addChild(b);
			
			texture=textureBank.getTextureByName("bag_03");
			b=new Bitmap(texture.draw(textureBank.getPaletteByName("bag_03_pl")));
			//b.scaleX=8;
			//b.scaleY=8;
			b.y=16*8;
			b.x=256;
			addChild(b);
			
			var model:NSBMD=new NSBMD();
			model.parse(fs.openFile("jpn/modelitemlocal.bin/0"));
		}
	}
	
}
