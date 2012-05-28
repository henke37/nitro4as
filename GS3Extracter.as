package  {
	
	import flash.events.*;
	import flash.utils.*;
	
	public class GS3Extracter extends GSBaseExtractor {
		
		public function GS3Extracter() {
			super("gs3.nds");
		}
		
		protected override function outDirSelected(e:Event):void {
			var time:uint=getTimer();
			extractBase();
			extractCase1();
			extractCase2();
			extractCase3();
			extractCase4();
			extractCase5();
			
			extractSplashes();
			extractPatches();
			
			traceCurrentOffset();
			
			time=getTimer()-time;
			
			trace("Extraction took "+time+" ms.");
		}
			
		private function extractBase():void {
			outputSingleImage("jplogo.png",0,32,24,8);
			outputSingleImage("enlogo.png",13956,32,24,8);
			outputSingleImage("bottomScreen1A.png",399008);
			outputSingleImage("bottomScreen1B.png",407968);
			outputSingleImage("bottomScreen2.png",418792);
			outputSingleImage("bottomScreen3.png",435192);
			outputSingleImage("vsbgA.png",442344);
			outputSingleImage("bottomScreen1C.png",446284);
			outputSingleImage("bottomScreen1D.png",456488);
			
			//saveDecodedChunk("10.bin",456488);
			//outputBin("archive1",467012,false);
			
			//outputArchive1("logoarchive",467012);
			outputSlicedImage("logo2A.png",467012);
			outputSlicedImage("logo2B.png",476348);
			outputSlicedImage("logo2C.png",486404);
			
			outputSlicedImage("locations/court/defence_lobby.png",491188);
			outputSlicedImage("locations/court/defence_benchBG.png",521076);
			outputSlicedImage("locations/court/prosecution_benchBG.png",529216);
			outputSlicedImage("locations/court/witness_benchBG.png",536984);			
			outputSlicedImage("locations/court/judge_bench.png",546280);
			outputSlicedImage("locations/court/defenceAid.png",578300);
			outputSlicedImage("locations/court/courtZoomOut.png",606348);
			outputSlicedImage("locations/court/courtZoomOut_blue.png",642340);
			outputSlicedImage("locations/court/gavelbang_BG.png",661084);
			outputSlicedImage("vsbgB.png",670588);
			outputSlicedImage("locations/detentionCenter.png",674952);
			outputSlicedImage("locations/lawOffice.png",699324);
			outputSlicedImage("locations/policeOfficeA.png",729112);
			outputSlicedImage("locations/policeOfficeB.png",759196);
			outputSlicedImage("bottomScreen4.png",789280);
			outputSlicedImage("thinkingGray/phoenixCourt.png",805784);
			outputSlicedImage("thinkingGray/miaGrayCourt.png",816216);
			outputSlicedImage("thinkingGray/edgeworthCourt.png",826468);
			outputSlicedImage("thinkingGray/phoenixInvestigation.png",836960);
			outputSlicedImage("thinkingGray/edgeworthInvestigation.png",844288);
			outputSlicedImage("unknown/1.png",851608);
			outputSlicedImage("unknown/2.png",881716);
			outputSlicedImage("unknown/3.png",915148);
			
			//outputSingleImage("unknown/4.png",918596,32,24,4,false);
			
			outputSlicedImage("ui/loadFailure.png",923780);
			outputSlicedImage("unknown/5.png",931444);
			outputSlicedImage("ui/writeFailure.png",940072);
			
			outputSlicedImage("casePosters/case1.png",947624,32,8);
			outputSlicedImage("casePosters/case2.png",1029092,32,8);
			outputSlicedImage("casePosters/case3.png",1106216,32,8);
			outputSlicedImage("casePosters/case4.png",1184928,32,8);
			outputSlicedImage("casePosters/case5.png",1264176,32,8);
			outputSlicedImage("casePosters/locked.png",1335568,32,8);
		}
		
		private function extractCase1():void {
			outputSlicedImage("case1/swallowFallen.png",1404232,32,4,true);
			outputSlicedImage("case1/phoenixShocked.png",1427980,32,4,true);
			outputSlicedImage("case1/roadBg.png",1447792);
			//saveDecodedChunk("11.bin",1464780);
			outputSingleImage("case1/phoenixBottom.png",1464780,12,10,4,true);
			//saveDecodedChunk("12.bin",1466712);
			outputSingleImage("case1/push/1.png",1466712,8,32,8,true);
			outputSlicedImage("case1/crimeScenePhoto.png",1470424);
			outputSlicedImage("case1/handPhotoJP.png",1483660);
			outputSlicedImage("case1/archiveMeeting.png",1494220);
			outputSlicedImage("case1/findingTheBody.png",1512420);
			
			outputSlicedImage("case1/cr/jp/1.png",1530216);
			outputSlicedImage("case1/cr/jp/2A.png",1534500);
			outputSlicedImage("case1/cr/jp/2B.png",1538480);
			outputSlicedImage("case1/handPhotoEN.png",1543060);
			outputSlicedImage("case1/cr/en/1.png",1553624);
			outputSlicedImage("case1/cr/en/2A.png",1557948);
			outputSlicedImage("case1/cr/en/2B.png",1561996);
		}
		
		private function extractCase2():void {
			
			outputSlicedImage("locations/case2/lordytailorJP.png",1566388);
			outputSlicedImage("locations/case2/basementJP.png",1603424,64);
			outputSlicedImage("locations/case2/atemyOffice.png",1667988);
			outputSlicedImage("locations/case2/demaskNest.png",1705276);
			outputSlicedImage("locations/case2/kbsecurityOffice.png",1740132);
			outputSlicedImage("locations/case2/kbsecurityGuardroom.png",1773472);
			
			outputSlicedImage("case2/cr/jp/1.png",1807628);
			outputSlicedImage("case2/cr/jp/2.png",1811732);
			outputSlicedImage("case2/safeDoor.png",1815860);
			outputSlicedImage("case2/safeOpenJP.png",1824464);
			outputSlicedImage("case2/cardJP.png",1829316);
			outputSlicedImage("case2/spotlights.png",1857604);
			outputSlicedImage("case2/moon.png",1870288);
			outputSlicedImage("case2/gumshoeShadow.png",1879796);
			
			//saveDecodedChunk("13.bin",1883212);
			outputSingleImage("case2/allyA.png",1883212,12,24,4);
			//saveDecodedChunk("14.bin",1885060);
			outputSingleImage("case2/allyB.png",1885060,10,24,4);
			//saveDecodedChunk("15.bin",1886592);
			outputSingleImage("case2/allyC.png",1886592,10,24,4);
			
			outputSlicedImage("case2/cr/jp/3.png",1888080);
			
			outputSlicedImage("case2/adJP.png",1891908);
			outputSlicedImage("case2/miaDeath.png",1907780);
			outputSlicedImage("case2/kurainGrayscale.png",1922844);
			outputSlicedImage("case2/urnRepairJP.png",1942140);
			outputSlicedImage("case2/maskVsAtemy.png",1957656);
			outputSlicedImage("case2/securityCameraPhotoJP.png",1988688);
			outputSlicedImage("case2/maskPoster.png",2006452);
			outputSlicedImage("case2/channeling.png",2039564);
			outputSlicedImage("case2/ronMeetsDesirée.png",2054916);
			outputSlicedImage("case2/paperJP.png",2072116);
			outputSlicedImage("case2/atemyInHidingJP.png",2109372);
			outputSlicedImage("case2/bullardDead.png",2125344);
			outputSlicedImage("case2/boxTripJP.png",2140456);
			outputSlicedImage("case2/urnDropJP.png",2158412);
			outputSlicedImage("case2/maskAtOffice.png",2174536);
			outputSlicedImage("case2/urnRepairedJP.png",2195096);
			outputSlicedImage("locations/case2/lordytailorEN.png",2224168);
			outputSlicedImage("locations/case2/basementEN.png",2261000,64);
			
			outputSlicedImage("case2/cr/en/1.png",2324860);
			outputSlicedImage("case2/cr/en/2.png",2328920);
			
			outputSlicedImage("case2/cardEN.png",2333056);
			outputSlicedImage("case2/cr/en/3.png",2362080);
			outputSlicedImage("case2/adEN.png",2365976);
			outputSlicedImage("case2/urnRepairEN.png",2382232);
			outputSlicedImage("case2/securityCameraPhotoEN.png",2397744);
			outputSlicedImage("case2/paperEN.png",2415508);
			outputSlicedImage("case2/atemyInHidingEN.png",2454492);
			outputSlicedImage("case2/boxTripEN.png",2470464);
			outputSlicedImage("case2/urnRepairedEN.png",2488552);
			outputSlicedImage("case2/safeOpenEN.png",2516920);
			outputSlicedImage("case2/urnDropEN.png",2521780);
		}
		
		private function extractCase3():void {
			outputSlicedImage("locations/case3/trésbienJP.png",2537900,64);
			outputSlicedImage("locations/case3/trésbienKitchen.png",2606080);
			outputSlicedImage("locations/case3/vitaminSquareJP.png",2642948);
			outputSlicedImage("locations/case3/blueScreensInc.png",2673716);
			outputSlicedImage("locations/case3/tenderLenderJP.png",2707776);
			
			outputSlicedImage("case3/dinning.png",2746260,64);
			
			//saveDecodedChunk("16.bin",2780824);
			outputSingleImage("case3/glenBig.png",2780824,21,22,4,true,true);
			//saveDecodedChunk("17.bin",2787180); 
			outputSingleImage("case3/dinning2.png",2787180,32,10,8);
			
			outputSlicedImage("case3/hand.png",2800812);
			outputSlicedImage("case3/coffeeCup.png",2807724);
			outputSlicedImage("case3/mapJP.png",2814856);
			outputSlicedImage("case3/listeningAlone.png",2818868);
			outputSlicedImage("case3/maggeyAsleep.png",2833392);
			outputSlicedImage("case3/paperJP.png",2846016);
			outputSlicedImage("case3/glenFallenJP.png",2864408);
			outputSlicedImage("case3/sidePhoto.png",2877124);
			outputSlicedImage("case3/violaPosions.png",2889692);
			outputSlicedImage("case3/trafficAccident.png",2903944);
			outputSlicedImage("case3/glenWinsJP.png",2917212);
			outputSlicedImage("case3/glenScreamsJP.png",2932892);
			outputSlicedImage("case3/gumshoeEnters.png",2950568);
			outputSlicedImage("case3/maggeyEatsJP.png",2981244);
			outputSlicedImage("case3/emptyLunchboxJP.png",3012424);
			
			outputSlicedImage("locations/case3/trésbienEN.png",3031024,64);
			outputSlicedImage("locations/case3/vitaminSquareEN.png",3099204);
			outputSlicedImage("locations/case3/tenderLenderEN.png",3130064);
			
			outputSlicedImage("case3/mapEN.png",3168156);
			outputSlicedImage("case3/paperEN.png",3172140);
			outputSlicedImage("case3/glenFallenEN.png",3189668);
			outputSlicedImage("case3/glenWinsEN.png",3202384);
			outputSlicedImage("case3/glenScreamsEN.png",3218064);
			outputSlicedImage("case3/maggeyEatsEN.png",3235740);
			outputSlicedImage("case3/emptyLunchboxEN.png",3266968);
		}
		
		private function extractCase4():void {
			
			outputSlicedImage("case4/1.png",3285364,32,8);
			outputSlicedImage("case4/2.png",3309480);
			outputSlicedImage("case4/atGunpoint.png",3322832);
			outputSlicedImage("case4/laptopInBed.png",3338056);
			
			outputSlicedImage("case4/cr/jp/1.png",3346940);
			outputSlicedImage("case4/mapJP.png",3350872);
			outputSlicedImage("case4/trunkPhoto.png",3358168);
			outputSlicedImage("case4/terryMeetsOnTheBridge.png",3372560);
			outputSlicedImage("case4/atGunpointOverhead.png",3389660);
			outputSlicedImage("case4/cr/en/1.png",3408100);
			outputSlicedImage("case4/mapEN.png",3412016);
		}
		
		private function extractCase5():void {
			outputSlicedImage("locations/case5/eantrence.png",3419372);
			outputSlicedImage("locations/case5/courtyard.png",3452692);
			outputSlicedImage("locations/case5/mainHall.png",3487616);
			outputSlicedImage("locations/case5/bridgeJP.png",3530564);
			outputSlicedImage("locations/case5/bridgeOutJP.png",3567304);
			outputSlicedImage("locations/case5/bridgeBurningJP.png",3604680);
			outputSlicedImage("locations/case5/heavenlyHallJP.png",3640164);
			outputSlicedImage("locations/case5/innerTemple.png",3676636,64);
			outputSlicedImage("locations/case5/trainingAntechamber.png",3746648);
			outputSlicedImage("locations/case5/innerGardenJP.png",3788572);
			outputSlicedImage("case5/urnRepair2JP.png",3830856);
			outputSlicedImage("case5/statue.png",3868512,32,8);
			outputSlicedImage("case5/cr/jp/1.png",3889256);
			outputSlicedImage("case5/cr/jp/2.png",3893516);
			outputSlicedImage("case5/mapJP.png",3897588);
			outputSlicedImage("case5/burntNotesAJP.png",3905892);
			outputSlicedImage("case5/burntNotesBJP.png",3913008);
			outputSlicedImage("case5/burntNotesCJP.png",3920112);
			outputSlicedImage("case5/paperJP.png",3927372);
			outputSlicedImage("case5/elsie.png",3944560);
			outputSlicedImage("case5/tapestryJP.png",3975640);
			outputSlicedImage("case5/misty.png",3983100);
			outputSlicedImage("case5/larryAwakens.png",3995184);
			outputSlicedImage("case5/irisStabsElsie.png",4017596);
			outputSlicedImage("case5/snowmobilePhoto.png",4037856);
			outputSlicedImage("case5/elsieAtTheAltar.png",4052112);
			outputSlicedImage("case5/larrysDrawing.png",4066388);
			outputSlicedImage("case5/tapestryStainedJP.png",4109828);
			outputSlicedImage("case5/burningBridge.png",4118428,32,8);
			outputSlicedImage("case5/godotStabsDahilia.png",4143368);
			outputSlicedImage("case5/burntBridge.png",4160152);
			outputSlicedImage("case5/elevatorMemories.png",4175384);
			//saveDecodedChunk("17.bin",4194060);
			outputSingleImage("case5/larryReachesOut.png",4194060,16,16,8);
			outputSlicedImage("locations/case5/courtyardNight.png",4206188);
			outputSlicedImage("case5/mayaVsElsie.png",4218976);
			outputSlicedImage("case5/dahilia/screaming.png",4238076);
			outputSlicedImage("case5/dahilia/floatingA.png",4244192);
			outputSlicedImage("case5/dahilia/floatingB.png",4252820);
			outputSlicedImage("case5/dahilia/floatingC.png",4261160);
			outputSlicedImage("case5/blueMagatama.png",4269336);
			outputSlicedImage("case5/endSketch.png",4280124,32,8);
			outputSlicedImage("locations/case5/bridgeBurningGrayscaleJP.png",4335164);
			
			outputSlicedImage("locations/case5/bridgeEN.png",4355700);
			outputSlicedImage("locations/case5/bridgeOutEN.png",4392596);
			outputSlicedImage("locations/case5/bridgeBurningEN.png",4430228);
			outputSlicedImage("locations/case5/heavenlyHallEN.png",4465728);
			outputSlicedImage("locations/case5/innerTempleEN.png",4502164,64);
			outputSlicedImage("locations/case5/innerGardenEN.png",4572112);
			
			outputSlicedImage("case5/urnRepair2EN.png",4614436);
			outputSlicedImage("case5/cr/en/1.png",4651820);
			outputSlicedImage("case5/cr/en/2.png",4655996);
			outputSlicedImage("case5/mapEN.png",4660088);
			outputSlicedImage("case5/burntNotesAEN.png",4668384);
			outputSlicedImage("case5/burntNotesBEN.png",4676256);
			outputSlicedImage("case5/burntNotesCEN.png",4683844);
			outputSlicedImage("case5/paperEN.png",4692088);
			outputSlicedImage("case5/tapestryEN.png",4708716);
			outputSlicedImage("locations/case5/bridgeBurningGrayscaleEN.png",4716176);
			
			//saveDecodedChunk("18.bing",4736688);
			outputSingleImage("case5/godotInDarkCourt.png",4736688);
		}
		
		private function extractSplashes():void {
			outputSlicedImage("case1/splashJP.png",4740416);
			outputSlicedImage("case2/splashJP.png",4744120);
			outputSlicedImage("case3/splashJP.png",4747876);
			outputSlicedImage("case4/splashJP.png",4751544);
			outputSlicedImage("case5/splashJP.png",4755276);
			outputSlicedImage("case1/splashEN.png",4759076);
			outputSlicedImage("case2/splashEN.png",4763184);
			outputSlicedImage("case3/splashEN.png",4767336);
			outputSlicedImage("case4/splashEN.png",4771468);
			outputSlicedImage("case5/splashEN.png",4775616);
		}
		
		private function extractPatches():void {
			outputPatch("locations/case2/patches/1a.png",1603424,4779860,6,4);
			outputPatch("locations/case2/patches/1b.png",1603424,4781312,6,4);
			outputPatch("locations/case2/patches/1c.png",1603424,4782600,6,3);
			outputPatch("locations/case2/patches/2a.png",1603424,4783540,5,5);
			outputPatch("locations/case2/patches/2b.png",1603424,4784964,5,5);
			outputPatch("locations/case2/patches/3.png",1603424,4786328,6,2);//24.bin
			outputPatch("locations/case2/patches/4.png",1603424,4786964,5,4);//25.bin
			outputPatch("locations/case2/patches/5a.png",1667988,4787732,6,4);//26.bin
			outputPatch("locations/case2/patches/5b.png",1667988,4789044,6,4);//27.bin
			outputPatch("locations/case2/patches/6.png",1740132,4790060,8,3);//28.bin
			outputPatch("locations/case2/patches/7.png",1740132,4791160,3,1);//29.bin
			
			outputPatch("locations/case3/patches/1a.png",2642948,4791328,6,2);//30.bin
			outputPatch("locations/case3/patches/1b.png",2642948,4791880,9,3);//31.bin
			outputPatch("locations/case3/patches/1c.png",2642948,4793328,9,3);//32.bin
			outputPatch("locations/case3/patches/2.png",2606080,4794724,3,1);//33.bin
			outputPatch("locations/case3/patches/3.png",2606080,4794900,2,1);//34.bin
			outputPatch("locations/case3/patches/4.png",2818868,4795024,2,4);//35.bin
			
			
			/*
			archiveData.position=4786328;
			for(var i:uint=24;archiveData[archiveData.position]==0x10;++i) {
				trace(archiveData.position,i);
				saveDecodedChunk("unknownPatches/"+i+".bin",archiveData.position);
				archiveData.position=alignedOffset;
			}*/
		}		

		private function experiment():void {
			outputBin("archive1",12389632);
		}

	}
	
}
