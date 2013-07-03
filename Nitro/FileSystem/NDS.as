package Nitro.FileSystem {
	
	import flash.utils.*;
	import Nitro.*;
	import Nitro.Compression.*;
	
	/** A NDS file
	
	<p>The NDS file contains a full game in one file.</p> */
	
	public class NDS {
		
		/** The game title */
		public var gameName:String;
		
		/** Four character long code that names the game. */
		public var gameCode:String;
		
		/** An ASCII encoded number that maps to the maker of the game. */
		public var makerCode:String;
		
		public var cardSize:uint;
		
		/** The position of the ARM9 executable in ROM */
		public var arm9Offset:uint;
		/** The position in memory where the ARM9 executable will be loaded before execution. */
		public var arm9LoadBase:uint;
		/** The entrypoint for the ARM9 executable. */
		public var arm9ExecuteStart:uint;
		/** The length of the ARM9 executable*/
		public var arm9Len:uint;
		
		/** The position of the ARM7 executable in ROM */
		public var arm7Offset:uint;
		/** The position in memory where the ARM7 executable will be loaded before execution. */
		public var arm7LoadBase:uint;
		/** The entrypoint for the ARM7 executable. */
		public var arm7ExecuteStart:uint;
		/** The length of the ARM7 executable*/
		public var arm7Len:uint;
		
		/** The overlays for the ARM9 */
		public var arm9Overlays:Vector.<Overlay>;
		/** The overlays for the ARM7 */
		public var arm7Overlays:Vector.<Overlay>;
		
		private var nds:ByteArray;
		
		/** The embeded filesystem. */
		public var fileSystem:FileSystem;
		
		/** The banner data for the game. */
		public var banner:Banner;

		public function NDS() {
			
		}
		
		/** Loads a NDS file from a ByteArray
		@param nds The ByteArray to load from*/
		public function parse(nds:ByteArray):void {
			this.nds=nds;
			
			nds.endian=Endian.LITTLE_ENDIAN;
			
			gameName=nds.readUTFBytes(12);
			gameCode=nds.readUTFBytes(4);
			
			makerCode=nds.readUTFBytes(2);
			
			nds.position+=1;//unit code
			nds.position+=1;//device code
			
			cardSize=2<<(nds.readUnsignedByte()+20);
			
			nds.position+=9;//card info
			
			var romVersion:uint=nds.readUnsignedByte();
			
			var flags:uint=nds.readUnsignedByte();
			
			arm9Offset=nds.readUnsignedInt();
			arm9ExecuteStart=nds.readUnsignedInt();
			arm9LoadBase=nds.readUnsignedInt();
			arm9Len=nds.readUnsignedInt();
			
			arm7Offset=nds.readUnsignedInt();
			arm7ExecuteStart=nds.readUnsignedInt();
			arm7LoadBase=nds.readUnsignedInt();
			arm7Len=nds.readUnsignedInt();
			
			var fileNameTablePos:uint=nds.readUnsignedInt();
			var fileNameTableSize:uint=nds.readUnsignedInt();
			
			var fileAllocationTablePos:uint=nds.readUnsignedInt();
			var fileAllocationTableSize:uint=nds.readUnsignedInt();
			
			//nds.position+=4*4;//overlays
			var arm9OverlayOffset:uint=nds.readUnsignedInt();
			var arm9OverlaySize:uint=nds.readUnsignedInt();
			var arm7OverlayOffset:uint=nds.readUnsignedInt();
			var arm7OverlaySize:uint=nds.readUnsignedInt();
			
			nds.position+=4*2;//flash chip timing controll data
			
			var bannerOffset:uint=nds.readUnsignedInt();
			
			var romCRC:uint=nds.readUnsignedShort();
			
			nds.position+=2;//rom timeout
			
			nds.position+=4*2;//unknown arm offsets
			
			nds.position+=8;//magic for unencrypted mode
			
			nds.position+=4*2;//romsize and header size
			
			nds.position+=56;//plain old unknown/reservated/padding
			
			nds.position+=156;//gba logo
			
			var logoCRC:uint=nds.readUnsignedShort();
			var headerCRC:uint=nds.readUnsignedShort();
			var calcCRC:uint=crc16(nds,0,0x15D);
			if(calcCRC!=headerCRC) throw new ArgumentError("Header CRC fail. Expected 0x"+headerCRC.toString(16)+" got 0x"+calcCRC+"!");
			
			if(bannerOffset) {
				try {
					banner=new Banner();
					banner.parse(nds,bannerOffset);
				} catch (err:Error) {
					banner=null;
				}
			}
			
			fileSystem=new FileSystem();
			fileSystem.parse(nds,fileNameTablePos,fileNameTableSize,fileAllocationTablePos,fileAllocationTableSize);
			
			arm9Overlays=readOVT(arm9OverlayOffset,arm9OverlaySize);
			arm7Overlays=readOVT(arm7OverlayOffset,arm7OverlaySize);
		}
		
		/** The ARM9 executable */
		public function get arm9Executable():ByteArray {
			var o:ByteArray=new ByteArray();
			o.writeBytes(nds,arm9Offset,arm9Len);
			return o;
		}
		
		/** The ARM7 executable */
		public function get arm7Executable():ByteArray {
			var o:ByteArray=new ByteArray();
			o.writeBytes(nds,arm7Offset,arm7Len);
			return o;
		}
		
		/** Reads an overlay
		@param cpu The cpu the overlay is for, either 7 or 9.
		@param id The id of the overlay to read
		@return A new ByteArray containing the plaintext contents of the overlay
		*/
		public function openOverlayById(cpu:uint,id:uint):ByteArray {
			if(cpu!=9 && cpu!=7) throw new ArgumentError("CPU has to be either 7 or 9!");
			
			var overlay:Overlay=findOverlay(cpu,id);
			return openOverlayByReference(overlay);
		}
		
		/** Reads an overlay
		@param overlay The overlay to read
		@return A new ByteArray containing the plaintext contents of the overlay
		*/
		public function openOverlayByReference(overlay:Overlay):ByteArray {
			if(!overlay) throw new ArgumentError("No overlay with that id!");
			
			var rawData:ByteArray=fileSystem.openFileById(overlay.fileId);
			rawData.endian=Endian.LITTLE_ENDIAN;
			
			if(overlay.compressed) {
				rawData=ReverseLZ.unpack(rawData);
				rawData.endian=Endian.LITTLE_ENDIAN;
			}
			
			rawData.position=0;
			
			return rawData;
		}
		
		/** Finds an overlay entry by id
		@param cpu The cpu the overlay is for, either 7 or 9.
		@param id The id of the overlay to read
		@return The overlay entry for the given id, or null if not found
		*/
		public function findOverlay(cpu:uint,id:uint):Overlay {
			var list:Vector.<Overlay>;
			
			if(cpu==9) {
				list=arm9Overlays;
			} else if(cpu==7) {
				list=arm7Overlays;
			} else {
				throw new ArgumentError("CPU has to be either 7 or 9!");
			}
			
			if(!list) return null;//the cpu might not even have overlays at all!
			
			for each(var overlay:Overlay in list) {
				if(overlay.id==id) {
					return overlay;
				}
			}
			
			return null;
		}
		
		private function readOVT(offset:uint,size:uint):Vector.<Overlay> {
			
			if(offset==0) return null;
			
			const entrySize:uint=32;
			
			var o:Vector.<Overlay>=new Vector.<Overlay>();
			
			nds.position=offset;
			
			for(var i:uint=0;i<size;i+=entrySize) {
				var overlay:Overlay=new Overlay();
				overlay.id=nds.readUnsignedInt();
				overlay.ramAddress=nds.readUnsignedInt();
				overlay.ramSize=nds.readUnsignedInt();
				overlay.bssSize=nds.readUnsignedInt();
				overlay.bssStart=nds.readUnsignedInt();
				overlay.bssStop=nds.readUnsignedInt();
				overlay.fileId=nds.readUnsignedInt();
				
				var flags:uint=nds.readUnsignedInt();
				overlay.compressed=Boolean(flags & 0x1000000);
				//if(overlay.compressed) {
					overlay.size=flags & 0xFFFFFF;
				//} else {
					//overlay.size=overlay.ramSize;
				//}
				
				o.push(overlay);
			}
			
			o.fixed=true;
			return o;
		}

	}
	
}
