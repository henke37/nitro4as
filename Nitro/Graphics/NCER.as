package Nitro.Graphics {
	
	import flash.utils.*;
	
	public class NCER {
		
		private const sectionOffset:uint=0x10;
		
		public var cells:Vector.<Cell>;

		public function NCER() {
		}
		
		public function parse(data:ByteArray):void {
			var type:String;
			
			data.endian=Endian.LITTLE_ENDIAN;
			
			type=data.readUTFBytes(4);
			if(type!="RECN") throw new ArgumentError("Incorrect file header, type is "+type);
			
			data.position=sectionOffset;
			type=data.readUTFBytes(4);
			if(type!="KBEC") throw new ArgumentError("Incorrect file header, section type is "+type);
			
			data.position=sectionOffset+8;
			var bankCount:uint=data.readUnsignedShort();
			var version:uint=data.readUnsignedShort();
			
			if(version>1) {
				throw new ArgumentError("Unknown version: "+version);
			}
			
			data.position=sectionOffset+0x10;
			var blockSize:uint= 1 << data.readUnsignedInt()+4;
			
			data.position=sectionOffset+0x20;			
			var cellCount:uint=data.readUnsignedShort();
			
			cells=new Vector.<Cell>();
			cells.length=cellCount;
			cells.fixed=true;
			
			data.position=sectionOffset+0x24;
			var cellOffset:uint=data.readUnsignedInt()+sectionOffset+8;
			
			var cellDataSize:uint=8;
			if(version==1) {
				cellDataSize+=8;
			}
			
			var oamStart:uint=cellOffset+cellDataSize*cellCount;
			
			var i:uint;
			
			for(i=0;i<cellCount;++i) {
				data.position=cellOffset+cellDataSize*i;
				
				var cell:Cell=new Cell();
				cells[i]=cell;
				
				var numOAMS:uint=data.readUnsignedShort();
				data.position+=2;
				var oamOffset:uint=data.readUnsignedInt();
				if(version==1) {
					var xMax:int=data.readShort();
					var yMax:int=data.readShort();
					var xMin:int=data.readShort();
					var yMin:int=data.readShort();
				}
				
				cell.oams=new Vector.<CellOam>();
				cell.oams.length=numOAMS;
				cell.oams.fixed=true;
				
				data.position=oamStart+oamOffset;
				
				for(var j:uint=0;j<numOAMS;++j) {
					
					var oam:CellOam=new CellOam();
					cell.oams[j]=oam;
				
					oam.x=data.readByte();
					var atts0:uint=data.readUnsignedByte();
					
					var rs:Boolean=(atts0 & 1) == 1;
					
					if(rs) {
						oam.doubleSize=(atts0 & 2) ==2;
					} else {
						oam.hide=(atts0 & 2) ==2;
					}
					
					var shape:uint=atts0 >> 6;
					
					oam.y=data.readUnsignedByte();
					
					var atts1:uint=data.readUnsignedByte();
					
					if((atts1 & 1) == 1) {
						oam.y-=0x200;
					}
					
					if(!rs) {
						oam.xFlip=(atts1 & 16)==16;
						oam.yFlip=(atts1 & 32)==32;
					}
					
					var objSize:uint=atts1 >> 6;
					
					var atts2:uint=data.readUnsignedShort();
					
					oam.tileIndex=atts2 & 0x103;
					oam.paletteIndex= atts2 >> 12;
				}
			}
			
			
		}

	}
	
}
