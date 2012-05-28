package  {
	
	import flash.events.*;

	public class GS1Extracter extends GSBaseExtractor {
		
		public function GS1Extracter() {
			super("gs1.nds");
		}
		
		protected override function outDirSelected(e:Event):void {
			
			extractVideos();
			extractBase();
			
			traceCurrentOffset();
		}
		
		private function extractVideos():void {
			outputVideo("badger",0,32,20);
			outputVideo("15intro",1823768);
			outputVideo("securityVideo",2677052);
			outputVideo("epiloge",25266104);
		}
		
		private function extractBase():void {
			//outputBin("archive5",27669216);//useless junk, a bunch of way too content free files
			//outputBin("archive6",27727316);/more junk
			//outputBin("archive7",27731420);//junk
			//outputBin("archive8",27741988);//junk
			
			outputSingleImage("jplogo.png",27753756,32,24,8);
			outputSingleImage("enlogo.png",27771340,32,24,8);
						
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
			
			outputSingleImage("bottomBg.png",29401108,32,24);
		}
	}
	
}
