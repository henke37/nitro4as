package {
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	
	import Nitro.FileSystem.*;	
	import Nitro.SDAT.*;
	import Nitro.*;
	
	public class RomMapGen extends MovieClip {
		
		private var loader:URLLoader;
		
		private var nds:NDSParser;
		
		private var sdat:SDATReader;
		
		public var status_txt:TextField;
		
		private static const iconZoom:Number=10;
		private static const titleHeight:Number=40;
		
		public function RomMapGen() {			
			
			if(loaderInfo.url.match(/^file:/) && false) {
				status_txt.text="Loading data";
				loader=new URLLoader();
				loader.addEventListener(Event.COMPLETE,loaded);
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.load(new URLRequest("game.nds"));
			} else {
				status_txt.text="Click to load game from disk";
				stage.addEventListener(MouseEvent.CLICK,stageClick);
			}
		}
		
		var fr:FileReference;
		
		private function stageClick(e:MouseEvent):void {
			
			fr=new FileReference();
			fr.addEventListener(Event.SELECT,fileSelected);
			fr.browse([new FileFilter("Nitro games","*.nds")]);
		}
		
		private function fileSelected(e:Event):void {
			stage.removeEventListener(MouseEvent.CLICK,stageClick);
			
			fr.addEventListener(Event.COMPLETE,frLoaded);
			status_txt.text="Loading data";
			fr.load();
			
		}
		
		private function frLoaded(e:Event):void {	
			nds=new NDSParser(fr.data);
			setup();
		}
		
		private function loaded(e:Event):void {
			nds=new NDSParser(loader.data);
			setup();
		}
		
		private function setup():void {
			status_txt.text="Data loaded. Click to save";
			stage.addEventListener(MouseEvent.CLICK,saveDump);
		}
		
		private function saveDump(e:MouseEvent):void {
			fr=new FileReference();
			var xml:XML=<nds>
				<arm7 offset={nds.arm7Offset} size={nds.arm7Len} mirror={nds.arm7Mirror} start={nds.arm7ExecuteStart} />
				<arm9 offset={nds.arm9Offset} size={nds.arm9Len} mirror={nds.arm9Mirror} start={nds.arm9ExecuteStart}  />
			</nds>;
			
			if(nds.banner) {
				xml.appendChild(<banner offset={nds.bannerOffset}>
					<title lang="jp">{nds.banner.jpTitle}</title>
					<title lang="en">{nds.banner.enTitle}</title>
					<title lang="it">{nds.banner.itTitle}</title>
					<title lang="de">{nds.banner.deTitle}</title>
					<title lang="fr">{nds.banner.frTitle}</title>
					<title lang="es">{nds.banner.esTitle}</title>
				</banner>);
			}
			
			xml.appendChild(dumpFs(nds.fileSystem.rootDir));
			
			if(nds.arm7Overlays) {
				var overlay:XML=<overlays cpu="arm7" offset={nds.arm7OverlayOffset} size={nds.arm7OverlaySize}/>;
				addOverlays(overlay,nds.arm7Overlays);
				xml.appendChild(overlay);
			}
			
			if(nds.arm9Overlays) {
				overlay=<overlays cpu="arm9" offset={nds.arm9OverlayOffset} size={nds.arm9OverlaySize}/>;
				addOverlays(overlay,nds.arm9Overlays);
				xml.appendChild(overlay);
			}
			
			
			fr.save(xml,"ndsmap.xml");
		}
		
		private static function addOverlays(xml:XML,overlays:Vector.<Overlay>):void {
			for each(var overlay:Overlay in overlays) {
				xml.appendChild(<overlay id={overlay.id} fileId={overlay.fileId}>
					<ram address={overlay.ramAddress} size={overlay.ramSize} />
					<bss size={overlay.bssSize} start={overlay.bssStart} stop={overlay.bssStop} />
				</overlay>);
			}
		}
	}
}