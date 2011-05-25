package Nitro.Graphics {
	
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	public class NCER {
		
		public var cells:Vector.<Cell>;
		public var labels:Vector.<String>;
		
		public var subImages:Boolean;

		public function NCER() {
		}
		
		public function parse(data:ByteArray):void {
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			
			if(sections.id!="RECN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			var section:ByteArray=sections.open("KBEC");
			section.endian=Endian.LITTLE_ENDIAN;
			
			parseKBEC(section);
			
			if(sections.hasSection("LBAL")) {
				section=sections.open("LBAL");
				section.endian=Endian.LITTLE_ENDIAN;
				parseLBAL(section);
			}
				
				
		}
		
		private function parseKBEC(section:ByteArray):void {
			
			var cellCount:uint=section.readUnsignedShort();
			var version:uint=section.readUnsignedShort();
			
			if(version>1) {
				throw new ArgumentError("Unknown version: "+version);
			}
			
			cells=new Vector.<Cell>();
			cells.length=cellCount;
			cells.fixed=true;
			
			section.position+=4;//seek past unknown constant
			var flags:uint=section.readUnsignedInt();
			
			var tileIndexShift:uint=flags & 3;
			
			var partionOffset:uint=section.readUnsignedInt();
			subImages=Boolean(flags & 4);
			
			section.position+=8;//padding
			
			var cellOffset:uint=section.position;
			
			var cellDataSize:uint=8;
			if(version==1) {
				cellDataSize+=8;
			}
			
			var oamStart:uint=cellOffset+cellDataSize*cellCount;
			
			var cellItr:uint;
			
			for(cellItr=0;cellItr<cellCount;++cellItr) {
				section.position=cellOffset+cellDataSize*cellItr;
				
				var cell:Cell=new Cell();
				cells[cellItr]=cell;
				
				var numOAMS:uint=section.readUnsignedShort();
				section.position+=2;
				var oamOffset:uint=section.readUnsignedInt();
				if(version==1) {
					var xMax:int=section.readShort();
					var yMax:int=section.readShort();
					var xMin:int=section.readShort();
					var yMin:int=section.readShort();
				}
				
				cell.oams=new Vector.<CellOam>();
				cell.oams.length=numOAMS;
				cell.oams.fixed=true;
				
				section.position=oamStart+oamOffset;
				
				for(var j:uint=0;j<numOAMS;++j) {
					
					var oam:CellOam=new CellOam();
					cell.oams[j]=oam;
				
					oam.y=section.readByte();
					var atts0:uint=section.readUnsignedByte();
					
					var rs:Boolean=(atts0 & 1) == 1;
					
					if(rs) {
						oam.doubleSize=(atts0 & 2) ==2;
					} else {
						oam.hide=(atts0 & 2) ==2;
					}
					
					var shape:uint=atts0 >> 6;
					
					var atts1:uint=section.readUnsignedShort();
					
					oam.x=atts1 & 0x1FF;
					
					if(oam.x>=0x100) {
						oam.x-=0x200;
					}
					
					if(!rs) {
						oam.xFlip=(atts1 & 0x1000)==0x1000;
						oam.yFlip=(atts1 & 0x2000)==0x2000;
					}
					
					var objSize:uint=atts1 >> 14;
					
					var atts2:uint=section.readUnsignedShort();
					
					oam.tileIndex=(atts2 & 0x3FF);
					if(tileIndexShift) {
						oam.tileIndex <<= (tileIndexShift-1);
					}
					oam.paletteIndex= atts2 >> 12;
					
					oam.setSize(objSize,shape);
				}
			}
			
			
		}
		
		public function get length():uint { return cells.length; }
		
		public function rend(cellId:uint,palette:Vector.<uint>,tiles:NCGR,useTransparency:Boolean=true):DisplayObject {
			var cell:Cell=cells[cellId];
			return cell.rend(palette,tiles,subImages,useTransparency);
		}
		
		private function parseLBAL(section:ByteArray):void {
			
			
			var offsets:Vector.<uint>=new Vector.<uint>();
			
			for(;;) {
				var offset:uint=section.readUnsignedInt();
				
				if(offset+section.position>=section.length) break;
				
				offsets.push(offset);
			}
			
			var firstLabelOffset:uint=section.position;
			
			labels=new Vector.<String>();
			labels.length=offsets.length;
			labels.fixed=true;
			
			var cellId:uint=0;
			
			for each(offset in offsets) {
				section.position=offset+firstLabelOffset;
				
				labels[cellId++]=readZeroTermString(section);
			}
		}
		
		private function readZeroTermString(d:ByteArray):String {
			var startOffset:uint=d.position;
			
			for(var len:uint=0;d.readUnsignedByte()!=0;++len) {}
			
			d.position=startOffset;
			
			return d.readUTFBytes(len);
		}

	}
	
}
