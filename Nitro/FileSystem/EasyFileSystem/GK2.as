package Nitro.FileSystem.EasyFileSystem {
	
	import flash.utils.*;
	
	import Nitro.FileSystem.*;
	import Nitro.GK2.*;
	
	public class GK2 extends Basic {

		public function GK2(nds:NDS) {
			super(nds);
		}
		
		private var lastSubArchiveName:String,lastSubArchive:GKSubarchive;
		private var lastArchiveName:String,cachedArchive:GKArchive;
		private var lastFileName:String,cachedData:ByteArray;
		
		public override function openFile(path:String):ByteArray {
			var file:File=File(nds.fileSystem.resolvePath(path,true));
			
			var fileName:String=nds.fileSystem.getFullNameForFile(file);
			
			var data:ByteArray;
			
			if(fileName!=lastFileName) {
				data=nds.fileSystem.openFileByReference(file);
				lastFileName=fileName;
				cachedData=data;
			} else {
				data=cachedData;
			}
			
			var archiveName:String=fileName;
			fileName=path.substr(fileName.length);
			
			var matches:Array=fileName.match(/^\/([0-9]+)(.*)/);
			if(matches) {
				var archive:GKArchive;
				
				if(archiveName!=lastArchiveName) {
					archive=new GKArchive();
					archive.parse(data);
					cachedArchive=archive;
					lastArchiveName=archiveName;
				} else {
					archive=cachedArchive;
				}
				
				data=archive.open(parseInt(matches[1]));
				fileName=matches[2];
				archiveName+="/"+matches[1];
			}
			
			matches=fileName.match(/^\/([0-9]+)(.*)/);
			if(matches) {
				var subArchive:GKSubarchive;
				if(lastSubArchiveName!=archiveName) {
					subArchive=new GKSubarchive();
					subArchive.parse(data);
					lastSubArchive=subArchive;
					lastSubArchiveName=archiveName;
				} else {
					subArchive=lastSubArchive;
				}
								
				data=subArchive.open(parseInt(matches[1]));
				fileName=matches[2];
			}
			
			return data;
		}

	}
	
}
