package Nitro.Layton {
	
	/** A file in a LPAC archive */
	public class FileEntry {
		/** The name of the file */
		public var name:String;
		/** The size of the file */
		public var size:uint;
		/** The offset of the file */
		public var offset:uint;
		
		public function toString():String {
			return "[FileEntry \""+name+"\" "+size.toString()+" "+offset.toString()+"]";
		}
	}
	
}
