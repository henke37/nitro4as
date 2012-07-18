package Nitro.SDAT {
	
	public class FATRecord {
		public var size:uint,pos:uint;
		
		public function FATRecord(s:uint,p:uint) {
			if(s<4) throw new ArgumentError("Files have a minimum size");
			size=s;pos=p;
		}
	}
	
}
