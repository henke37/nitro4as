﻿package Nitro.FileSystem {
	/** Dumps a directory tree to XML */
	public function dumpFs(dir:Directory):XML {
		var o:XML=<dir name={dir.name} />;
		
		for each(var abf:AbstractFile in dir.files) {
			var subDir:Directory=abf as Directory;
			if(subDir) {
				o.appendChild(dumpFs(subDir));
			} else {
				var file:File=File(abf);
				o.appendChild(<file name={abf.name} offset={file.offset} size={file.size} />);
			}
		}
		return o;
	}
	
}