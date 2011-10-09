package Nitro.GK {
	import flash.utils.*;
	
	/** Tries to estimate the correct file extension for a file based on the contents of the time.
	@param data The contents of the file
	@param name The name of the file
	@return The file extension, without a leading dot*/
	
	public function sniffExtension(data:ByteArray,name:String):String {
				
		//false positives
		//if(name.indexOf("anmseq_chr.bin/")!=-1) return "bin";
		//if(name.indexOf("bustanmseq_chr.bin/")!=-1 return "bin";
		
		if(data.length<4) return "bin";
		
		data.endian=Endian.LITTLE_ENDIAN;
		
		var id:String=data.readUTFBytes(4);
		
		if(!id.match(/[ a-z0-9]{4}/i)) {
			
			data.position=0;
			var firstInt:uint=data.readUnsignedInt();
			if((firstInt%4)==0 && (firstInt/4) == 3) {
				return "subarchive";
			}
			
			return "bin";
		}
		
		id=id.replace(" ","").toLowerCase();
		
		switch(id) {
			case "bmd0":
				return "nsbmd";
			break;
			
			case "btx0":
				return "nsbtx";
			break;
			
			case "bca0":
				return "nsbca";
			break;
			
			default:
				return (id.charAt(3)+id.charAt(2)+id.charAt(1)+id.charAt(0));
			break;
		}
		
		
	}
}