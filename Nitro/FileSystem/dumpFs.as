package Nitro.FileSystem {
	public function dumpFs(dir:Directory) {
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