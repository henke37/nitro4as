package  {
	import flash.net.*;
	import flash.events.*;
	
	public class Table extends EventDispatcher {
		
		private var loader:URLLoader;
		
		private var entries:Object;
		private var reverseEntries:Object;

		public function Table() {
			entries={};
			reverseEntries={};
		}

		public function loadFromFile(request:URLRequest) {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE,parseLoadedFile);
			loader.load(request);
		}
		
		private function parseLoadedFile(e:Event):void {
			loadFromString(loader.data);
		}
		
		public function loadFromString(data:String):void {
			var lines:Array=data.split("\n");
			data="";//just to keep the debugger from looking bad when displaying the vars
			
			for each(var line:String in lines) {
				line=line.replace("\n","").replace("\r","");
				var parts:Array=line.split("=",2);
				var bytes:String=parts[0];
				bytes=bytes.toLowerCase();
				var replacement:String=parts[1];
				addEntry(bytes,replacement);
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function addEntry(bytes:String,replacement:String):void {
			entries[bytes]=replacement;
			reverseEntries[replacement]=bytes;
		}
		
		public function matchEntry(entry:String):String {
			entry=entry.toLowerCase();
			if(!(entry in entries)) return "<$"+entry+">";
			return entries[entry];
		}
	}
	
}
