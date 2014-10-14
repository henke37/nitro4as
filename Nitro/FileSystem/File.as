package Nitro.FileSystem {
	
	/** A file in the filesystem. */
	
	public class File extends AbstractFile {
		
		/** The FAT index for the file. */
		internal var fileId:uint;
		
		/** The position of the file contents in the filesystem. */
		internal var offset:uint;
		
		/** The size of the file contents. */
		public var size:uint;

		public function File(name:String,parent:Directory,fid:uint) {
			super(name,parent);
			
			fileId=fid;
		}
		
		public function toString():String {
			return "[File name="+name+" id="+fileId+"]";
		}

	}
	
}
