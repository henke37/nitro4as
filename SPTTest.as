﻿package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import Nitro.*;
	import Nitro.FileSystem.*;
	import Nitro.GK.*;	
	
	public class SPTTest extends MovieClip {
		
		private var nds:NDS;
		
		private var loader:URLLoader;
		
		public function SPTTest() {
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
			archive.parse(nds.fileSystem.openFileByName("jpn/spt.bin"));
			
			var scripts:XML=<scripts file="spt.bin"/>
			
			for(var i:uint=0;i<archive.length;++i) {
				
				try {
			
					var spt:SPT=new SPT();
					spt.parse(archive.open(i));
					
					var scriptFile:XML=<scriptFile id={i} />;
					
					/*for each(var ent in spt.sections)  {
						trace(ent.offset,ent.size,ent.flag1,ent.flag2);
					}*/
					
					for(var j:uint=0;j<spt.length;++j) {
						scriptFile.appendChild(spt.parseSection(j));
					}
					scripts.appendChild(scriptFile);
				} catch (err:ArgumentError) {
					scripts.appendChild(<unknownFile id={i} />);
				}
			}
			
			trace(scripts);
		}
	}
}