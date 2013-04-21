package Nitro.GhostTrick {
	import flash.utils.*;
	
	import Nitro.Graphics.*;
	
	public class CellBank {
		
		public var cells:Vector.<Cell>;

		public function CellBank() {
			// constructor code
		}
		
		public function parse(data:ByteArray,cellCount:uint):void {
			data.endian=Endian.LITTLE_ENDIAN;
			
			var cellStarts:Vector.<uint>=new Vector.<uint>(cellCount,true);
			cells=new Vector.<Cell>(cellCount,true);
			
			for(var cellItr:uint=0;cellItr<cellCount;++cellItr) {
				var cellStart:uint=data.readUnsignedShort()*2;
				cellStarts[cellItr]=cellStart;
			}
			
			for(cellItr=0;cellItr<cellCount;++cellItr) {
				cellStart=cellStarts[cellItr];
				data.position=cellStart;
				var cellLength:uint=data.readUnsignedShort();
				var cell:Cell=new Cell();
				cell.oams=new Vector.<CellOam>(cellLength,true);
				
				for(var objItr:uint=0;objItr<cellLength;++objItr) {
					var obj:CellOam=new CellOam();
					obj.parse(data,2,0);
					cell.oams[objItr]=obj;
				}
				
				cells[cellItr]=cell;
			}
		}
		
		

	}
	
}
