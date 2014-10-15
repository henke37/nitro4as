package Nitro.Animation {
	
	import Nitro.*;
	
	import flash.utils.*;
	import flash.geom.*;
	
	/**
	NANR file parser and writer.
	
	<p>NANR files are animation instructions and depend on a NCER file for the cells to show during the animation.</p>
	*/
	
	public class NANR {
		
		/** The animations in the file. */
		public var anims:Vector.<NANRAnim>;
		
		private static const animSize:uint=16;
		private static const frameSize:uint=8;

		public function NANR() {
			// constructor code
		}
		
		/** Loads an existing file.
		@param data The file to load. */
		public function parse(data:ByteArray):void {
			
			var sections:SectionedFile=new SectionedFile();
			sections.parse(data);
			
			if(sections.id!="RNAN") throw new ArgumentError("Incorrect file header, type is "+sections.id);
			
			var section:ByteArray=sections.open("KNBA");
			
			section.endian=Endian.LITTLE_ENDIAN;
			
			const animCount:uint=section.readUnsignedShort();
			const totalFrames:uint=section.readUnsignedShort();
			
			const animOffset:uint=section.readUnsignedInt();
			const frameBaseOffset:uint=section.readUnsignedInt();
			const positionBaseOffset:uint=section.readUnsignedInt();
			
			anims=new Vector.<NANRAnim>();
			
			var positionCache:Object={}
			
			for(var animIttr:uint=0;animIttr<animCount;++animIttr) {
				
				section.position=animOffset+animIttr*animSize;
				var anim:NANRAnim=new NANRAnim();
				var frameCount:uint=section.readUnsignedShort();
				anim.loopStart=section.readUnsignedShort();
				var dataType:uint=section.readUnsignedInt();
				anim.playbackMethod=section.readUnsignedInt();
				
				var positionSize:uint=[4,16,8][dataType];
				
				anim.frames=new Vector.<NANRFrame>();
				anim.frames.length=frameCount;
				anim.frames.fixed=true;
				
				var frameOffset:uint=section.readUnsignedInt();
				
				
				for(var frameIttr:uint=0;frameIttr<frameCount;++frameIttr) {
					
					section.position=frameBaseOffset+frameOffset+frameIttr*frameSize;
					
					var frame:NANRFrame=new NANRFrame();
					
					var positionOffset:uint=section.readUnsignedInt();
					
					frame.frameTime=section.readUnsignedShort();
					
					if(positionOffset in positionCache) {
						frame.position=positionCache[positionOffset];
					} else {
						
						section.position=positionBaseOffset+positionOffset;
						
						var position:NANRPosition=new NANRPosition;
						
						position.transform=new Matrix();
						position.transform.identity();
						
						position.cellIndex=section.readUnsignedShort();
						
						switch(dataType) {
							case 0:
							break;
							
							case 1:
							break;
							
							case 2:
								section.position+=2;
								position.transform.tx=section.readShort();
								position.transform.ty=section.readShort();
							break;
						}
						
						frame.position=position;
						positionCache[positionOffset]=position;
					}
					
					anim.frames[frameIttr]=frame;
				}
				anims[animIttr]=anim;
			}
			
		}
		
		/** Outputs the content of the NANR as XML.
		@return The XML for the NANR */
		public function toXML():XML {
			var root:XML=<animations />;
			
			for each(var animation:NANRAnim in anims) {
				var animXML:XML=<animation />;
				
				for each(var frame:NANRFrame in animation.frames) {
					var frameXML:XML=<frame time={frame.frameTime} cell={frame.position.cellIndex} />;
					animXML.appendChild(frameXML);
				}
				
				root.appendChild(animXML);
			}
			
			return root;
		}

	}
	
}