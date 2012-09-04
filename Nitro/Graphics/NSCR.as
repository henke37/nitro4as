package Nitro.Graphics {
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	/** NSCR File reader and writer
	
	<p>NSCR files defines screens of tiled graphics</p>
	*/
	
	public class NSCR extends TileMappedScreen {
		/** The height of the viewport for the screen, measured in pixels. */
		public var dataHeight:uint;
		/** The width of the viewport for the screen, measured in pixels. */
		public var dataWidth:uint;
		
		public function NSCR() {
			// constructor code
		}
		
		/** Loads a NSCR file from a ByteArray
		@param data The ByteArray to load from
		*/
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RCSN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			var section:ByteArray=sections.open("NRCS");
			section.endian=Endian.LITTLE_ENDIAN;
			
			const width:uint=section.readUnsignedShort();
			const height:uint=section.readUnsignedShort();
			
			if(width % Tile.width || height % Tile.height) throw new ArgumentError("Width and height must be evenly divdeable by the tile size!");
			
			var size:uint=section.readUnsignedShort();
			var mode:uint=section.readUnsignedShort();
			
			if(mode==0) {
				dataHeight=[256,256,512,512][size];
				dataWidth=[256,512,256,512][size];
			} else {
				dataHeight=[128,256,512,1024][size];
				dataWidth=[128,256,512,1024][size];
			}
			
			section.position=0x0C;
			
			loadEntries(section,width/Tile.width,height/Tile.height,true);
		}
		
	}
	
}