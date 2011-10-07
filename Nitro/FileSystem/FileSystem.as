package Nitro.FileSystem {
	
	import flash.utils.*;
	
	/** The filesystem contained in a NDS file. */
	
	public class FileSystem {
		
		private var nds:ByteArray;
		private var FNTPos:uint;
		private var FATPos:uint;
		
		/** The root directory of the filesystem. */
		public var rootDir:Directory;

		public function FileSystem() {
			
		}
		
		/** Loads a filesystem from a ByteArray
		@param nds The ByteArray to load from
		@param FNTPos The position of the file name table
		@param FATPos The position of the file allocation table
		@param FNTSize The size of the file name table
		@param FATSize The size of the file allocation table
		*/
		public function parse(nds:ByteArray,FNTPos:uint,FNTSize:uint,FATPos:uint,FATSize:uint):void {
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
							dir.files.push(makeFile(name,dir,fileId++));
						}
					}
					
				}
				
				dir.files.fixed=true;
			}
			
		}
		/**
		Resolves a path in the filesystem into an openable file.
		@param path The path to resolve
		@param endOnFile Ignore trailing filenames so that files in archive files can be opened.
		@return A new AbstractFile that can be opened.
		*/
		public function resolvePath(path:String,endOnFile:Boolean=false):AbstractFile {
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
				
				if(foundFile && entry is File && endOnFile) {
					return entry;
				}
				
				dir=entry as Directory;
			}
			
			return entry;
		}
		
		/** Searches for a filename in the filesystem
		@param baseDir The directory to start searching in
		@param filter The filename to search for
		@param allowRecursion Search in subfolders too
		@param justFirst Stop after the first match
		@return A new vector containing the found matches
		*/
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
		
		/** Returns the full filename for a file
		@param file The file
		@return The full filename for the file*/
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
		
		/** Opens a file by name.
		@param path The file name to open
		@return A new ByteArray holding the contents of the file
		*/
		public function openFileByName(path:String):ByteArray {
			var file:File=File(resolvePath(path));
			
			return openFileByReference(file);
		}
		
		/** Opens a file by refernce
		@param file The reference to the file
		@return A new ByteArray holding the contents of the file
		*/
		public function openFileByReference(file:File):ByteArray {
			var out:ByteArray=new ByteArray();
			
			nds.position=file.offset;
			nds.readBytes(out,0,file.size);
			
			return out;
		}
		
		/** Opens a file by a FAT index
		@param id The fat index
		@return A new ByteArray holding the contents of the file
		*/
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
		
		private function makeFile(name:String,parent:Directory,id:uint):File {
			var file:File=new File(name,parent,id);
			
			var readPos:uint=nds.position;
			
			try {
				nds.position=id*8+FATPos;
				
				var start:uint=nds.readUnsignedInt();
				var stop:uint=nds.readUnsignedInt();
				var len:uint=stop-start+1;
				
				file.offset=start;
				file.size=len;
			} finally {//no pesky read error is going to mess with the main reading
				nds.position=readPos;
			}
			
			return file;
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