package Nitro.FileSystem {
	
	/** A directory in the filesystem. */
	
	public class Directory extends AbstractFile {
		
		/** The files and directories in the directory. */
		public var files:Vector.<AbstractFile>;

		public function Directory(name:String,parent:Directory) {
			super(name,parent);
			
			files=new Vector.<AbstractFile>();
		}

	}
	
}
