package Nitro.FileSystem.EasyFileSystem {
	import flash.utils.ByteArray;
	import Nitro.FileSystem.NDS;
	
	public class Basic implements IEasyFileSystem {

		protected var nds:NDS;

		public function Basic(nds:NDS) {
			if(!nds) throw new ArgumentError("The nds argument can not be null!",1507);
			this.nds=nds;
		}
		
		public function openFile(fileName:String):ByteArray {
			return nds.fileSystem.openFileByName(fileName);
		}

	}
	
}
