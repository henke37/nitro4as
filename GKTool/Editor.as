package GKTool {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import Nitro.GK.*;
	import Nitro.*;
	import Nitro.Graphics.*;
	
	public class Editor extends Screen {
		
		private var tileList:Sprite;
		
		private var ncgr:NCGR;
		private var ncer:NCER;
		private var nclr:NCLR, convertedPalette:Vector.<uint>;
		private var archive:GKArchive;
		private var subarchive:GKSubarchive;
		
		private var agregator:OAMCollector;
		
		private var _boxMode:uint=0;
		
		private var canvas:Sprite;
		private var currentCell:Cell;
		
		private var editorOams:Vector.<EditorOam>;
		
		private static const CANVASLEFT:Number=128-16;
		private static const CANVASTOP:Number=16;
		private static const CANVASWIDTH:Number=800-CANVASLEFT;
		private static const CANVASHEIGHT:Number=600-CANVASTOP;
		
		public var boxMode_mc:BoxModeSelector;
		
		private var _selectedOam:EditorOam;
		
		public function Editor() {
			canvas=new Sprite();
			canvas.x=CANVASWIDTH/2+CANVASLEFT;
			canvas.y=CANVASHEIGHT/2+CANVASTOP;
			addChild(canvas);
			
			boxMode_mc.addEventListener(Event.CHANGE,changingBoxMode);
		}
		
		protected override function init():void {
			var archive:GKArchive=new GKArchive();
			archive.parse(gkTool.nds.fileSystem.openFileByName("com/bustup.bin"));
			
			subarchive=new GKSubarchive();
			subarchive.parse(archive.open(102));
			
			nclr=new NCLR();
			nclr.parse(archive.open(101));
			
			convertedPalette=RGB555.paletteFromRGB555(nclr.colors);
			
			ncgr=new NCGR();
			ncgr.parse(subarchive.open(2));
			
			ncer=new NCER();
			ncer.parse(subarchive.open(0));
			
			agregator=new OAMCollector();
			agregator.loadOams(ncer);
			
			buildTileList();
			
			loadCellFromCell(ncer.cells[0]);
		}
		
		private function changingBoxMode(e:Event):void {
			boxMode=boxMode_mc.value;
			flagRender();
		}
		
		private function set boxMode(m:uint):void {
			_boxMode=m;
		}
		
		private function loadCellFromCell(cell:Cell):void {
			currentCell=cell;
			
			editorOams=new Vector.<EditorOam>();
			editorOams.length=cell.oams.length;
			
			var i:uint=0;
			
			for each(var original:CellOam in cell.oams) {
				editorOams[i++]=EditorOam.spawnFromTemplate(original);
			}
			
			flagRender();
		}
		
		private function writeToCell(cell:Cell):void {
			throw new Error("not implemented");
		}
		
		private function buildTileList():void {
			const lineWidth:uint=128;
			var xPos:Number=0,yPos:Number=0,currentLineHeight:Number=0;
			
			tileList=new Sprite();
			addChild(tileList);
			
			for each(var tile:OamTile in agregator.oams) {
				var rend:DisplayObject=ncgr.renderOam(tile,convertedPalette,ncer.subImages);
				if(rend.width+xPos>lineWidth) {
					xPos=0;
					yPos+=currentLineHeight;
					currentLineHeight=0;
				}
				
				rend.x=xPos;
				rend.y=yPos;
				
				tileList.addChild(rend);
				
				xPos+=rend.width;
				if(currentLineHeight<rend.height) currentLineHeight=rend.height;
			}
			
			
		}
		
		private function flagRender():void {
			if(stage) {
				addEventListener(Event.RENDER,render);
				stage.invalidate();
			} else {
				addEventListener(Event.ADDED_TO_STAGE,render);
			}
		}
		
		private function render(e:Event=null):void {
			
			removeEventListener(Event.RENDER,render);
			removeEventListener(Event.ADDED_TO_STAGE,render);
			
			while(canvas.numChildren) canvas.removeChildAt(canvas.numChildren-1);
			
			for each(var oam:EditorOam in editorOams) {
			
				var rendering:EditorRendering=oam.rendering;
				
				while(rendering.numChildren) rendering.removeChildAt(rendering.numChildren-1);
				
				switch(_boxMode) {
					case 0:
						rendering.addChild(oam.rend(convertedPalette,ncgr,ncer.subImages));
					break;
					
					case 1:
						rendering.addChild(oam.drawBox(0,true));
					break;
					
					case 2:
						rendering.addChild(oam.rend(convertedPalette,ncgr,ncer.subImages));
						rendering.addChild(oam.drawBox(0,false));
					break;
				}
				
				rendering.addEventListener(MouseEvent.MOUSE_DOWN,downOnRender);
				
				if(_selectedOam) {
					rendering.addChild(_selectedOam.drawBox(0x0000FF,false,false));
				}
														
				
				canvas.addChild(rendering);
			}
		}
		
		private function downOnRender(e:MouseEvent):void {
			selectedOam=EditorRendering(e.currentTarget).oam;
		}
		
		private function set selectedOam(s:EditorOam):void {
			_selectedOam=s;
			flagRender();
		}
	}
	
}

