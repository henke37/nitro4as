package Nitro.FileSystem {
	
	public class Directory extends AbstractFile {
		
		public var files:Vector.<AbstractFile>;

		public function Directory(name,parent) {
			super(name,parent);
			
			files=new Vector.<AbstractFile>();
		}

	}
	
}
