package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	public class OamProperties extends Sprite {
		
		public var xFlip_mc:ToggleButton;
		public var yFlip_mc:ToggleButton;
		
		public var x_txt:TextField;
		public var y_txt:TextField;
		public var palette_txt:TextField;
		public var tile_txt:TextField;
		
		public function OamProperties() {
			xFlip_mc.addEventListener(Event.CHANGE,setXFlip);
			yFlip_mc.addEventListener(Event.CHANGE,setYFlip);
			
			x_txt.addEventListener(Event.CHANGE,setX);
			x_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			y_txt.addEventListener(Event.CHANGE,setY);
			y_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			tile_txt.addEventListener(Event.CHANGE,setTile);
			tile_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
			palette_txt.addEventListener(Event.CHANGE,setPalette);
			palette_txt.addEventListener(FocusEvent.FOCUS_OUT,numberFocusLost);
		}
		
		private function numberFocusLost(e:FocusEvent):void {
			if(e.currentTarget.text=="") {
				e.currentTarget.text="0";
			}
		}
		
		private function setXFlip(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			oam.xFlip=xFlip_mc.selected;
			editor.flagRender();
		}
		
		private function setYFlip(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			oam.yFlip=yFlip_mc.selected;
			editor.flagRender();
		}
		
		private function setX(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			oam.x=parseInt(x_txt.text);
			editor.flagRender();
		}
		
		private function setY(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			oam.y=parseInt(y_txt.text);
			editor.flagRender();
		}
		
		private function setTile(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			oam.tileIndex=parseInt(tile_txt.text);
			editor.flagRender();
		}
		
		private function setPalette(e:Event):void {
			var oam:EditorOam=editor._selectedOam;
			oam.paletteIndex=parseInt(palette_txt.text);
			editor.flagRender();
		}
		
		internal function update():void {
			
			var oam:EditorOam=editor._selectedOam;
			
			xFlip_mc.selected=oam.xFlip;
			yFlip_mc.selected=oam.yFlip;
			x_txt.text=String(oam.x);
			y_txt.text=String(oam.y);
			tile_txt.text=String(oam.tileIndex);
			palette_txt.text=String(oam.paletteIndex);
		}
		
		private function get editor():Editor { return Editor(parent); }
	}
	
}
