package Nitro.GK2 {
	import flash.utils.*;

	public class SPTEntry {
		public var offset:uint;
		public var size:uint;
		public var flag1:uint;
		public var flag2:uint;
		
		private var _script:XML;
		private var _encodedScript:ByteArray;
		
		internal static const entryLength:uint=8;
		
		public function loadScript(script:XML,spt:SPT):void {
			_script=script;
			
			var writer:SectionWriter=new SectionWriter(spt);
			
			_encodedScript=writer.buildSection(script);
		}
		
		internal function get encodedScript():ByteArray { return _encodedScript; }
	}
}