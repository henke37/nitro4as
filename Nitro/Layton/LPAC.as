package Nitro.Layton {
	import flash.utils.*;
	
	import Nitro.*;
	
	public class LPAC {
		
		private static const fatEntryLength:uint=12;
		
		public var files:Vector.<FileEntry>;
		
		private var data:ByteArray;

		public function LPAC() {
			files=new Vector.<FileEntry>();
		}
		
		/** Parses a X from a ByteArray
		@param data The ByteArray*/
		public function parse(data:ByteArray):void {
			if(!data) throw new ArgumentError("The data can not be null!");
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			this.data=data;
			
			var type:String=data.readUTFBytes(4);
			if(type!="LPC2") throw new ArgumentError("Incorrect filetype, should be LPC2 but is "+type);
			
			var count:uint=data.readUnsignedInt();
			data.position+=4;//fileContents start
			var archiveFileSize:uint=data.readUnsignedInt();
			
			const fatStartOffset:uint=data.readUnsignedInt();
			
			const fileNameBaseOffset:uint=data.readUnsignedInt();
			const fileContentsBaseOffset:uint=data.readUnsignedInt();
			
			files.length=count;
			files.fixed=true;
			
			for(var i:uint=0;i<count;++i) {
				
				data.position=fatStartOffset+fatEntryLength*i;
				
				var nameOffset:uint=data.readUnsignedInt();
				nameOffset+=fileNameBaseOffset;
				var fileContentsOffset:uint=data.readUnsignedInt();
				fileContentsOffset+=fileContentsBaseOffset;
				var fileSize:uint=data.readUnsignedInt();
				
				var file:FileEntry=new FileEntry();
				file.offset=fileContentsOffset;
				file.size=fileSize;
				file.name=readNullString(data,nameOffset);
				
				//trace(file);
				
				files[i]=file;
			}
		}
		
		/** Opens a file by name
		@param name The file name
		@return A new ByteArray containing the contents of the file
		@throws ArgumentError No file with the given name exists */
		public function openFileByName(name:String):ByteArray {
			for(var i:uint=0;i<files.length;++i) {
				var entry:FileEntry=files[i];
				if(entry.name==name) return openFileByReference(entry);
			}
			throw new ArgumentError("No file with the given name exists.");
		}
		
		/** Opens a file by reference
		@param entry The file entry to open
		@return A new ByteArray containing the contents of the file
		@throws ArgumentError The entry can not be null */
		public function openFileByReference(entry:FileEntry):ByteArray {
			if(!entry) throw new ArgumentError("The entry can not be null");
			
			var o:ByteArray=new ByteArray();
			o.writeBytes(data,entry.offset,entry.size);
			o.position=0;
			return o;
		}

	}
	
}

class FileEntry {
	public var name:String;
	public var size:uint;
	public var offset:uint;
	
	public function toString():String {
		return "[FileEntry \""+name+"\" "+size.toString()+" "+offset.toString()+"]";
	}
}