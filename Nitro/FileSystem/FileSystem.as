package Nitro.FileSystem {
	
	import flash.utils.*;
	
	public class FileSystem {
		
		private var nds:ByteArray;
		private var FNTPos:uint;
		private var FATPos:uint;
		
		public var rootDir:Directory;

		public function FileSystem(nds:ByteArray,FNTPos:uint,FNTSize:uint,FATPos:uint,FATSize:uint) {
			this.nds=nds;
			this.FNTPos=FNTPos;
			this.FATPos=FATPos;
			
			nds.position=FNTPos;
			
			var dirIndex:Vector.<DirIndexEntry>=new Vector.<DirIndexEntry>();
			
			//root entry needs special treatment since it smuggles the dir count
			dirIndex.push(new DirIndexEntry(nds.readUnsignedInt(),nds.readUnsignedShort(),0));
			dirIndex.length=nds.readUnsignedShort();
			dirIndex.fixed=true;
			
			dirIndex[0].dir=rootDir=new Directory("$ROOT",null);
			
			for(var i:uint=1;i<dirIndex.length;++i) {
				dirIndex[i]=new DirIndexEntry(nds.readUnsignedInt(),nds.readUnsignedShort(),nds.readUnsignedShort());
			}
			
			
			for each(var entry:DirIndexEntry in dirIndex) {
				var dir:Directory=entry.dir;
				
				var fileId:uint=entry.firstFileID;
				
				nds.position=FNTPos+entry.offset;
				
				for(;;) {
					var type:uint=nds.readUnsignedByte();
					
					if(type==0) {
						break;
					} else {
						var len:uint=type & 0x7F;
						var name:String=nds.readUTFBytes(len);
						if(type & 0x80) {
							var subDir:Directory=new Directory(name,dir);
							dir.files.push(subDir);
							var subId:uint=nds.readUnsignedShort();
							dirIndex[subId & 0x0FFF].dir=subDir;
						} else {
							dir.files.push(new File(name,dir,fileId++));
						}
					}
					
				}
				
				dir.files.fixed=true;
			}
			
		}

	}
	
}

import Nitro.FileSystem.*;

class DirIndexEntry {
	public var offset:uint;
	public var firstFileID:uint;
	public var parent:uint;
	public var dir:Directory;
	
	public function DirIndexEntry(offset:uint,firstFileID:uint,parent:uint) {
		this.offset=offset;
		this.firstFileID=firstFileID;
		this.parent=parent;
	}
}