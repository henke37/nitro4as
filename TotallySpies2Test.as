package  {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.filesystem.*;
	import flash.geom.*;
	
	import Nitro.FileSystem.NDS;
	import Nitro.Graphics.*;
	import Nitro.Compression.Stock;
	import Nitro.FileSystem.File;
	import Nitro.FileSystem.AbstractFile;
	import Nitro.WildMagic.*;
	
	public class TotallySpies2Test extends MovieClip {
		
		private var loader:URLLoader;
		private var nds:NDS;
		
		private static const basePath:String="c:\\users\\henrik\\desktop\\ts2dump";
		
		public function TotallySpies2Test() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("ts2.nds"));
		}
		
		private function loaded(e:Event):void {
			nds=new NDS();
			nds.parse(loader.data);
			
			extractAll();
			
			//trace(nds.fileSystem.rootDir.files);
			//var img:DisplayObject=loadBG("Cine_ST01-01A");
			//addChild(img);
			
			//var fr:FileReference=new FileReference();
			//fr.save(openFile("Cine_ST01-01A00.NSCR.lz"),"Cine_ST01-01A00.NSCR.lz");
			
			//extractTexture("Levels/Alex_Arm.wmif");
		}
		
		private function extractTextures():void {
			const files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(
				nds.fileSystem.rootDir,
				/\.wmif$/,
				true,
				false
			);
			
			for each(var file:Nitro.FileSystem.File in files) {
				var fileName:String=nds.fileSystem.getFullNameForFile(file);
				extractTexture(fileName);
			}
		}
		
		private function extractTexture(baseName:String) {
			var wmif:WMIF=new WMIF();
			wmif.parse(nds.fileSystem.openFileByName(baseName));
			var wmpf:WMPF=new WMPF();
			wmpf.parse(nds.fileSystem.openFileByName(baseName+".wmpf"));
			var palette:Vector.<uint>=RGB555.paletteFromRGB555(wmpf.colors);
			
			var render:DisplayObject=wmif.render(palette);
			
			saveItem(baseName,render);
		}
		
		private function extractAll():void {
			var start=getTimer();
			extractBGs();
			extractCellBanks();
			extractTextures();
			trace(getTimer()-start);
		}
		
		private function extractCellBanks():void {
			const files:Vector.<AbstractFile>=nds.fileSystem.searchForFile(
				nds.fileSystem.rootDir,
				/\.NCER\.lz/
			);
			for each(var file:Nitro.FileSystem.File in files) {
				try {
					extractCellBank(
						file.name.replace("NCER","NCLR"),
						file.name.replace("NCER","NCGR"),
						file.name
					);
					trace("Success",file.name);
				} catch(err:Error) {
					trace("Fail",file.name);
				}
			}
		}
		
		private function extractCellBank(pal:String,cgr:String,bank:String):void {
			var nclr:NCLR=new NCLR();
			nclr.parse(openFile(pal));
			var palette:Vector.<uint>=RGB555.paletteFromRGB555(nclr.colors);
			var ncgr:NCGR=new NCGR();
			ncgr.parse(openFile(cgr));
			var ncer:NCER=new NCER();
			ncer.parse(openFile(bank));
			
			if(ncer.cells.length==1) {
				saveItem(bank,ncer.rend(0,palette,ncgr));
			} else {
				for(var cell:uint=0;cell<ncer.cells.length;++cell)
				saveItem(bank+flash.filesystem.File.separator+cell.toString(),ncer.rend(cell,palette,ncgr));
			}
		}
		
		private function extractBGs():void {
			extractBG("Centrifugeuse","Centrifugeuse00","Centrifugeuse00");
			//extractBG("Centrifugeuse","Centrifugeuse01","Centrifugeuse01");
			//extractBG("Centrifugeuse","Centrifugeuse02","Centrifugeuse02");
			//extractBG("Centrifugeuse","Centrifugeuse03","Centrifugeuse03");
			
			extractBG("Cine_ST01-01B","Cine_ST01-01B00","Cine_ST01-01B00");
			extractBG("Cine_ST01-02A","Cine_ST01-02A00","Cine_ST01-02A00");
			extractBG("Cine_ST01-02B","Cine_ST01-02B00","Cine_ST01-02B00");
			extractBG("Cine_ST01-03A","Cine_ST01-03A00","Cine_ST01-03A00");
			extractBG("Cine_ST01-04A","Cine_ST01-04A00","Cine_ST01-04A00");
			extractBG("Cine_ST01-05A","Cine_ST01-05A00","Cine_ST01-05A00");
			extractBG("Cine_ST01-05B","Cine_ST01-05B00","Cine_ST01-05B00");
			extractBG("Cine_ST01-06A","Cine_ST01-06A00","Cine_ST01-06A00");
			extractBG("Cine_ST01-07A","Cine_ST01-07A00","Cine_ST01-07A00");
			extractBG("Cine_ST01-08A","Cine_ST01-08A00","Cine_ST01-08A00");
			extractBG("Cine_ST01-08B","Cine_ST01-08B00","Cine_ST01-08B00");
			extractBG("Cine_ST01-09A","Cine_ST01-09A00","Cine_ST01-09A00");
			extractBG("Cine_ST01-10A","Cine_ST01-10A00","Cine_ST01-10A00");
			extractBG("Cine_ST01-11A","Cine_ST01-11A00","Cine_ST01-11A00");
			extractBG("Cine_ST01-12A","Cine_ST01-12A00","Cine_ST01-12A00");
			extractBG("Cine_ST01-13A","Cine_ST01-13A00","Cine_ST01-13A00");
			extractBG("Cine_ST01-14A","Cine_ST01-14A00","Cine_ST01-14A00");
			extractBG("Cine_ST01-15A","Cine_ST01-15A00","Cine_ST01-15A00");
			extractBG("Cine_ST01-16A","Cine_ST01-16A00","Cine_ST01-16A00");
			extractBG("Cine_ST01-16B","Cine_ST01-16B00","Cine_ST01-16B00");
			extractBG("Cine_ST01-17A","Cine_ST01-17A00","Cine_ST01-17A00");
			extractBG("Cine_ST01-18A","Cine_ST01-18A00","Cine_ST01-18A00");
			extractBG("Cine_ST01-19A","Cine_ST01-19A00","Cine_ST01-19A00");
			extractBG("Cine_ST01-20A","Cine_ST01-20A00","Cine_ST01-20A00");
			extractBG("Cine_ST01-21A","Cine_ST01-21A00","Cine_ST01-21A00");
			extractBG("Cine_ST01-22A","Cine_ST01-22A00","Cine_ST01-22A00");
			
			extractBG("Cine_ST02-01B","Cine_ST02-01B00","Cine_ST02-01B00");
			extractBG("Cine_ST02-03A","Cine_ST02-03A00","Cine_ST02-03A00");
			extractBG("Cine_ST02-03B","Cine_ST02-03B00","Cine_ST02-03B00");
			extractBG("Cine_ST02-04A","Cine_ST02-04A00","Cine_ST02-04A00");
			extractBG("Cine_ST02-06A","Cine_ST02-06A00","Cine_ST02-06A00");
			extractBG("Cine_ST02-07A","Cine_ST02-07A00","Cine_ST02-07A00");
			extractBG("Cine_ST02-07B","Cine_ST02-07B00","Cine_ST02-07B00");
			extractBG("Cine_ST02-08A","Cine_ST02-08A00","Cine_ST02-08A00");
			extractBG("Cine_ST02-09A","Cine_ST02-09A00","Cine_ST02-09A00");
			extractBG("Cine_ST02-10A","Cine_ST02-10A00","Cine_ST02-10A00");
			extractBG("Cine_ST02-11A","Cine_ST02-11A00","Cine_ST02-11A00");
			extractBG("Cine_ST02-11B","Cine_ST02-11B00","Cine_ST02-11B00");
			extractBG("Cine_ST02-12A","Cine_ST02-12A00","Cine_ST02-12A00");
			extractBG("Cine_ST02-13A","Cine_ST02-13A00","Cine_ST02-13A00");
			extractBG("Cine_ST02-14A","Cine_ST02-14A00","Cine_ST02-14A00");
			extractBG("Cine_ST02-14B","Cine_ST02-14B00","Cine_ST02-14B00");
			extractBG("Cine_ST02-15A","Cine_ST02-15A00","Cine_ST02-15A00");
			extractBG("Cine_ST02-16A","Cine_ST02-16A00","Cine_ST02-16A00");
			extractBG("Cine_ST02-16B","Cine_ST02-16B00","Cine_ST02-16B00");
			extractBG("Cine_ST02-17A","Cine_ST02-17A00","Cine_ST02-17A00");
			extractBG("Cine_ST02-18A","Cine_ST02-18A00","Cine_ST02-18A00");
			extractBG("Cine_ST02-18B","Cine_ST02-18B00","Cine_ST02-18B00");
			extractBG("Cine_ST02-19A","Cine_ST02-19A00","Cine_ST02-19A00");
			extractBG("Cine_ST02-20A","Cine_ST02-20A00","Cine_ST02-20A00");
			extractBG("Cine_ST02-21A","Cine_ST02-21A00","Cine_ST02-21A00");
			extractBG("Cine_ST02-21B","Cine_ST02-21B00","Cine_ST02-21B00");
			extractBG("Cine_ST02-22A","Cine_ST02-22A00","Cine_ST02-22A00");
			extractBG("Cine_ST02-22B","Cine_ST02-22B00","Cine_ST02-22B00");
			extractBG("Cine_ST02-23A","Cine_ST02-23A00","Cine_ST02-23A00");
			
			extractBG("Cine_ST03-01B","Cine_ST03-01B00","Cine_ST03-01B00");
			extractBG("Cine_ST03-02A","Cine_ST03-02A00","Cine_ST03-02A00");
			extractBG("Cine_ST03-03A","Cine_ST03-03A00","Cine_ST03-03A00");
			extractBG("Cine_ST03-03B","Cine_ST03-03B00","Cine_ST03-03B00");
			extractBG("Cine_ST03-04A","Cine_ST03-04A00","Cine_ST03-04A00");
			extractBG("Cine_ST03-06A","Cine_ST03-06A00","Cine_ST03-06A00");
			extractBG("Cine_ST03-06B","Cine_ST03-06B00","Cine_ST03-06B00");
			extractBG("Cine_ST03-07A","Cine_ST03-07A00","Cine_ST03-07A00");
			extractBG("Cine_ST03-08A","Cine_ST03-08A00","Cine_ST03-08A00");
			extractBG("Cine_ST03-08B","Cine_ST03-08B00","Cine_ST03-08B00");
			extractBG("Cine_ST03-09A","Cine_ST03-09A00","Cine_ST03-09A00");
			extractBG("Cine_ST03-09B","Cine_ST03-09B00","Cine_ST03-09B00");
			extractBG("Cine_ST03-10A","Cine_ST03-10A00","Cine_ST03-10A00");
			extractBG("Cine_ST03-11A","Cine_ST03-11A00","Cine_ST03-11A00");
			extractBG("Cine_ST03-12A","Cine_ST03-12A00","Cine_ST03-12A00");
			extractBG("Cine_ST03-12B","Cine_ST03-12B00","Cine_ST03-12B00");
			extractBG("Cine_ST03-13A","Cine_ST03-13A00","Cine_ST03-13A00");
			extractBG("Cine_ST03-13B","Cine_ST03-13B00","Cine_ST03-13B00");
			extractBG("Cine_ST03-14A","Cine_ST03-14A00","Cine_ST03-14A00");
			extractBG("Cine_ST03-14B","Cine_ST03-14B00","Cine_ST03-14B00");
			extractBG("Cine_ST03-15A","Cine_ST03-15A00","Cine_ST03-15A00");
			extractBG("Cine_ST03-16A","Cine_ST03-16A00","Cine_ST03-16A00");
			extractBG("Cine_ST03-17A","Cine_ST03-17A00","Cine_ST03-17A00");
			extractBG("Cine_ST03-17B","Cine_ST03-17B00","Cine_ST03-17B00");
			extractBG("Cine_ST03-18A","Cine_ST03-18A00","Cine_ST03-18A00");
			extractBG("Cine_ST03-18B","Cine_ST03-18B00","Cine_ST03-18B00");
			
			extractBG("Cine_ST04-01A","Cine_ST04-01A00","Cine_ST04-01A00");
			extractBG("Cine_ST04-02A","Cine_ST04-02A00","Cine_ST04-02A00");
			extractBG("Cine_ST04-02B","Cine_ST04-02B00","Cine_ST04-02B00");
			extractBG("Cine_ST04-03A","Cine_ST04-03A00","Cine_ST04-03A00");
			extractBG("Cine_ST04-05A","Cine_ST04-05A00","Cine_ST04-05A00");
			extractBG("Cine_ST04-05B","Cine_ST04-05B00","Cine_ST04-05B00");
			extractBG("Cine_ST04-06A","Cine_ST04-06A00","Cine_ST04-06A00");
			extractBG("Cine_ST04-07A","Cine_ST04-07A00","Cine_ST04-07A00");
			extractBG("Cine_ST04-08A","Cine_ST04-08A00","Cine_ST04-08A00");
			extractBG("Cine_ST04-08B","Cine_ST04-08B00","Cine_ST04-08B00");
			extractBG("Cine_ST04-09A","Cine_ST04-09A00","Cine_ST04-09A00");
			extractBG("Cine_ST04-10A","Cine_ST04-10A00","Cine_ST04-10A00");
			extractBG("Cine_ST04-10B","Cine_ST04-10B00","Cine_ST04-10B00");
			extractBG("Cine_ST04-11A","Cine_ST04-11A00","Cine_ST04-11A00");
			extractBG("Cine_ST04-12A","Cine_ST04-12A00","Cine_ST04-12A00");
			extractBG("Cine_ST04-12B","Cine_ST04-12B00","Cine_ST04-12B00");
			extractBG("Cine_ST04-13A","Cine_ST04-13A00","Cine_ST04-13A00");
			extractBG("Cine_ST04-14A","Cine_ST04-14A00","Cine_ST04-14A00");
			extractBG("Cine_ST04-14B","Cine_ST04-14B00","Cine_ST04-14B00");
			extractBG("Cine_ST04-15A","Cine_ST04-15A00","Cine_ST04-15A00");
			extractBG("Cine_ST04-15B","Cine_ST04-15B00","Cine_ST04-15B00");
			extractBG("Cine_ST04-16A","Cine_ST04-16A00","Cine_ST04-16A00");
			extractBG("Cine_ST04-17A","Cine_ST04-17A00","Cine_ST04-17A00");
			extractBG("Cine_ST04-18A","Cine_ST04-18A00","Cine_ST04-18A00");
			
			extractBG("Cine_ST05-01B","Cine_ST05-01B00","Cine_ST05-01B00");
			extractBG("Cine_ST05-02A","Cine_ST05-02A00","Cine_ST05-02A00");
			extractBG("Cine_ST05-02B","Cine_ST05-02B00","Cine_ST05-02B00");
			extractBG("Cine_ST05-03A","Cine_ST05-03A00","Cine_ST05-03A00");
			extractBG("Cine_ST05-05A","Cine_ST05-05A00","Cine_ST05-05A00");
			extractBG("Cine_ST05-06A","Cine_ST05-06A00","Cine_ST05-06A00");
			extractBG("Cine_ST05-07A","Cine_ST05-07A00","Cine_ST05-07A00");
			extractBG("Cine_ST05-07B","Cine_ST05-07B00","Cine_ST05-07B00");
			extractBG("Cine_ST05-08A","Cine_ST05-08A00","Cine_ST05-08A00");
			extractBG("Cine_ST05-09A","Cine_ST05-09A00","Cine_ST05-09A00");
			extractBG("Cine_ST05-09B","Cine_ST05-09B00","Cine_ST05-09B00");
			extractBG("Cine_ST05-10A","Cine_ST05-10A00","Cine_ST05-10A00");
			extractBG("Cine_ST05-10B","Cine_ST05-10B00","Cine_ST05-10B00");
			extractBG("Cine_ST05-11A","Cine_ST05-11A00","Cine_ST05-11A00");
			extractBG("Cine_ST05-12A","Cine_ST05-12A00","Cine_ST05-12A00");
			extractBG("Cine_ST05-12B","Cine_ST05-12B00","Cine_ST05-12B00");
			extractBG("Cine_ST05-13A","Cine_ST05-13A00","Cine_ST05-13A00");
			extractBG("Cine_ST05-13B","Cine_ST05-13B00","Cine_ST05-13B00");
			extractBG("Cine_ST05-14A","Cine_ST05-14A00","Cine_ST05-14A00");
			extractBG("Cine_ST05-15A","Cine_ST05-15A00","Cine_ST05-15A00");
			extractBG("Cine_ST05-15B","Cine_ST05-15B00","Cine_ST05-15B00");
			extractBG("Cine_ST05-16A","Cine_ST05-16A00","Cine_ST05-16A00");
			extractBG("Cine_ST05-17A","Cine_ST05-17A00","Cine_ST05-17A00");
			extractBG("Cine_ST05-17B","Cine_ST05-17B00","Cine_ST05-17B00");
			extractBG("Cine_ST05-18A","Cine_ST05-18A00","Cine_ST05-18A00");
			extractBG("Cine_ST05-18B","Cine_ST05-18B00","Cine_ST05-18B00");
			extractBG("Cine_ST05-19A","Cine_ST05-19A00","Cine_ST05-19A00");
			
			extractBG("Credits_Main","Credits_Main00","Credits_Main00");
			extractBG("Credits_Sub","Credits_Sub00","Credits_Sub00");
			extractBG("Dance_Sub","Dance_Sub00","Dance_Sub00",true);
			extractBG("Dance_Sub","Dance_Sub01","Dance_Sub01");
			extractBG("DS_Turn","DS_Turn00","DS_Turn00");
			extractBG("DS_TurnBottom","DS_TurnBottom00","DS_TurnBottom00");
			
			extractBG("Fleur1","Fleur100","Fleur100");
			extractBG("Fleur2","Fleur200","Fleur200");
			extractBG("Fleur3","Fleur300","Fleur300");
			extractBG("Fleur4","Fleur400","Fleur400");
			
			extractBG("GameGUI1_1","GameGUI1_100","GameGUI1_100",true);
			extractBG("GameGUI1_1","GameGUI1_100","GameGUI1_101",true);
			extractBG("GameGUI1_1","GameGUI1_100","GameGUI1_102");
			
			extractBG("GameGUI1_2","GameGUI1_200","GameGUI1_200",true);
			//extractBG("GameGUI1_2","GameGUI1_200","GameGUI1_201");
			//extractBG("GameGUI1_2","GameGUI1_200","GameGUI1_202");
			
			extractBG("GameGUI2_1","GameGUI2_100","GameGUI2_100",true);
			//extractBG("GameGUI2_1","GameGUI2_101","GameGUI2_101");
			extractBG("GameGUI2_2","GameGUI2_200","GameGUI2_200",true);
			extractBG("GameGUI2_2","GameGUI2_200","GameGUI2_201");
			extractBG("GameGUI2_4","GameGUI2_400","GameGUI2_400",true);
			//extractBG("GameGUI2_4","GameGUI2_401","GameGUI2_401");
			
			extractBG("GameGUI3_2","GameGUI3_200","GameGUI3_200",true);
			extractBG("GameGUI3_2","GameGUI3_200","GameGUI3_201",true);
			extractBG("GameGUI3_2b","GameGUI3_2b00","GameGUI3_2b00",true);
			extractBG("GameGUI3_2b","GameGUI3_2b00","GameGUI3_2b01",true);
			extractBG("GameGUI3_4","GameGUI3_400","GameGUI3_400",true);
			extractBG("GameGUI3_4","GameGUI3_400","GameGUI3_401",true);
			
			extractBG("GameGUI4_1","GameGUI4_100","GameGUI4_100",true);
			extractBG("GameGUI4_1","GameGUI4_100","GameGUI4_101",true);
			extractBG("GameGUI4_2","GameGUI4_200","GameGUI4_200",true);
			extractBG("GameGUI4_2","GameGUI4_200","GameGUI4_201",true);
			extractBG("GameGUI4_3","GameGUI4_300","GameGUI4_300",true);
			extractBG("GameGUI4_3","GameGUI4_300","GameGUI4_301",true);
			extractBG("GameGUI4_311","GameGUI4_31100","GameGUI4_31100",true);
			extractBG("GameGUI4_322","GameGUI4_32200","GameGUI4_32200",true);
			extractBG("GameGUI4_333","GameGUI4_33300","GameGUI4_33300",true);
			extractBG("GameGUI4_4","GameGUI4_400","GameGUI4_400",true);
			extractBG("GameGUI4_4","GameGUI4_400","GameGUI4_401",true);
						
			extractBG("GameGUI5_1","GameGUI5_100","GameGUI5_100",true);
			extractBG("GameGUI5_1","GameGUI5_100","GameGUI5_101",true);
			//extractBG("GameGUI5_1","GameGUI5_100","GameGUI5_102",true);
			extractBG("GameGUI5_2","GameGUI5_200","GameGUI5_200",true);
			extractBG("GameGUI5_2","GameGUI5_200","GameGUI5_201",true);
			
			extractBG("Gameover_ST01_L01_00","Gameover_ST01_L01_0000","Gameover_ST01_L01_0000");
			extractBG("Gameover_ST01_L02_00","Gameover_ST01_L02_0000","Gameover_ST01_L02_0000");
			extractBG("Gameover_ST01_L02_01","Gameover_ST01_L02_0100","Gameover_ST01_L02_0100");
			extractBG("Gameover_ST01_L02_02","Gameover_ST01_L02_0200","Gameover_ST01_L02_0200");
			extractBG("Gameover_ST01_L03_00","Gameover_ST01_L03_0000","Gameover_ST01_L03_0000");
			extractBG("Gameover_ST01_L04_00","Gameover_ST01_L04_0000","Gameover_ST01_L04_0000");
			extractBG("Gameover_ST02_L01_00","Gameover_ST02_L01_0000","Gameover_ST02_L01_0000");
			
			extractBG("Gameover_ST02_L02_00","Gameover_ST02_L02_0000","Gameover_ST02_L02_0000");
			extractBG("Gameover_ST02_L02_01","Gameover_ST02_L02_0100","Gameover_ST02_L02_0100");
			extractBG("Gameover_ST02_L02_02","Gameover_ST02_L02_0200","Gameover_ST02_L02_0200");
			extractBG("Gameover_ST02_L03_00","Gameover_ST02_L03_0000","Gameover_ST02_L03_0000");
			extractBG("Gameover_ST02_L04_00","Gameover_ST02_L04_0000","Gameover_ST02_L04_0000");
			
			extractBG("Gameover_ST03_L01_00","Gameover_ST03_L01_0000","Gameover_ST03_L01_0000");
			extractBG("Gameover_ST03_L02_00","Gameover_ST03_L02_0000","Gameover_ST03_L02_0000");
			extractBG("Gameover_ST03_L03_00","Gameover_ST03_L03_0000","Gameover_ST03_L03_0000");
			extractBG("Gameover_ST03_L03_01","Gameover_ST03_L03_0100","Gameover_ST03_L03_0100");
			extractBG("Gameover_ST01_L01_00","Gameover_ST01_L01_0000","Gameover_ST01_L01_0000");
			extractBG("Gameover_ST03_L03_02","Gameover_ST03_L03_0200","Gameover_ST03_L03_0200");
			
			extractBG("Gameover_ST04_L01_00","Gameover_ST04_L01_0000","Gameover_ST04_L01_0000");
			extractBG("Gameover_ST04_L02_00","Gameover_ST04_L02_0000","Gameover_ST04_L02_0000");
			extractBG("Gameover_ST04_L02_01","Gameover_ST04_L02_0100","Gameover_ST04_L02_0100");
			extractBG("Gameover_ST04_L02_02","Gameover_ST04_L02_0200","Gameover_ST04_L02_0200");
			extractBG("Gameover_ST04_L03_00","Gameover_ST04_L03_0000","Gameover_ST04_L03_0000");
			extractBG("Gameover_ST04_L04_00","Gameover_ST04_L04_0000","Gameover_ST04_L04_0000");
			
			extractBG("Gameover_ST05_L01_00","Gameover_ST05_L01_0000","Gameover_ST05_L01_0000");
			extractBG("Gameover_ST05_L02_00","Gameover_ST05_L02_0000","Gameover_ST05_L02_0000");
			extractBG("Gameover_ST05_L03_00","Gameover_ST05_L03_0000","Gameover_ST05_L03_0000");
			extractBG("Gameover_ST05_L04_00","Gameover_ST05_L04_0000","Gameover_ST05_L04_0000");
			extractBG("Gameover_ST05_L04_01","Gameover_ST05_L04_0100","Gameover_ST05_L04_0100");
			extractBG("Gameover_ST05_L04_02","Gameover_ST05_L04_0200","Gameover_ST05_L04_0200");
			
			extractBG("GenericPink","GenericPink00","GenericPink00");
			extractBG("Gladys_Gadgets","Gladys_Gadgets00","Gladys_Gadgets00");
			extractBG("GUI_Wifi","GUI_Wifi00","GUI_Wifi00");
			extractBG("Helper_Jerry","Helper_Jerry00","Helper_Jerry00",true);
			
			extractBG("Intro","Intro00","Intro00",true);
			extractBG("Intro","Intro01","Intro01",true);
			extractBG("Intro","Intro02","Intro02");
			
			extractBG("Intro_Bas","Intro_Bas00","Intro_Bas00");
			
			extractBG("Laboratoire","Laboratoire00","Laboratoire00",true);
			extractBG("Laboratoire","Laboratoire01","Laboratoire01");
			extractBG("Labo_Tutorial","Labo_Tutorial00","Labo_Tutorial00");
			extractBG("Labo_Tutorial","Labo_Tutorial01","Labo_Tutorial01");
			extractBG("Logo_Atari","Logo_Atari00","Logo_Atari00");
			extractBG("Logo_Marathon","Logo_Marathon00","Logo_Marathon00");
			extractBG("Logo_Mistic","Logo_Mistic00","Logo_Mistic00");
			extractBG("Logo_Nintendo","Logo_Nintendo00","Logo_Nintendo00");
			extractBG("Mastermind_Main","Mastermind_Main00","Mastermind_Main00");
			extractBG("Mastermind_MultiSub","Mastermind_MultiSub00","Mastermind_MultiSub00",true);
			extractBG("Mastermind_MultiSub","Mastermind_MultiSub00","Mastermind_MultiSub01");
			extractBG("Mastermind_Sub","Mastermind_Sub00","Mastermind_Sub00");
			
			extractBG("Menu_Bottom","Menu_Bottom00","Menu_Bottom00");
			extractBG("Menu_Bottom","Menu_Bottom01","Menu_Bottom01");
			extractBG("Menu_Network_FoundMain","Menu_Network_FoundMain00","Menu_Network_FoundMain00");
			extractBG("Menu_Network_FoundSub","Menu_Network_FoundSub00","Menu_Network_FoundSub00");
			extractBG("Menu_Network_SearchMain","Menu_Network_SearchMain00","Menu_Network_SearchMain00");
			extractBG("Menu_Network_SearchSub","Menu_Network_SearchSub00","Menu_Network_SearchSub00");
			extractBG("Menu_Network_StartMain","Menu_Network_StartMain00","Menu_Network_StartMain00");
			extractBG("Menu_Network_StartSub","Menu_Network_StartSub00","Menu_Network_StartSub00");
			extractBG("Menu_Principal_01","Menu_Principal_0100","Menu_Principal_0100");
			extractBG("Menu_Principal_02","Menu_Principal_0200","Menu_Principal_0200");
			extractBG("Menu_Select_Char","Menu_Select_Char00","Menu_Select_Char00",true);
			extractBG("Menu_Select_Char","Menu_Select_Char00","Menu_Select_Char01");
			extractBG("Menu_Title_Top","Menu_Title_Top00","Menu_Title_Top00");
			
			extractBG("mike","mike00","mike00");
			extractBG("MoonRace_Sub","MoonRace_Sub00","MoonRace_Sub00");
			extractBG("MultiGameGUI5_1","MultiGameGUI5_100","MultiGameGUI5_100",true);
			extractBG("MultiGameGUI5_1","MultiGameGUI5_100","MultiGameGUI5_101");
			extractBG("Options_BG","Options_BG00","Options_BG00");
			extractBG("Options_BG","Options_BG00","Options_BG01",true);
			extractBG("Pause","Pause00","Pause00");
			//extractBG("Pause","Pause01","Pause01");
			//extractBG("Pause","Pause02","Pause02");
			extractBG("PauseV","PauseV00","PauseV00");
			//extractBG("PauseV","PauseV01","PauseV01");
			//extractBG("PauseV","PauseV02","PauseV02");
			
			extractBG("Quiz_Alex","Quiz_Alex00","Quiz_Alex00");
			extractBG("Quiz_Clover","Quiz_Clover00","Quiz_Clover00");
			extractBG("Quiz_Sam","Quiz_Sam00","Quiz_Sam00");
			extractBG("Quiz_Sheet","Quiz_Sheet00","Quiz_Sheet00");
			
			extractBG("Story1Level3","Story1Level300","Story1Level300");
			extractBG("Taquin_GUI","Taquin_GUI00","Taquin_GUI00");
			extractBG("Track1","Track100","Track100");
			extractBG("Wifi_loseBottom","Wifi_loseBottom00","Wifi_loseBottom00");
			extractBG("Wifi_loseTop","Wifi_loseTop00","Wifi_loseTop00");
			extractBG("Wifi_winBottom","Wifi_winBottom00","Wifi_winBottom00");
			extractBG("Wifi_winTop","Wifi_winTop00","Wifi_winTop00");
		}
		
		private function extractBG(pal:String,gr:String,scr:String,transp:Boolean=false):void {
			var render:DisplayObject=loadBG(pal,gr,scr,transp);
			
			saveItem(scr,render);
		}
		
		private function saveItem(fileName:String,render:DisplayObject):void {
			var rect:Rectangle=render.getBounds(render);
			var m:Matrix=new Matrix();
			m.translate(-rect.x,-rect.y);
			
			rect.x=0;
			rect.y=0;
			
			var bmd:BitmapData=new BitmapData(rect.width,rect.height,true,0x00FF00FF);
			bmd.draw(render,m);
			
			var comp:PNGEncoderOptions=new PNGEncoderOptions();
			
			fileName=fileName.replace("/",flash.filesystem.File.separator);
			
			var file:flash.filesystem.File=new flash.filesystem.File(basePath+flash.filesystem.File.separator+fileName+".png");
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeBytes(bmd.encode(rect,comp));
			fs.close();
		}
		
		private function openFile(fileName:String):ByteArray {
			return Stock.decompress(nds.fileSystem.openFileByName(fileName));
		}
		
		private function loadBG(pal:String,gr:String,scr:String,transp:Boolean=false):DisplayObject {
			var nclr:NCLR=new NCLR();
			nclr.parse(openFile(pal+".NCLR.lz"));
			var palette:Vector.<uint>=RGB555.paletteFromRGB555(nclr.colors);
			var ncgr:NCGR=new NCGR();
			ncgr.parse(openFile(gr+".NCGR.lz"));
			var nscr:NSCR=new NSCR();
			var nscrData:ByteArray=openFile(scr+".NSCR.lz");
			
			//hack the screen file to have correct section lenght
			nscrData.endian=Endian.LITTLE_ENDIAN;
			nscrData.position=20
			nscrData.writeUnsignedInt(nscrData.bytesAvailable+4);
			nscrData.position=0;
			
			var fr:FileReference=new FileReference();
			//fr.save(nscrData,"Cine_ST01-01A00.NSCR");
			
			nscr.parse(nscrData);
			
			return nscr.renderViewport(ncgr,palette,transp,0,0,256/8,192/8);
		}
	}
	
}
