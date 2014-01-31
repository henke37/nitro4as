package Nitro.FileSystem {
	
	/** Resolves virtual address space for an executable image */
	public class Mapper {
		
		private var nds:NDS;
		
		private var mappings:Vector.<Mapping>;

		/** Creates a new Mapper
		@param nds The executable image to resolve for */
		public function Mapper(nds:NDS) {
			if(!nds) throw new ArgumentError("nds can't be null!");
			this.nds=nds;
			
			mappings=new Vector.<Mapping>();
			
			mappings[0]=new ExecutableMapping(nds,9);
			mappings[1]=new ExecutableMapping(nds,7);
		}
		
		public function isMapped(start:uint,length:uint=1):Boolean {
			try {
				var mapping:Mapping=findMapping(start,length);
				if(!mapping) return false;
			} catch(err:RangeError) {
				return false;
			}
			
			return true;
		}
		
		public function findMapping(start:uint,length:uint=1):Mapping {
			for each(var mapping:Mapping in mappings) {
				if(mapping.matches(start,length)) {
					return mapping;
				}
			}
			return null;
		}

	}
	
}
import flash.utils.*;
import Nitro.FileSystem.NDS;
import Nitro.Compression.ReverseLZ;

class Mapping {
	public var start:uint;
	public var length:uint;
	
	public function read(addr:uint,readLen:uint):ByteArray {
		if(!matches(addr,readLen)) throw new RangeError("Can't read from non covererd memory area!");
		return localRead(addr-start,readLen);
	}
	
	public function matches(addr:uint,len:uint):Boolean {
		if(addr<start) return false;
		if(addr+len>start+length) return false;
		return true;
	}
	
	protected function localRead(offset:uint,readLen:uint):ByteArray { return null; }
}

class ExecutableMapping extends Mapping {
	private var nds:NDS;
	
	private var executable:ByteArray;
	
	public function ExecutableMapping(nds:NDS,arm:uint) {
		this.nds=nds;
		
		if(arm==7) {
			executable=nds.arm7Executable;
			start=nds.arm7LoadBase;
		} else if(arm==9) {
			executable=nds.arm9Executable;
			start=nds.arm9LoadBase;
		} else {
			throw new ArgumentError("Must be for either 7 or 9!");
		}
		
		executable.endian=Endian.LITTLE_ENDIAN;
		executable=ReverseLZ.unpack(executable);
		length=executable.length;
	}
	
	protected override function localRead(offset:uint,readLen:uint):ByteArray {
		var ba:ByteArray=new ByteArray();
		executable.position=offset;
		executable.readBytes(ba,0,readLen);
		return ba;
	}
}

class BssMapping extends Mapping {
	protected override function localRead(offset:uint,readLen:uint):ByteArray {
		var ba:ByteArray=new ByteArray();
		ba.length=readLen;
		return ba;
	}
}
