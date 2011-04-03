package Nitro.FileSystem {
	
	public class File extends AbstractFile {
		
		internal var fileId:uint;

		public function File(name:String,parent:Directory,fid:uint) {
			super(name,parent);
			
			fileId=fid;
		}

	}
	
}
