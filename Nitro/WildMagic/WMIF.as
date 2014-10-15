package Nitro.WildMagic {
	import Nitro.Graphics.*;
	import flash.utils.*;
	
	public class WMIF extends GraphicsBank {

		public function WMIF() {
			// constructor code
		}
		
		public function parse(data:ByteArray):void {
			var sig:String=data.readUTFBytes(27);
			if(sig!="Wild Magic Image File 3.00") throw new ArgumentError("Bad signature!");

			data.endian=Endian.LITTLE_ENDIAN;
			
			var type:uint=data.readUnsignedInt();
			
			var pixelsX:uint=data.readUnsignedInt();
			var pixelsY:uint=data.readUnsignedInt();
			
			tilesX=pixelsX/Tile.width;
			tilesY=pixelsY/Tile.height;
			
			switch(type) {
				case 7:
					bitDepth=8;
				break;
				case 6:
					bitDepth=4;
				break;
				case 5:
					bitDepth=2;
				break;
				
				default:
					throw new ArgumentError("Unknown type!");
			}
			
			var size:uint=pixelsX*pixelsY*bitDepth/8;
			
			this.parseScaned(data,data.position,size);
			
			flipImage();
		}
		
		private function flipImage():void {
			var newPicture:Vector.<uint>=new Vector.<uint>(picture.length,true);
			
			const pixelsX:uint=tilesX*Tile.width;
			const pixelsY:uint=tilesY*Tile.height;
			
			for(var y:uint=0;y<pixelsY;++y) {
				var correctY:uint=pixelsY-y-1;
				for(var x:uint=0;x<pixelsX;++x) {
					var color:uint=picture[x+y*pixelsX];
					newPicture[x+correctY*pixelsX]=color;
				}
			}
			picture=newPicture;
		}

	}
	
}
