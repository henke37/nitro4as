package Nitro.FileSystem {
	
	public class AbstractFile {
		
		public var name:String;
		public var parent:Directory;

		public function AbstractFile(name:String,parent:Directory) {
			this.name=name;
			this.parent=parent;
		}

	}
	
}
