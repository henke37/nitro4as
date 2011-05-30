package GKTool {
	
	import Nitro.GK.*;
	
	import flash.utils.*;
	import flash.net.*;
	
	public class SptExtractScreen extends ExtractBaseScreen {
		
		var archive:GKArchive;
		
		private var subFileNr:uint;
		private var subFile:SPT;
		private var sectionNr:uint;

		private var numberSize:uint;
		private var subNumberSize:uint;
		
		public static const archiveFileName:String="jpn/spt.bin";
		
		private var table:Table;

		public function SptExtractScreen() {
			table=new Table();
			table.loadFromFile(new URLRequest("AAI2Jpn.tbl"));
		}
		
		protected override function beginExtraction():uint {
			var archiveData:ByteArray=gkTool.nds.fileSystem.openFileByName(archiveFileName);
			
			archive=new GKArchive();
			archive.parse(archiveData);
			
			numberSize=archive.length.toString().length;
			
			return archive.length;
		}
		
		protected override function processNext():Boolean {
			
			try {
				if(!subFile) {
					++progress;
					subFile=new SPT();
					subFile.parse(archive.open(subFileNr));
					subNumberSize=subFile.length.toString().length;
				}
				var sectionData:XML=subFile.parseSection(sectionNr,table);
				
				var subFileName:String=archiveFileName+"/"+padNumber(subFileNr,numberSize)+"/"+padNumber(sectionNr,subNumberSize)+".xml";				
				
				var data=new ByteArray();
				data.writeUTFBytes(sectionData.toXMLString());
				
				saveFile(subFileName,data);
				
				log("Extracted \""+subFileName+"\"");
				
				++sectionNr;
			} catch(err:ArgumentError) {
				log("Failed to extract\""+subFileName+"\". It's not a SPT file.");
				++errors;
				subFile=null;
			}
			
			if(!subFile || sectionNr>=subFile.length) {
				sectionNr=0;
				++subFileNr;
				subFile=null;
			}
			if(subFileNr>=archive.length) return false;
			return true;
		}

	}
	
}
