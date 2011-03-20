package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import SDAT.*;
	import HTools.WaveWriter;
	import flash.net.FileReference;
	
	use namespace strmInternal;
	use namespace sdatInternal;
	
	public class SDATTest extends Sprite {
		
		[Embed(source="sound_data.sdat", mimeType="application/octet-stream")]
		private var sdatClass:Class;
		
		private var reader:SDATReader;

		
		public function SDATTest() {
			reader=new SDATReader(new sdatClass());
			
			//listWaveArchives();
			listStreams();
			streamTest(3);
			//swarTest(2,0);
			
		}
		
		private function listWaveArchives():void {
			var i:uint;
			for each(var swar:SWAR in reader.waveArchives) {
				var name:String=reader.waveArchiveSymbols[i];
				trace(name,swar.waves.length);
				listWaveArchiveContent(swar);
				i++;
			}
		}
		
		private function listWaveArchiveContent(swar:SWAR):void {
			var i:uint;
			for each(var wave:Wave in swar.waves) {
				var o:String="  "+i+" "+Wave.encodingAsString(wave.encoding)+" "+wave.duration+" "+wave.loops;
				if(wave.loops) {
					o+=" "+wave.loopStart+" "+wave.loopLength;
				}
				trace(o);
				++i;
			}
		}
		
		private function listStreams():void {
			var i:uint;
			for each(var stream:STRM in reader.streams) {
				var name:String=reader.streamSymbols[i];
				trace(i,name,stream.length,stream.channels,stream.loop,stream.dataPos);
				i++;
			}
		}
		
		var streamPlayer:STRMPlayer;
		private function streamTest(streamNumber:uint):void {
				
			var strmData:ByteArray;
			var stream:STRM;
			
			/*for(var i:uint;i<reader.streams.length;++i) {
				stream=reader.streams[i];
				trace(reader.streamSymbols[i],stream.length,stream.encoding);
			}*/
			
			
			stream=reader.streams[streamNumber];
			
			trace(stream.dataPos,stream.blockLength,stream.nBlock,stream.blockSamples,stream.channels);
			//reader.sdat.position=stream.dataPos;
			
			//strmData=new ByteArray();
			//strmData.writeBytes(reader.sdat,stream.dataPos,stream.blockLength*stream.nBlock);
			
			streamPlayer=new STRMPlayer(stream);
			
			dumpWave(streamPlayer);
			//streamPlayer.play();
		}
		
		var wave:WaveWriter;
		private function dumpWave(player:STRMPlayer):void {
			wave=new WaveWriter(true,32,player.stream.sampleRate);
			var buff:ByteArray=new ByteArray();
			
			var readSize:uint;
			
			do {
				buff.position=0;
				readSize=player.render(buff,8000);
				buff.position=0;
				wave.addSamples(buff);
			} while(readSize==8000);
			wave.finalize();
			
			stage.addEventListener(MouseEvent.CLICK,saveIt);
		}
		
		private function saveIt(e:MouseEvent):void {
			var fr:FileReference=new FileReference();
			fr.save(wave.outBuffer,"strm.wav");
		}
		
		var wavePlayer:WavePlayer;
		private function swarTest(swar:uint,sub:uint) {
			var wave:Wave=reader.waveArchives[swar].waves[sub];
			wavePlayer=new WavePlayer(wave);
			wavePlayer.play();
		}
	}
	
}
