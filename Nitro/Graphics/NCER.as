package Nitro.Graphics {
	
	import flash.utils.*;
	import flash.display.*;
	
	import Nitro.*;
	
	/** Reader and writer of NCER files 
	
	<p>A NCER file contains a sequence of Cells</p>*/
	
	public class NCER {
		
		/** The cells in the file */
		public var cells:Vector.<Cell>;
		
		/** The labels for the cells */
		public var labels:Vector.<String>;
		
		/** The tile layout mode for the individual oams */
		public var subImages:Boolean;

		public function NCER() {
		}
		
		/** Loads a NCER file from a ByteArray
		@param data The ByteArray to load from
		*/
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
				
				var sectionNudge:uint=0;
				if(partionOffset) {
					section.position=partionOffset+4+cellItr*4;
					sectionNudge=section.readUnsignedInt();
					sectionNudge/=Tile.width*Tile.height;
				}
				
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
					
					oam.colorDepth=atts0 >> 5 & 0x1;
					
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
					
					oam.tileIndex <<= tileIndexShift;
					oam.tileIndex += sectionNudge;
					
					oam.paletteIndex= atts2 >> 12;
					
					oam.priority=atts2 >> 10 & 0x3;
					
					oam.setSize(objSize,shape);
				}
			}
			
			
		}
		
		/** The number of cells in the file */
		public function get length():uint { return cells.length; }
		
		/** Rends a single cell
		@param cellId The id of the cell to rend
		@param palette The pallete to use when rendering the tiles, in RGB888 format
		@param tiles The GraphicsBank where the tiles are stored
		@param useTransparence If the tiles should be rendered using transparency
		@return A DisplayObject that represents the cell */
		public function rend(cellId:uint,palette:Vector.<uint>,tiles:GraphicsBank,useTransparency:Boolean=true):DisplayObject {
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
			
			var firstLabelOffset:uint=section.position-4;
			
			labels=new Vector.<String>();
			labels.length=offsets.length;
			labels.fixed=true;
			
			var cellId:uint=0;
			
			for each(offset in offsets) {
				section.position=offset+firstLabelOffset;
				var label:String=readZeroTermString(section);
				//trace(label);
				labels[cellId++]=label;
			}
		}
		
		private function readZeroTermString(d:ByteArray):String {
			var startOffset:uint=d.position;
			
			for(var len:uint=0;d.readUnsignedByte()!=0;++len) {}
			
			d.position=startOffset;
			
			return d.readUTFBytes(len);
		}
		
		/** Writes the file to a new ByteArray
		@return The new ByteArray
		@param version The version to use when writing
		*/
		public function save(version:uint=0):ByteArray {
			var sections:SectionedFile=new SectionedFile();
			
			var sectionList:Object={ KBEC: writeKBEC(version), LBAL: writeLBAL() };
			
			sections.build("RECN",sectionList);
			
			return sections.data;
		}
		
		private function writeLBAL():ByteArray {
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			var offset:uint=0;
			var textOut:ByteArray=new ByteArray();
			var pointerOut:ByteArray=new ByteArray();
			pointerOut.endian=Endian.LITTLE_ENDIAN;
			
			for each(var label:String in labels) {
				pointerOut.writeUnsignedInt(textOut.length);
				textOut.writeUTFBytes(label);
				textOut.writeByte(0);
			}
			
			o.writeBytes(pointerOut);
			o.writeBytes(textOut);
			
			return o;
		}
		
		private function writeKBEC(version:uint):ByteArray {
			var o:ByteArray=new ByteArray();
			o.endian=Endian.LITTLE_ENDIAN;
			
			o.writeShort(cells.length);
			
			
			var cellDataSize:uint=8;
			if(version==1) {
				cellDataSize+=8;
			}
			
			o.writeShort(version);
			
			o.writeUnsignedInt(0x18);//start of cell data
			
			
			
			var shift:uint=bestShift();
			
			var flags:uint=shift;
			if(subImages) flags |= 4;
			o.writeUnsignedInt(flags);
			
			o.writeUnsignedInt(0);//partioning, not supported
			
			o.writeUnsignedInt(0);//padding
			o.writeUnsignedInt(0);
			
			var cellOut:ByteArray=new ByteArray();
			cellOut.endian=Endian.LITTLE_ENDIAN;
			
			var oamOut:ByteArray=new ByteArray();
			oamOut.endian=Endian.LITTLE_ENDIAN;
			
			
			
			
			
			for each(var cell:Cell in cells) {
				cellOut.writeShort(cell.oams.length);
				cellOut.writeShort(0);
				cellOut.writeUnsignedInt(oamOut.length);
				for each(var oam:CellOam in cell.oams) {
					oamOut.writeByte(oam.y);
					oamOut.writeByte(att0(oam));
					oamOut.writeShort(att1(oam));
					oamOut.writeShort(att2(oam,shift));
				}
				
			}
			o.writeBytes(cellOut);
			o.writeBytes(oamOut);
			
			return o;
		}
		
		private function att0(oam:CellOam):uint {
			var o:uint=0;
			
			if(oam.doubleSize) {
				o|=0x30;
			} else if(oam.hide) {
				o|=0x20;
			}
			
			o|=oam.colorDepth<<5;
			
			if(oam.width==oam.height) {
				o|=0;
			} else if(oam.width<oam.height) {
				o|=0x80;
			} else if(oam.width>oam.height) {
				o|=0x40;
			} else {
				o|=0xC0;
			}
			
			return o;
		}
		
		private function att1(oam:CellOam):uint {
			var o:uint=0;
			
			o|=oam.x&0x1FF;
			
			if(oam.xFlip) {
				o|=0x1000;
			}
			if(oam.yFlip) {
				o|=0x2000;
			}
			
			o|=oam.getSize()<<14;
			
			return o;
		}
		
		private function att2(oam:CellOam,shift:uint):uint {
			var o:uint=0;
			
			var shiftedTileIndex:uint=oam.tileIndex;
			if(shift>0) {
				shiftedTileIndex>>>=shift;
			}
			return shiftedTileIndex | oam.paletteIndex << 12;
		}
		
		private function bestShift():uint {
			var tileIndexSum:uint=0;
			for each(var cell:Cell in cells) {
				for each(var oam:CellOam in cell.oams) {
					tileIndexSum|=oam.tileIndex;
				}
			}
			
			if(tileIndexSum==0) return 0;//try not to crash
			
			var shift:uint=0;
			while((tileIndexSum &1)==0 && shift <3) {
				++shift;
				tileIndexSum>>>=1;
			}
			
			return shift;
		}

	}
	
}
