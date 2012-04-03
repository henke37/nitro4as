package  {
	
	import flash.display.MovieClip;
	
	import Nitro.Compression.Stock;
	import flash.utils.*;
	import flash.net.FileReference;
	
	public class CompressionTest extends MovieClip {
		
		[Embed(source="compression examples/img.raw.bin", mimeType="application/octet-stream")]
		private const rawClass:Class;
		
		[Embed(source="compression examples/img.rle.bin", mimeType="application/octet-stream")]
		private const rleClass:Class;
		
		[Embed(source="compression examples/img.lz.bin", mimeType="application/octet-stream")]
		private const lzClass:Class;
		
		[Embed(source="compression examples/img.huf.bin", mimeType="application/octet-stream")]
		private const huffmanClass:Class;
		
		public function CompressionTest() {
			var raw:ByteArray=new rawClass();
			var rle:ByteArray=new rleClass();
			var lz:ByteArray=new lzClass();
			var huffman:ByteArray=new huffmanClass();
			
			var decoded:ByteArray;
			
			try {
				decoded=Stock.decompress(rle);
				
				if(compareByteArrays(raw,decoded)==0) {
					trace("RLE ok");
				} else {
					trace("RLE fail");
				}
			} catch(e:Error) {
				trace(e.getStackTrace());
			}
			
			
			try {
				decoded=Stock.decompress(lz);
				
				if(compareByteArrays(raw,decoded)==0) {
					trace("LZ ok");
				} else {
					trace("LZ fail");
				}
			
			} catch(e:Error) {
				trace(e.getStackTrace());
			}
			
			try {
				huffman.endian=Endian.LITTLE_ENDIAN;
				decoded=Stock.decompress(huffman);
				
				if(compareByteArrays(raw,decoded)==0) {
					trace("Huffman ok");
				} else {
					trace("Huffman fail");
				}
			
			} catch(e:Error) {
				trace(e.getStackTrace());
			}
			
			var originalLen:uint=raw.length;
			raw.position=0;
			raw.compress();
			trace(originalLen-raw.length,raw.length);
		}
		
		private function compareByteArrays(a:ByteArray,b:ByteArray):int {
			if(a.length<b.length) return 1;
			if(a.length>b.length) return -1;
			
			a.position=0;
			b.position=0;
			
			while(a.bytesAvailable>0) {
				var aByte:int=a.readByte();
				var bByte:int=b.readByte();
				if(aByte<bByte) {
					return 1;
				}
				if(aByte>bByte) {
					return -1;
				}
			}
			
			return 0;
		}
	}
	
}
