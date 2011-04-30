package GKTool {
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import com.adobe.images.*;
	
	import Nitro.GK.*;
	import Nitro.FileSystem.*;
	import Nitro.Graphics.*;
	
	public class GraphicsExtractScreen extends ExtractBaseScreen {
		
		private static const PRE_PAL_AND_SUB:uint=1;
		private static const POST_PAL_AND_SUB:uint=2;
		private static const POST_PAL_NO_SUB:uint=3;

		public function GraphicsExtractScreen() {
			// constructor code
		}
		
		var queue:Vector.<QueueEntry>;
		var queueEntry:QueueEntry;
		var queuePosition:uint;
		var archive:GKArchive;
		var archivePosition:uint;
		
		var palette:NCLR;
		var cells:NCER;
		var tiles:NCGR;
		
		var cellItr:uint;
		var inSubArchive:Boolean=false;
		
		var fileName:String;
		
		protected override function beginExtraction():uint {
			queue=new Vector.<QueueEntry>();
			
			queue.push(new QueueEntry("com/bustup.bin",PRE_PAL_AND_SUB));
			//queue.push(new QueueEntry("com/mapchar.bin",PRE_PAL_AND_SUB));
			
			var estimate:uint=0;
			
			for each(queueEntry in queue) {
				queueEntry.archive=new GKArchive();
				queueEntry.archive.parse(gkTool.nds.fileSystem.openFileByName(queueEntry.file));
				estimate+=queueEntry.archive.length;
			}
			
			
			return estimate;
		}
		
		protected override function processNext():Boolean {
			if(!archive) {
				queueEntry=queue[queuePosition++];
				archive=queueEntry.archive;
				archivePosition=0;
			}
			
			var contents:ByteArray=archive.open(archivePosition);
			
			fileName=queueEntry.file+"/"+archivePosition;
			
			var type:String=sniffExtension(contents,fileName);
			
			contents.position=0;
			
			if(fileName=="com/bustup.bin/112") {
				log("Skipping special palette #"+archivePosition);
			} else if(inSubArchive) {
				nextCell();
				
				if(inSubArchive) return true;
				
			} else if(type=="nclr") {
				loadPalette(contents);
				log("loaded palette \""+fileName+"\".");
			} else if(type=="subarchive") {
				
				if(fileName=="com/bustup.bin/122") {
					loadPalette(archive.open(112));
					log("loaded special palette # 112");
				}
				
				var subArchive:GKSubarchive=new GKSubarchive();
				subArchive.parse(contents);
				
				tiles=new NCGR();
				tiles.parse(subArchive.open(2));
				
				cells=new NCER();
				cells.parse(subArchive.open(0));
				log("extracting cells from subarchive \""+fileName+"\".");
				
				cellItr=0;
				
				nextCell();
				
				if(inSubArchive) return true;
			}
			
			
			++archivePosition;
			++progress;
			
			if(archivePosition>=archive.length) {
				if(queuePosition>=queue.length) {
					return false;
				}
				
				archive=null;
			}
			
			return true;
		}
		
		private function loadPalette(contents:ByteArray):void {
			palette=new NCLR();
			palette.parse(contents);
		}
		
		private function nextCell():void {
			var cellR:DisplayObject=cells.rend(cellItr,palette,tiles);
			
			if(cellR.width==0 || cellR.height==0) {
				log("Skipping cell # "+cellItr+" since it is empty");
			} else {
				saveBitmap(fileName+"/"+cellItr+".png",cellR);
				
				log("Extracted cell # "+cellItr);
			}
			
			++cellItr;
			
			inSubArchive=cellItr<cells.length;
		}
		
		private function saveBitmap(name:String,obj:DisplayObject):void {			
			var bounds:Rectangle=obj.getBounds(obj);
			
			var rendMatrix:Matrix=new Matrix();
			rendMatrix.identity();
			rendMatrix.translate(bounds.left,bounds.top);
			rendMatrix.invert();
			
			var bmd:BitmapData=new BitmapData(bounds.width,bounds.height,true,0x00FF4000);
			bmd.lock();
			
			bmd.draw(obj,rendMatrix);
			
			var png:ByteArray=PNGEncoder.encode(bmd);
			
			saveFile(name,png);
		}

	}
	
}
import Nitro.GK.GKArchive;

class QueueEntry {
	public var file:String;
	public var mode:uint;
	public var archive:GKArchive;
	
	public function QueueEntry(f:String,m:uint) {
		file=f;
		mode=m;
	}
}
