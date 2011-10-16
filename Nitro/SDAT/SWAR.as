package Nitro.SDAT {
	
	import flash.utils.*;
	import Nitro.SectionedFile;
	
	//use namespace strmInternal;
	
	/** SWAR file reader
	
	<p>SWAR files contains a set of sound clips</p> */
	
	public class SWAR extends SubFile{

		private var data:ByteArray;
		
		/** The sound clips*/
		public var waves:Vector.<Wave>;

		public function SWAR() {
			
		}
		
		/** Loads a file from a ByteArray
		@param data The ByteArray to load from*/
		public override function parse(data:ByteArray):void {
			this.data=data;
			if(!data) {
				throw new ArgumentError("data can not be null!");
			}
			data.position=0;
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="SWAR") {
				throw new ArgumentError("Invalid SWAR block, wrong type id");
			}
			
			parseDATA(sections.open("DATA"));
			
			
		}
		
		private function parseDATA(section:ByteArray):void {
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			const padding:uint=8*4;//pointless padding
			section.position=padding;
			var count:uint=section.readUnsignedInt();
			
			//trace(count);
			
			waves=new Vector.<Wave>();
			
			for(var i:uint;i<count;++i) {
				section.position=padding+4+4*i;
				var pos:uint=section.readUnsignedInt();
				var wave:Wave=new Wave();
				wave.parse(pos,section);
				waves.push(wave);
			}
		}

	}
	
}
