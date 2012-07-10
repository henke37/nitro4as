package Nitro.Layton {
	
	public class FileEntry {
		public var name:String;
		public var size:uint;
		public var offset:uint;
		
		public function toString():String {
			return "[FileEntry \""+name+"\" "+size.toString()+" "+offset.toString()+"]";
		}
	}
	
}
