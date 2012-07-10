package Nitro.Dusk {
	import flash.utils.*;
	
	public class WPF {

		private var entries:Vector.<FileEntry>;
		
		private static const entryLen:uint=0x20;
		private static const nameLen:uint=24;

		public function WPF() {
			entries=new Vector.<FileEntry>();
		}
		
		public function parse(tbl:ByteArray,wpf:ByteArray):void {
			tbl.endian=Endian.LITTLE_ENDIAN;
			wpf.endian=Endian.LITTLE_ENDIAN;
			
			var pos:uint;
			for(;;pos+=entryLen) {
				tbl.position=pos;
				var name:String=tbl.readUTFBytes(nameLen);
				
				if(name=="") break;
				
				tbl.position=pos+nameLen;
				var size:uint=tbl.readUnsignedInt();
				var position:uint=tbl.readUnsignedInt();
				
				trace(name,size,position);
			}
		}

	}
	
}

class FileEntry {
	public var name:String;
	public var offset:uint;
	public var size:uint;
}