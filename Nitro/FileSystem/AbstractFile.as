package Nitro.FileSystem {
	
	/** An abstract directory entry. */
	
	public class AbstractFile {
		
		/** The name of the file or directory. */
		public var name:String;
		/** The parent directory of the file or directory. */
		public var parent:Directory;

		public function AbstractFile(name:String,parent:Directory) {
			this.name=name;
			this.parent=parent;
		}

	}
	
}
