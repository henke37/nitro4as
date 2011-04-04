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
		
		public function resolvePath(path:String):AbstractFile {
			var folders:Array=path.split("/");
			
			var dir:Directory=rootDir;
			
			var entry:AbstractFile;
			
			while(folders.length) {
				var fileName:String=folders.shift();
				
				entry=null;
				var foundFile:Boolean=false;
				
				for each(entry in dir.files) {
					if(entry.name==fileName) {
						foundFile=true;
						break;
					}
				}
				
				if(!foundFile) {
					throw new ArgumentError("Unknown filename \""+fileName+"\" in \""+path+"\".");
				}
				
				dir=entry as Directory;
			}
			
			return entry;
		}
		
		public function searchForFile(baseDir:Directory,filter:RegExp,allowRecursion:Boolean=false,justFirst:Boolean=false):Vector.<AbstractFile> {
			
			var out:Vector.<AbstractFile>=new Vector.<AbstractFile>();
			
			for each(var entry:AbstractFile in baseDir.files) {
				
				if(entry.name.match(filter)) {
					out.push(entry);
				}
				
				var subDir:Directory=entry as Directory;
				
				if(subDir && allowRecursion) {
					out=out.concat(searchForFile(subDir,filter,true));
				}
				
				if(justFirst && out.length>0) {
					break;
				}
			}
			
			return out;
		}
		
		public function getFullNameForFile(file:AbstractFile):String {
			var o:String;
			
			o=file.name;
			
			file=file.parent;
			
			while(file.parent) {
				o=file.name+"/"+o;
				file=file.parent;
			}
			
			return o;
		}
		
		public function openFileByName(path:String):ByteArray {
			var file:File=File(resolvePath(path));
			
			return openFileByReference(file);
		}
		
		public function openFileByReference(file:File):ByteArray {
			return openFileById(file.fileId);
		}
		
		public function openFileById(id:uint):ByteArray {
			
			nds.position=id*8+FATPos;
			
			var start:uint=nds.readUnsignedInt();
			var stop:uint=nds.readUnsignedInt();
			var len:uint=stop-start+1;
			
			var out:ByteArray=new ByteArray();
			
			nds.position=start;
			nds.readBytes(out,0,len);
			
			return out;
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