package  {
	
	import flash.events.*;
	import flash.utils.*;

	import Nitro.GS.*;

	public class GS1Extracter extends GSBaseExtractor {
		
		public function GS1Extracter() {
			super("gs1.nds");
		}
		
		protected override function outDirSelected(e:Event):void {
			var time:uint=getTimer();
			extractVideos();
			
			extractBase();
			
			extractCase1();
			extractCase2();
			extractCase3();
			extractCase4();
			extractCase5();
			
			extractPatches();
			
			time=getTimer()-time;
			
			trace("Extraction took: "+time+" ms.");
			
			//dev();
			
			traceCurrentOffset();
		}
		
		private function extractVideos():void {
			outputVideo("video/badger",0,32,20);
			outputVideo("video/15intro",1823768);
			outputVideo("video/securityVideo",2677052);
			outputVideo("video/epiloge",25266104);
		}
		
		private function extractBase():void {
			//outputBin("archive5",27669216);//useless junk, a bunch of way too content free files
			//outputBin("archive6",27727316);//they are mostly filled with zeros
			//outputBin("archive7",27731420);//and are quite useless
			//outputBin("archive8",27741988);//and obviously not images
			
			outputSingleImage("logos/jp.png",27753756,32,24,8);
			outputSingleImage("logos/en.png",27771340,32,24,8);
			outputSlicedImage("logos/capcom 1.png",30804028);
			outputSlicedImage("logos/capcom 2.png",31233320);
			outputSlicedImage("logos/capcom 3.png",32327744);
			outputSingleImage("logos/demo.png",32332320,32,24,8);
						
			//saveDecodedChunk("file9.bin",27753756);
			
			//27787188: uncompressed font
			//27789236: message box tiles
			//27793364: name tags
			//27839572: Misc uncompressed tiles
			
			//27925364
			//27988916
			//outputBin("jpprofiledesc",27988948);//japanese profile descriptions, no palette
			//outputBin("enprofiledesc",28192420);//english profile descriptions, no palette
			
			//outputBin("archive12",28356876);//japanese profile titles, no palette
			//outputBin("archive13",28395640);//english profile titles, no palette
			
			outputEvidence(28433332,0x1BBC2B4);
			
			//outputSingleImage("stuff.png",0x1BBC2B4,
			
			outputSingleImage("bottom/1.png",29401108,32,24);
			outputSingleImage("bottom/2.png",29410068);
			outputSingleImage("bottom/3.png",29420892);
			outputSingleImage("bottom/4.png",29444208);
			outputSlicedImage("bottom/5.png",31216816);
			
			outputSingleImage("ui/3d exam frame.png",29437292);
			outputSingleImage("ui/3d exam frame 2.png",29441224);
			outputSingleImage("ui/3d exam frame 3.png",29486712);
			outputSlicedImage("ui/3d exam frame 4.png",32976484);
			outputSlicedImage("ui/3d exam frame 5.png",33404496);
			outputSingleImage("ui/masked exam bg 1.png",29490440);
			outputSlicedImage("ui/masked exam bg 2.png",34203552);
			outputSlicedImage("ui/print comparision frame.png",33087444);
			outputSlicedImage("ui/frame.png",34001748);
			
			outputSingleImage("whoosh.png",29507940);
			outputSlicedImage("whoosh untinted.png",31212452);
			
			outputSlicedImage("locations/office.png",29568332);
			
			outputSlicedImage("locations/court/defenseLobby.png",29598120);
			outputSlicedImage("locations/court/defenseBench.png",29628008);
			outputSlicedImage("locations/court/prosecutionBench.png",29636148);
			outputSlicedImage("locations/court/witnessStand.png",29643916);
			outputSlicedImage("locations/court/zoomedOut.png",29653212);
			outputSlicedImage("locations/court/aideBench.png",29689204);
			outputSlicedImage("locations/court/judgeBench.png",29717252);
			
			outputSlicedImage("locations/detention centre.png",30360540);
			
			outputSlicedImage("locations/police department.png",31609212);
			outputSlicedImage("locations/train station.png",31704252);
			
			outputSlicedImage("gavelSlam/bg.png",30334240);
			outputSlicedImage("gavelSlam/bang.png",30343744);
			
			
			outputSlicedImage("demo end.png",32348972);
			
			outputSlicedImage("thinkingGray/phoenix.png",32387708);
			outputSingleImage("to be continued.png",32398140);
			
			outputSlicedImage("locations/kurain village.png",33795716);
			
			outputSlicedImage("case posters/locked.png",34597228,32,8);
			
			outputSlicedImage("demo end top.png",34763920);
			outputSlicedImage("demo end bottom.png",34798240);
			
			outputSlicedImage("caseposters/locked 2.png",34858768,8);
		}
		
		private function extractCase1():void {
			outputSlicedImage("case 1/holding the thinker.png",30476444,32,8);
			outputSlicedImage("case 1/cindy on the floor.png",30497948);
			outputSlicedImage("case 1/standing over the body.png",30520612,32,8);
			outputSlicedImage("case 1/sawhit shocked 1.png",30576068);
			outputSlicedImage("case 1/sawhit shocked 2.png",30594724);
			outputSlicedImage("case 1/sawhit shocked 3.png",30614684);
			outputSlicedImage("case 1/cindy spots sahwit.png",30700264);
			outputSlicedImage("case 1/sahwit spots larry.png",30716524);
			outputSlicedImage("case 1/sahwit peeks in.png",30728572);
			
			outputSlicedImage("case 1/titlecard jp.png",33506140);
			outputSlicedImage("case 1/titlecard en.png",33509988);
			outputSlicedImage("case posters/1.png",34297836,32,8);
		}
		
		private function extractCase2():void {
			outputSlicedImage("locations/case 2/office.png",29511880,64);
			outputSlicedImage("locations/case 2/hallway.png",29749272);
			outputSlicedImage("locations/case 2/bluecorp jp.png",30384980);
			outputSlicedImage("locations/case 2/bluecorp en.png",30417224);
			outputSlicedImage("locations/case 2/hotel room.png",30449664);
			outputSlicedImage("locations/case 2/grossbarg lawoffice painting.png",30636936);
			outputSlicedImage("locations/case 2/grossberg lawoffice no painting.png",30669808);
			
			outputSlicedImage("case 2/maya with mia.png",29777008);
			outputSlicedImage("case 2/mia dodges right.png",29985096);
			outputSlicedImage("case 2/mia dodges left.png",29996672);
			outputSlicedImage("case 2/floormap.png",30008232);
			outputSlicedImage("case 2/aprill orders roomservice.png",30012780);
			outputSlicedImage("case 2/mias dead body.png",30030004);
			outputSlicedImage("case 2/three part handshake.png",30057496);
			outputSlicedImage("case 2/aprill calls the police.png",30115044);
			outputSlicedImage("case 2/redd swings the thinker.png",30146476,32,8);
			outputSlicedImage("case 2/mia blocks.png",30204812);
			outputSlicedImage("case 2/holding the thinker.png",30246644);
			outputSlicedImage("case 2/floormap with view.png",30355252);
			
			outputSlicedImage("case 2/titlecard jp.png",33514044);
			outputSlicedImage("case 2/titlecard en.png",33517756);
			outputSlicedImage("case posters/2.png",34361508,32,8);
		}
		
		private function unknownAssets():void {
			outputSlicedImage("unknown/cr/jp/1 a.png",30796200);
			outputSlicedImage("unknown/cr/jp/1 b.png",30800164);
			outputSlicedImage("unknown/cr/jp/1 c.png",30812284);
			outputSlicedImage("unknown/cr/jp/2 a.png",31691580);
			outputSlicedImage("unknown/cr/jp/2 b.png",31695712);
			outputSlicedImage("unknown/cr/jp/2 c.png",31699948);
		}
		
		private function extractCase3():void {
			outputSlicedImage("locations/case 3/gate jp.png",29808812);
			outputSlicedImage("locations/case 3/gate en.png",29842904);
			outputSlicedImage("locations/case 3/staff Area jp.png",29877288,64);
			outputSlicedImage("locations/case 3/staff Area en.png",29931176,64);
			outputSlicedImage("locations/case 3/trialer interior.png",30087808);
			outputSlicedImage("locations/case 3/dressing room.png",30255828);
			outputSlicedImage("locations/case 3/parking gate.png",30285236);
			outputSlicedImage("locations/case 3/studio 1.png",30309948);
			outputSlicedImage("locations/case 3/studio 2.png",30742392,64);
			
			outputSlicedImage("case 3/cr/security photo.png",30816468);
			outputSlicedImage("case 3/finding the body.png",30830112);
			outputSlicedImage("case 3/dressing as the samurai.png",30850272);
			outputSlicedImage("case 3/the second impalement.png",30868216);
			outputSlicedImage("case 3/dinner.png",30885912);
			outputSlicedImage("case 3/meeting at the trialer.png",30905492);
			outputSlicedImage("case 3/cody peeks in.png",30925108);
			outputSlicedImage("case 3/codys photo.png",30948728);
			outputSlicedImage("case 3/the first impalement photo.png",30956176);
			outputSlicedImage("case 3/unfriendly fellas.png",30969580);
			outputSlicedImage("case 3/pink princess jp.png",30998332);
			outputSlicedImage("case 3/pink princess en.png",31037636);
			outputSlicedImage("case 3/blocked way.png",31077124);
			outputSlicedImage("case 3/map jp.png",31120912);
			outputSlicedImage("case 3/map en.png",31125180);
			outputSlicedImage("case 3/training incident.png",31129500);
			outputSlicedImage("case 3/steel samurai logo jp.png",31146172);
			outputSlicedImage("case 3/steel samurai logo en.png",31178896);
			
			outputSlicedImage("case 3/opening/base.png",31237772,32,8);
			outputSlicedImage("case 3/opening/bush.png",31510772);
			outputSlicedImage("case 3/opening/small trees.png",31514532);
			outputSlicedImage("case 3/opening/samurai body.png",31518108);
			outputSlicedImage("case 3/opening/sword vs sword.png",31675932);
			
			outputSlicedImage("case 3/titlecard jp.png",33521788);
			outputSlicedImage("case 3/titlecard en.png",33525592);
			outputSlicedImage("case posters/3.png",34436884,32,8);
			
			outputSlicedImage("case 3/the first impalement fullscreen.png",33646656);
		}
		
		private function extractCase4():void {
			outputSlicedImage("locations/case 4/gourd lake gate jp.png",31247240);
			outputSlicedImage("locations/case 4/gourd lake gate en.png",31289732);
			outputSlicedImage("locations/case 4/hotdog stand 1 jp.png",31332104);
			outputSlicedImage("locations/case 4/hotdog stand 1 en.png",31364616);
			outputSlicedImage("locations/case 4/hotdog stand 2 jp.png",31397360);
			outputSlicedImage("locations/case 4/hotdog stand 2 en.png",31424316);
			outputSlicedImage("locations/case 4/forest.png",31451524,64);
			outputSlicedImage("locations/case 4/boat house jp.png",31527308);
			outputSlicedImage("locations/case 4/boat house en.png",31555700);
			outputSlicedImage("locations/case 4/boat house interiour.png",31584396);
			outputSlicedImage("locations/case 4/evidence room.png",31642028);
			
			outputSlicedImage("case 4/map.png",31742564);
			outputSlicedImage("case 4/closeup photo.png",31746668);
			outputSlicedImage("case 4/elevator photo.png",31758756);
			outputSlicedImage("case 4/gourdy paper jp.png",31772584);
			outputSlicedImage("case 4/gourdy paper en.png",31811792);
			outputSlicedImage("case 4/baloon flight.png",31844012);
			outputSlicedImage("case 4/baloon crash.png",31865556);
			outputSlicedImage("case 4/baloon hunt.png",31883572);
			outputSlicedImage("case 4/far out photo.png",31938280);
			
			outputSlicedImage("case 4/class trial/zoomed out.png",31900312);
			outputSlicedImage("case 4/class trial/phoenix.png",31952720);
			outputSlicedImage("case 4/class trial/miles.png",31976812);
			outputSlicedImage("case 4/class trial/larry.png",32008684);
			
			outputSlicedImage("case 4/yoghi shoots.png",32037708);
			outputSlicedImage("case 4/water shot.png",32053672);
			outputSlicedImage("case 4/stuck in the elevator.png",32071272);
			outputSlicedImage("case 4/miles throws the gun.png",32089800);
			outputSlicedImage("case 4/shoulder wound.png",32106916);
			outputSlicedImage("case 4/karma in the doorway.png",32128028);
			outputSlicedImage("case 4/parting with maya.png",32139092);
			outputSlicedImage("case 4/celebration jp.png",32168496);
			outputSlicedImage("case 4/celebration en.png",32205852);
			
			outputSlicedImage("case 4/opening/foggy lake 1.png",32243716);
			outputSlicedImage("case 4/opening/foggy lake 2.png",32255988);
			outputSlicedImage("case 4/opening/miles holds the gun.png",32266712,32,8);
			
			outputSlicedImage("case 4/titlecard jp.png",33529640);
			outputSlicedImage("case 4/titlecard en.png",33533496);
			outputSlicedImage("case posters/4.png",34519684,32,8);
		}
		
		private function extractCase5():void {
			//non continious stuff found along the base stuff
			
			outputSingleImage("case 5/keypad jp.png",29493564,32,24,8);
			outputSlicedImage("case 5/keypad jp 2.png",33668592);
			
			outputSlicedImage("locations/case 5/police station 1 jp.png",32402008);
			outputSlicedImage("locations/case 5/police station 1 en.png",32437496);
			outputSlicedImage("locations/case 5/edgeworths office.png",32473524);
			outputSlicedImage("locations/case 5/parking lot jp.png",32512148,64);
			outputSlicedImage("locations/case 5/parking lot en.png",32581488,64);
			outputSlicedImage("locations/case 5/locker room jp.png",32651436,64);
			outputSlicedImage("locations/case 5/locker room en.png",32711384,64);
			outputSlicedImage("locations/case 5/security station.png",32771424);
			outputSlicedImage("locations/case 5/police station 2 jp.png",34959164);
			outputSlicedImage("locations/case 5/police station 2 en.png",34993352);
			
			outputSlicedImage("case 5/parking lot map jp.png",32813776,48);
			outputSlicedImage("case 5/parking lot map en.png",32819828,48);
			
			outputSlicedImage("case 5/lana stabs goodman.png",32825888);
			outputSlicedImage("case 5/starrs photo.png",32842788);
			outputSlicedImage("case 5/angel arrests lana.png",32857264);
			outputSlicedImage("case 5/trunk photo.png",32875840);
			outputSlicedImage("case 5/goodmans memo jp.png",32889880);
			outputSlicedImage("case 5/goodmans memo en.png",32902252);
			
			outputSlicedImage("case 5/mike confronts goodman.png",32922268);
			
			outputSingleImage("case 5/locker handprint 1.png",29451360);
			outputSingleImage("case 5/locker handprint 2.png",29460656,32,24,8);
			outputSlicedImage("case 5/locker handprint 3.png",32938508);
			outputSlicedImage("case 5/locker handprint 4.png",32948828);
			outputSlicedImage("case 5/locker handprint 5.png",33465544);
			outputSlicedImage("case 5/locket handprint 6.png",33483832);
			outputSlicedImage("case 5/locker handprint 7.png",33496372);
			
			outputSingleImage("case 5/jacket handprint.png",29476624);
			outputSlicedImage("case 5/jacket handprint 2.png",32965380);
			
			outputSlicedImage("case 5/luminol/trunk 1.png",32983384);
			outputSlicedImage("case 5/luminol/trunk 2.png",33000644);
			outputSlicedImage("case 5/luminol/trunk 3.png",33017560);
			outputSlicedImage("case 5/luminol/phone 1.png",33046904);
			outputSlicedImage("case 5/luminol/phone 2.png",33060188);
			outputSlicedImage("case 5/luminol/phone 3.png",33071648);
			
			outputSlicedImage("case 5/the armour.png",33091136);
			outputSlicedImage("case 5/lana and gant.png",33105688);
			outputSlicedImage("case 5/the team.png",33137076);
			outputSlicedImage("case 5/award photo.png",33157384);
			outputSlicedImage("case 5/drake vs neil.png",33182364);
			outputSlicedImage("case 5/lana holds ema.png",33200460);
			outputSlicedImage("case 5/body pile.png",33215824);
			outputSlicedImage("case 5/emas note full.png",33233892);
			outputSlicedImage("case 5/emas note a.png",33247160);
			outputSlicedImage("case 5/emas note b.png",33256844);
			outputSlicedImage("case 5/the contradictiory merchant.png",33265460);
			
			outputSlicedImage("case 5/access log/jp/a.png",32914608);
			outputSlicedImage("case 5/access log/en/a.png",32918428);
			outputSlicedImage("case 5/access log/jp/b.png",33285100);
			outputSlicedImage("case 5/access log/en/b.png",33289016);
			outputSlicedImage("case 5/access log/jp/c.png",33749072);
			outputSlicedImage("case 5/access log/en/c.png",33753068);
			outputSlicedImage("case 5/access log/jp/d.png",33757080);
			outputSlicedImage("case 5/access log/en/d.png",33761196);
			
			outputSlicedImage("case 5/urn a.png",33292924);
			outputSlicedImage("case 5/urn b.png",33300140);
			outputSlicedImage("case 5/urn c.png",33307352);
			outputSlicedImage("case 5/urn d.png",33314164);
			
			outputSlicedImage("case 5/urn message/jp.png",33371800);
			outputSlicedImage("case 5/urn message/en.png",33389076);
			outputSlicedImage("case 5/urn message/solved jp.png",33687548);
			outputSlicedImage("case 5/urn message/solved en.png",33705040);
			outputSlicedImage("case 5/urn message/missing piece jp.png",33720292);
			outputSlicedImage("case 5/urn message/missing piece en.png",33736028);
			outputSlicedImage("case 5/urn message/solved missing piece jp.png",34831644);
			outputSlicedImage("case 5/urn message/solved missing piece en.png",34847220);
			
			outputSlicedImage("locations/case 5/gant office center.png",33321012);
			
			outputSlicedImage("case 5/neil impaled on armour.png",33356336);
			outputSlicedImage("case 5/locker closeup.png",33409104);
			outputSlicedImage("case 5/locker closeup b.png",33437372);
			
			outputSlicedImage("case 5/titlecard jp.png",33537684);
			outputSlicedImage("case 5/titlecard en.png",33541352);
			
			outputSlicedImage("case 5/opening/urn crash 1.png",33545420);
			outputSlicedImage("case 5/opening/urn crash 2.png",33554040);
			outputSlicedImage("case 5/opening/urn crash 3.png",33564820);
			outputSlicedImage("case 5/opening/window badger.png",33576608);
			outputSlicedImage("case 5/opening/parkinglot wall.png",33585520,32,8);
			
			outputSlicedImage("case 5/locker room map.png",33665420);
			
			outputSlicedImage("case 5/cr/jp/1 a.png",33765324);
			outputSlicedImage("case 5/cr/en/1 a.png",33769020);
			outputSlicedImage("case 5/cr/jp/1 b.png",33772716);
			outputSlicedImage("case 5/cr/en/1 b.png",33776572);
			outputSlicedImage("case 5/cr/jp/1 c.png",33780312);
			outputSlicedImage("case 5/cr/en/1 c.png",33784008);
			outputSlicedImage("case 5/cr/jp/1 d.png",33787568);
			outputSlicedImage("case 5/cr/en/1 d.png",33791736);
			
			outputSlicedImage("case 5/luminol/security station 1.png",33833392);
			outputSlicedImage("case 5/luminol/security station 2.png",33853272);
			outputSlicedImage("case 5/luminol/locker room floor 1.png",33871644);
			outputSlicedImage("case 5/luminol/locker room floor 2.png",33886496);
			outputSlicedImage("case 5/luminol/edgeworth office 1.png",33899340);
			outputSlicedImage("case 5/luminol/edgeworth office 2.png",33915860);
			outputSlicedImage("case 5/luminol/edgeworth office 3.png",33957692);
			outputSlicedImage("case 5/luminol/gant office 1.png",33928244);
			outputSlicedImage("case 5/luminol/gant office 2.png",33943484);
			outputSlicedImage("case 5/luminol/gant office 3.png",33978232);
			
			outputSlicedImage("case 5/locker room.png",34005012,64);
			
			outputSlicedImage("ui/urn reassembly.png",34034040);
			outputSlicedImage("ui/urn reassembly 2.png",34043404);
			
			outputSlicedImage("case 5/badger silhouette.png",34053120);
			
			outputSlicedImage("case 5/luminol/locker handprint 1.png",34057128);
			outputSlicedImage("case 5/luminol/locker handprint 2.png",34071044);
			outputSlicedImage("case 5/luminol/locker handprint 3.png",34079120);
			
			outputSlicedImage("case 5/lana hugs ema.png",34097892);
			outputSlicedImage("case 5/lana and ema saluts jp.png",34131784);
			outputSlicedImage("case 5/lana and ema saluts en.png",34163736);
			
			outputSlicedImage("case 5/police station zoomin.png",34196368);
			
			outputSlicedImage("case 5/gants desk.png",34206908);
			outputSlicedImage("case 5/gants safe.png",34230840);
			outputSlicedImage("case 5/gants safe 2.png",34252136);
			
			outputSlicedImage("case 5/correctly positioned urn jp.png",34279320);
			outputSlicedImage("case 5/correctly positioned urn en.png",34288524);
			
			outputSlicedImage("case 5/safe door.png",34665892);
			
			outputSlicedImage("case 5/cr/jp/2 a.png",34674616);
			outputSlicedImage("case 5/cr/en/2 a.png",34678912);
			outputSlicedImage("case 5/cr/jp/2 b.png",34683288);
			outputSlicedImage("case 5/cr/en/2 b.png",34687536);
			
			outputSlicedImage("case 5/lost item report jp.png",34691980);
			outputSlicedImage("case 5/lost item report en.png",34707884);
			
			outputSlicedImage("case 5/trunk fullscreen.png",34722856);
			
			outputSlicedImage("case 5/safe display.png",34741460);
			
			outputSlicedImage("case 5/cr/jp/3 a.png",34755616);
			outputSlicedImage("case 5/cr/en/3 a.png",34759912);
			
			outputSlicedImage("case 5/opening/city.png",34927432);
			outputSlicedImage("case 5/opening/city 2.png",34954140);
			
			outputSlicedImage("case 5/badger closeup.png",35028084);
			outputSlicedImage("case 5/king of procecutors award.png",35040316);
			
			outputSlicedImage("black screen.png",35055528);
			outputSlicedImage("case 5/alt titlecard en.png",35058572);
			outputSlicedImage("case 5/emas drawing c.png",35062532);
			
			outputSlicedImage("case 5/neil impaled on armour 1.png",35074832);
			outputSlicedImage("case 5/neil impaled on armour 2.png",35091732);
			outputSlicedImage("case 5/neil impaled on armour 3.png",35108240);
			
		}
		
		private function extractPatches():void {
			//outputPatch("",0,32807136,4,6);
			//32808320
			//32808512
			//32809336
			//32809708
			outputPatch("patches/evidence room.png",31642028,32810176,4,6);
			//32811084
			//32811176
			//32811324
			//32811476
			//32811636
			//32811832
			//32812056
			//32812056
			//32812168
			//32812260
			//32812424
			//32812564
			//32812704
			//32812848
			//32812896
			//32813036
			//32813152
			//32813316
			//32813484
			
			//32938412
			
			//32980492
			//32980604
			//32980724
			
			//33684264
			//33684384
			//33684740
			//33685092
			//33685152
			//33685660
			//33685820
			//33685972
			//33686096
			//33686200
			//33686312
			//33686420
			//33686544
			//33686648
			//33686780
			//33686888
			//33687220
		}
		
		private function dev():void {			
			outputSlicedImage("unknown/1.png",35123776);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
			//outputSlicedImage("y.png",);
		}
		
		private function skipPatches(offset:uint,startIndex:uint):void {
			archiveData.position=offset;
			
			for(var i:uint=startIndex;;++i) {
				try {
					trace(alignedOffset);
					saveDecodedChunk("patches/"+i+".bin",alignedOffset);
				} catch(err:Error) {
					break;
				}
			}
		}
	}
	
}
