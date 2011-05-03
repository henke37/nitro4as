package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	import flash.geom.*;
	
	import Nitro.FileSystem.*;
	import Nitro.Graphics.*;
	import Nitro.Animation.*;
	import Nitro.*;
	import Nitro.GK.*;
	
	
	public class AnimTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		private var player:NANRPlayer;
		
		public function AnimTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,parse);
			loader.load(new URLRequest("game.nds"));
			
			stage.align=StageAlign.TOP_LEFT;
		}
		
		private function parse(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			var archive:GKArchive=new GKArchive();
			archive.parse(nds.fileSystem.openFileByName("com/mapchar.bin"));
			
			var subArchive:GKSubarchive=new GKSubarchive();
			subArchive.parse(archive.open(9));
			
			var paletteData:ByteArray=archive.open(0);
			var palette:NCLR=new NCLR();
			palette.parse(paletteData);
			
			var tileData:ByteArray=subArchive.open(2);
			var tiles:NCGR=new NCGR();
			tiles.parse(tileData);
			
			//var renderedTiles:DisplayObject=tiles.render(palette.colors,0,false);
			//addChild(renderedTiles);
			
			var cellData:ByteArray=subArchive.open(0);
			var cells:NCER=new NCER();
			cells.parse(cellData);
			
			var animData:ByteArray=subArchive.open(1);
			var anims:NANR=new NANR();
			anims.parse(animData);
			
			trace(anims.toXML().toXMLString());
			
			player=new NANRPlayer(palette,tiles,cells,anims.anims[0]);
			
			player.x=50;
			player.y=200;
			
			addChild(player);
			player.play();
			
			addEventListener(Event.ENTER_FRAME,moveRight);
		}
		
		private function moveLeft(e:Event):void {
			player.x-=4;
			if(player.x<=-20) player.x=stage.stageWidth;
		}
		
		private function moveRight(e:Event):void {
			player.x+=4;
			if(player.x-20>stage.stageWidth) player.x=0;
		}
	}
}
