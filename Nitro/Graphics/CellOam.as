package Nitro.Graphics {
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	
	/** A tile group that can be displayed as an OAM */
	
	public class CellOam extends OamTile {
		
		/** The y position of the object, in pixels */
		public var y:int;
		/** The yx position of the object, in pixels */
		public var x:int;
		/** If the object should be hidden */
		public var hide:Boolean;
		/** If the object should be displayed at double size */
		public var doubleSize:Boolean;
		
		/** If the object should be flipped along the X axis when displayed */
		public var xFlip:Boolean;
		/** If the object should be flipped along the Y axis when displayed */
		public var yFlip:Boolean;
		
		public var priority:uint;
		
		public function CellOam() {
			// constructor code
		}
		
		/** Rends the tile group accordingly to the settings
		@param palette The RGB888 palette to use when rendering the tiles
		@param tiles The tiles pixel data to use
		@param useSubImages If sub image addressing should be used
		@param useTransparency If the tiles should be rendered using transparency
		@return A DisplayObject that represents the tile group
		*/
		public override function rend(palette:Vector.<uint>,tiles:GraphicsBank,useSubImages:Boolean,useTranparency:Boolean=true):DisplayObject {
			var oamR:DisplayObject=super.rend(palette,tiles,useSubImages,useTranparency);
				
			oamR.x=x;
			oamR.y=y;
			
			if(xFlip) {
				oamR.x+=width;
				oamR.scaleX=-1;
			}
			
			if(yFlip) {
				oamR.y+=height;
				oamR.scaleY=-1;
			}
			
			return oamR;
		}
		
		/** Draws a rectangle that represents the OAM
		@param boxColor The stroke color for the rectangle
		@param useFill If the rectangle should be filled
		@param tileNumbers If the tile number should be displayed
		@return A DisplayObject that contains the drawn rectangle*/
		public override function drawBox(boxColor:uint=0,useFill:Boolean=true,tileNumbers:Boolean=true):DisplayObject {
			
			var spr:DisplayObject=super.drawBox(boxColor,useFill,tileNumbers);
			spr.x=x;
			spr.y=y;
			
			return spr;
		}
		
		protected override function addTileNumber(spr:Sprite):void {
			var tf:TextField=new TextField();
			tf.autoSize=TextFieldAutoSize.LEFT;
			tf.selectable=false;
			tf.text=String(tileIndex);
			
			if(xFlip) tf.appendText("XF");
			if(yFlip) tf.appendText("YF");
			
			spr.addChild(tf);
		}
		
		public function parse(data:ByteArray,tileIndexShift:uint,sectionNudge:uint):void {
			y=data.readByte();
			var atts0:uint=data.readUnsignedByte();
			
			var rs:Boolean=(atts0 & 1) == 1;
			
			if(rs) {
				doubleSize=(atts0 & 2) ==2;
			} else {
				hide=(atts0 & 2) ==2;
			}
			
			colorDepth=atts0 >> 5 & 0x1;
			
			var shape:uint=atts0 >> 6;
			
			var atts1:uint=data.readUnsignedShort();
			
			x=atts1 & 0x1FF;
			
			if(x>=0x100) {
				x-=0x200;
			}
			
			if(!rs) {
				xFlip=(atts1 & 0x1000)==0x1000;
				yFlip=(atts1 & 0x2000)==0x2000;
			}
			
			var objSize:uint=atts1 >> 14;
			
			var atts2:uint=data.readUnsignedShort();
			
			tileIndex=(atts2 & 0x3FF);
			
			tileIndex <<= tileIndexShift;
			tileIndex += sectionNudge;
			
			paletteIndex= atts2 >> 12;
			
			priority=atts2 >> 10 & 0x3;
			
			setSize(objSize,shape);
		}
		
		public function writeEntry(oamOut:ByteArray,shift:uint):void {
			oamOut.writeByte(y);
			oamOut.writeByte(att0());
			oamOut.writeShort(att1());
			oamOut.writeShort(att2(shift));
		}
		
		private function att0():uint {
			var o:uint=0;
			
			if(doubleSize) {
				o|=0x30;
			} else if(hide) {
				o|=0x20;
			}
			
			o|=colorDepth<<5;
			
			if(width==height) {
				o|=0;
			} else if(width<height) {
				o|=0x80;
			} else if(width>height) {
				o|=0x40;
			} else {
				o|=0xC0;
			}
			
			return o;
		}
		
		private function att1():uint {
			var o:uint=0;
			
			o|=x&0x1FF;
			
			if(xFlip) {
				o|=0x1000;
			}
			if(yFlip) {
				o|=0x2000;
			}
			
			o|=getSize()<<14;
			
			return o;
		}
		
		private function att2(shift:uint):uint {
			var o:uint=0;
			
			var shiftedTileIndex:uint=tileIndex;
			if(shift>0) {
				shiftedTileIndex>>>=shift;
			}
			return shiftedTileIndex | paletteIndex << 12;
		}
		
	}
	
}
