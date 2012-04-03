package Nitro.Compression {
	import flash.utils.*;
	
	public function huffmanDecode(inBuff:ByteArray,length:uint,dataSize:uint):ByteArray {
		var outBuff:ByteArray=new ByteArray();
		
		var dataStart:uint=inBuff.position;
		
		var treeSize:uint=inBuff.readUnsignedByte();
		treeSize=(treeSize+1)*2;
		
		var rootNode:HuffmanTreeNode=HuffmanTreeNode.readHuffmanTree(inBuff,dataStart+1);
		
		var bitStream:ByteArrayBitStream=new ByteArrayBitStream(inBuff);
		
		inBuff.position=dataStart+treeSize;
		
		while(outBuff.length<length) {
			var currentNode:HuffmanTreeNode=rootNode;
			
			while(!currentNode.isDataNode) {
				if(bitStream.readBit()) {
					currentNode=currentNode.rightNode;
				} else {
					currentNode=currentNode.leftNode;
				}
			}
			outBuff.writeByte(currentNode.data);
		}
		
		outBuff.position=0;
		return outBuff;
	}
	
	
}
import flash.utils.ByteArray;

class HuffmanTreeNode {
	public var leftNode:HuffmanTreeNode;
	public var rightNode:HuffmanTreeNode;
	
	public var data:uint;
	
	public function get isDataNode():Boolean {
		return !leftNode && !rightNode;
	}
	
	static private function newDataNode(data:uint):HuffmanTreeNode {
		var n:HuffmanTreeNode=new HuffmanTreeNode();
		n.data=data;
		return n;
	}
	
	static public function readHuffmanTree(inBuff:ByteArray, startPos:uint):HuffmanTreeNode {
		inBuff.position=startPos;
		
		var flags:uint=inBuff.readUnsignedByte();
		var leftIsData:Boolean=Boolean(flags & 0x80);
		var rightIsData:Boolean=Boolean(flags & 0x40);
		var depth:uint=flags & 0x1F;
		
		var childStartOffset:uint=(startPos & ~1)+depth*2+2;
		
		var parent:HuffmanTreeNode=new HuffmanTreeNode();
		
		if(leftIsData) {
			inBuff.position=childStartOffset;
			parent.leftNode=newDataNode(inBuff.readUnsignedByte());
		} else {
			parent.leftNode=readHuffmanTree(inBuff,childStartOffset);
		}
		
		if(rightIsData) {
			inBuff.position=childStartOffset+1;
			parent.rightNode=newDataNode(inBuff.readUnsignedByte());
		} else {
			parent.rightNode=readHuffmanTree(inBuff,childStartOffset+1);
		}
		
		return parent;
	}
}

class ByteArrayBitStream {
		
	public var ba:ByteArray;
	
	private var bytePos:uint;
	private var bitsLeft:uint;
	private var bits:uint;

	public function ByteArrayBitStream(ba:ByteArray) {
		this.ba=ba;
	}
	
	public function readBit():Boolean {
		if(bitsLeft==0) {
			bitsLeft=32;
			bits=ba.readUnsignedInt();
		}
		
		var bit:Boolean=Boolean(bits & 0x80000000);
		bits<<=1;
		bitsLeft--;
		
		return bit;
	}

}


