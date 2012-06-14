package  {
	
	import flash.events.*;
	import flash.utils.*;
	
	import Nitro.GS.*;

	public class GS2Extracter extends GSBaseExtractor {
		
		public function GS2Extracter() {
			super("gs2.nds");
		}
		
		protected override function outDirSelected(e:Event):void {
			var time:uint=getTimer();
			//extractBase();
			
			//extractCase1();
			//extractCase2();
			//extractCase3();
			//extractCase4();
			
			//extractSplashes();
			extractMisc();
			
			traceCurrentOffset();
			
			time=getTimer()-time;
			//trace("extraction took:",time,"ms");
		}
		
		private function extractBase():void {
			outputSingleImage("jplogo.png",0,32,24,8);
			outputSingleImage("enlogo.png",17560,32,24,8);
			
			outputSingleImage("demologo.png",33496,32,24,8);
			
			//outputBin("archive1",187640);//text as graphics
			//outputBin("archive2",358984);//more text as graphics
			//outputBin("archive3",494264);//dito
			//outputBin("archive4",523728);//more of above
			
			//saveDecodedChunk("2.bin",1218724);
			
			outputEvidence(0x871C4,0xF3C84);
			
			outputSingleImage("bottomScreen1.png",1218724);
			outputSingleImage("bottomScreen2.png",1227684);
			outputSingleImage("bottomScreen3.png",1238508);
			outputSingleImage("bottomScreen4.png",1254908);
			outputSingleImage("vsBga.png",1262060);
			
			outputSlicedImage("logo2a.png",1266000);
			outputSlicedImage("logo2b.png",1270452);
			outputSlicedImage("logo2c.png",1278708);
			
			outputSlicedImage("locations/court/lobby.png",1283284);
			outputSlicedImage("locations/court/defenseBenchBG.png",1313172);
			outputSlicedImage("locations/court/prosecutionBenchBG.png",1321312);
			outputSlicedImage("locations/court/wittnesStandBG.png",1329080);
			outputSlicedImage("locations/court/judgeBench.png",1338376);
			outputSlicedImage("locations/court/defenseAideBench.png",1370396);
			outputSlicedImage("locations/court/wide.png",1398444);
			outputSlicedImage("bottomScreen5.png",1434436);
			
			outputSlicedImage("vfx/gavelSlam/BG.png",1451628);
			outputSlicedImage("vfx/gavelSlam/1.png",1461132);
			outputSlicedImage("vfx/gavelSlam/FGa.png",1476256);
			outputSlicedImage("vfx/gavelSlam/FGb.png",1487764);
			outputSlicedImage("vfx/gavelSlam/FGc.png",1499272);
			outputSlicedImage("vsBgb.png",1510780);
			
			outputSlicedImage("locations/detentionCenter.png",1515144);
			outputSlicedImage("locations/lawoffice.png",1539516);
			outputSlicedImage("locations/policeOffice.png",1569304);
			outputSlicedImage("chars/franziska/cutinBG.png",1602120,32,4,true);
			outputSlicedImage("bottomScreen6.png",1608168);
			outputSlicedImage("thinkingGray/courtPhoenix.png",1624672);
			outputSlicedImage("thinkingGray/investigationPhoenix.png",1635104);
			outputSingleImage("toBeContinued.png",1642432);
			
			outputSlicedImage("casePosters/case1.png",1646300,32,8);
			outputSlicedImage("casePosters/case2.png",1715764,32,8);
			outputSlicedImage("casePosters/case3.png",1794416,32,8);
			outputSlicedImage("casePosters/case4.png",1862492,32,8);
			outputSlicedImage("casePosters/locked.png",1937540,32,8);
		}
		
		private function extractCase1():void {
			outputSlicedImage("case1/crimeScenePhoto.png",2006204);
			outputSlicedImage("case1/handWritingJP.png",2020700);
			outputSlicedImage("case1/handWritingEN.png",2034032);
			outputSlicedImage("case1/foundPhoneJP.png",2046944);
			outputSlicedImage("case1/foundPhoneEN.png",2064436);
			outputSlicedImage("case1/fallen.png",2081932);
			outputSlicedImage("case1/lurkingAttacker.png",2101524,64);
			outputSlicedImage("case1/dreamBG.png",2151440);
			outputSlicedImage("case1/wellington.png",2161472);
		}
		
		private function extractCase2():void {
			outputSlicedImage("locations/case2/kourainVillage.png",2181356);
			outputSlicedImage("locations/case2/trainingHall.png",2219032);
			outputSlicedImage("locations/case2/summoningChamberClean.png",2259292,64);
			outputSlicedImage("locations/case2/summoningChamberDirty.png",2335044,64);
			outputSlicedImage("locations/case2/windingWay.png",2410960);
			outputSlicedImage("locations/case2/guestRoomWithBox.png",2447776);
			outputSlicedImage("locations/case2/guestRoom.png",2482904);
			outputSlicedImage("locations/case2/hottieJP.png",2515788);
			outputSlicedImage("locations/case2/hottiedEN.png",2542440);
			
			outputSlicedImage("case2/carJP.png",2568564);
			outputSlicedImage("case2/carEN.png",2593728);
			outputSlicedImage("case2/accident.png",2618852,32,8);
			outputSlicedImage("case2/meetingMaya.png",2665544);
			outputSlicedImage("dummys/case2/steelSamurai.png",2689748);
			
			outputSlicedImage("case2/cr/jp/1a.png",2694496);
			outputSlicedImage("case2/cr/en/1a.png",2698860);
			outputSlicedImage("case2/cr/jp/1b.png",2703020);
			outputSlicedImage("case2/cr/en/1b.png",2707328);
			outputSlicedImage("case2/cr/jp/1c.png",2711504);
			outputSlicedImage("case2/cr/en/1c.png",2715976);
			
			outputSlicedImage("case2/map1.png",2720164);
			outputSlicedImage("case2/map2JP.png",2723576);
			outputSlicedImage("case2/map2EN.png",2727924);
			
			outputSlicedImage("case2/headlights.png",2732136);
			outputSlicedImage("case2/miasDeath.png",2737252);
			outputSlicedImage("case2/channelingSession.png",2750040);
			outputSlicedImage("case2/hospitalAccident.png",2765392);
			outputSlicedImage("case2/robe.png",2785848);
			outputSlicedImage("case2/photoOfMayasBack.png",2794308);
			outputSlicedImage("case2/photoOfMayasFront.png",2807864);
			outputSlicedImage("case2/secretPhotoOfMayaChannelingMia.png",2822272);
			outputSlicedImage("case2/urnRepairJP.png",2844688);
			outputSlicedImage("case2/urnRepairEN.png",2860204);
			outputSlicedImage("case2/morgan.png",2875716);
			outputSlicedImage("case2/iniMeetsMaya.png",2906884);
			outputSlicedImage("case2/iniAtTheCrimeScene.png",2922476);
			outputSlicedImage("case2/theHiddenBox.png",2937328);
			outputSlicedImage("case2/grayShootsBack.png",2950692);
			outputSlicedImage("case2/mayaHugsMia.png",2967868);
		}
		
		private function extractCase3():void {
			outputSlicedImage("locations/case3/stage.png",2993064);
			outputSlicedImage("locations/case3/cafeteriaJP.png",3028944);
			outputSlicedImage("locations/case3/cafeteriaEN.png",3066464);
			outputSlicedImage("locations/case3/berrysLodge.png",3103948);
			outputSlicedImage("locations/case3/outsideDayJP.png",3137444);
			outputSlicedImage("locations/case3/outsideDayEN.png",3167428);
			outputSlicedImage("locations/case3/outsideNightJP.png",3197652);
			outputSlicedImage("locations/case3/outsideNightEN.png",3228984);
			outputSlicedImage("locations/case3/courtyard.png",3260368);
			outputSlicedImage("locations/case3/moesRoom.png",3288980);
			outputSlicedImage("locations/case3/acrosRoom.png",3323372);
			//outputSlicedImage("locations/case3/a.png",);
			//outputSlicedImage("locations/case3/a.png",);
			//outputSlicedImage("locations/case3/a.png",);
			
			outputSlicedImage("case3/lionMouthA.png",3352960,32,8);
			outputSlicedImage("case3/lionMouthB.png",3376804);
			outputSlicedImage("case3/circusOverheadJP.png",3398904,64);
			outputSlicedImage("case3/circusOverheadEN.png",3474516,64);
			outputSlicedImage("case3/max.png",3547396);
			
			outputSlicedImage("case3/cr/jp/1.png",3574272);
			outputSlicedImage("case3/cr/en/1.png",3578236);
			outputSlicedImage("case3/maxPosterJP.png",3582048);
			outputSlicedImage("case3/maxPosterEN.png",3606904);
			outputSlicedImage("case3/maxTrophyPhoto.png",3631804);
			outputSlicedImage("case3/berryLeavesMaxJP.png",3660928);
			outputSlicedImage("case3/berryLeavesMaxEN.png",3678460);
			outputSlicedImage("case3/mapJP.png",3695944);
			outputSlicedImage("case3/mapEN.png",3701996);
			outputSlicedImage("case3/crimeScenePhoto.png",3708120);
			outputSlicedImage("case3/berryDead.png",3719044);
			outputSlicedImage("case3/berryLiftsTheBox.png",3731352);
			outputSlicedImage("case3/theKillerBust.png",3741732);
			outputSlicedImage("case3/leonsLastTrick.png",3754220,32,8);
			outputSlicedImage("case3/triloSpotsMaxJP.png",3777928);
			outputSlicedImage("case3/triloSpotsMaxEN.png",3794712);
			outputSlicedImage("case3/acroSeesMax.png",3811380);
			outputSlicedImage("case3/theBust.png",3824200);
			outputSlicedImage("case3/acrosRopeTrick.png",3847620);
			outputSlicedImage("case3/maxesFightJP.png",3867036);
			outputSlicedImage("case3/maxesFightEN.png",3886880);
			outputSlicedImage("case3/acrosWheelchair.png",3906532,32,8);
			outputSlicedImage("case3/milesReturn.png",3916392,64);
		}
		
		private function extractCase4():void {
			outputSlicedImage("locations/case4/ballroom.png",3958236);
			outputSlicedImage("locations/case4/hallwayJP.png",3999796);
			outputSlicedImage("locations/case4/hallwayEN.png",4036196);
			outputSlicedImage("locations/case4/engardesRoom.png",4072020);
			outputSlicedImage("locations/case4/corridasRoom.png",4107796,64);
			outputSlicedImage("dummys/case4/steelSamurai2.png",4171692);
			outputSlicedImage("locations/case4/lobbyJP.png",4176504);
			outputSlicedImage("locations/case4/lobbyEN.png",4214916);
			outputSlicedImage("locations/case4/mattsLivingroom.png",4253340);
			outputSlicedImage("locations/case4/mattsWorkroom.png",4291604);
			outputSlicedImage("locations/case4/winecellar.png",4321396);
			
			outputSlicedImage("case4/skyview.png",4354584);
			outputSlicedImage("case4/jammingNinjaJP.png",4385392);
			outputSlicedImage("case4/jammingNinjaEN.png",4421152);
			outputSlicedImage("locations/case4/airport.png",4456856);
			outputSlicedImage("case4/crimeScenePhoto.png",4488816);
			outputSlicedImage("case4/mapJP.png",4502188);
			outputSlicedImage("case4/mapEN.png",4507300);
			outputSlicedImage("case4/lottasPhoto.png",4512184);
			outputSlicedImage("case4/nickelSamuraiPosterJP.png",4526932);
			outputSlicedImage("case4/nickelSamuraiPosterEN.png",4561236);
			outputSlicedImage("case4/theSuicide.png",4596548);
			outputSlicedImage("case4/adrianDressesUp.png",4610612);
			outputSlicedImage("case4/adrianFindsMattAsleep.png",4627756);
			outputSlicedImage("case4/mattAndBike.png",4643832);
			outputSlicedImage("case4/edgeworthsFlashback.png",4657044,32,8);
			outputSlicedImage("case4/mattsMeetingWithDeKillerJP.png",4690604);
			outputSlicedImage("case4/mattsMeetingWithDeKillerEN.png",4711344);
			outputSlicedImage("case4/fransizkaEnters.png",4731780);
			outputSlicedImage("case4/handingOverTheDollJP.png",4762156);
			outputSlicedImage("case4/handingOverTheDollEN.png",4777712);
			outputSlicedImage("case4/endingHug.png",4792804);
			outputSlicedImage("case4/callingCardMarkedJP.png",4824292);
			outputSlicedImage("case4/callingCardMarkedEN.png",4835104);
			outputSlicedImage("case4/badEnd.png",4845564);
			outputSlicedImage("case4/adrianFindsJuan.png",4863716);
			outputSlicedImage("case4/callingCardJP.png",4881372);
			outputSlicedImage("case4/callingCardEN.png",4886204);
			outputSlicedImage("case4/steelSamuraiPosterJP.png",4890784);
			outputSlicedImage("case4/steelSamuraiPosterEN.png",4923508);
			
			outputSlicedImage("case4/cr/jp/1.png",4957064);
			outputSlicedImage("case4/cr/en/1.png",4961172);
			outputSlicedImage("case4/youngMilesSpeaksUp.png",4965168);
			outputSlicedImage("case4/awards.png",4979096,64);
			outputSlicedImage("case4/theNickelSamuraiEnters.png",5040904);
			outputSlicedImage("case4/theNickelSamuraiWinsJP.png",5050600);
			outputSlicedImage("case4/theNickelSamuraiWinsEN.png",5080920);
		}
		
		private function extractSplashes():void {
			outputSlicedImage("case1/splashJP.png",5112536);
			outputSlicedImage("case1/splashEN.png",5116244);
			
			outputSlicedImage("case2/splashJP.png",5120260);
			outputSlicedImage("case2/splashEN.png",5124016);
			
			outputSlicedImage("case3/splashJP.png",5128236);
			outputSlicedImage("case3/splashEN.png",5131892);
			
			outputSlicedImage("case4/splashJP.png",5135956);
			outputSlicedImage("case4/splashEN.png",5139612);
		}
		
		private function extractMisc():void {
			outputSlicedImage("dummys/seeYouInCourt.png",5143824);
			
			outputSlicedImage("unknown/1.png",5179828);
			outputSlicedImage("unknown/2.png",5216800);
			
			outputSlicedImage("ui/readFailJP.png",5250232);
			outputSlicedImage("ui/readFailEN.png",5258864);
			outputSlicedImage("ui/writeFailJP.png",5265872);
			outputSlicedImage("ui/writeFailEN.png",5274500);
			
			//saveDecodedChunk("3.bin",5282284);//first patch
		}
	}
	
}
