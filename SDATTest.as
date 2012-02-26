package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	
	import Nitro.FileSystem.*;
	import Nitro.SDAT.*;
	
	import HTools.Audio.*;
	import Nitro.SDAT.InfoRecords.BaseInfoRecord;
	import Nitro.SDAT.InfoRecords.StreamInfoRecord;
	
	
	use namespace strmInternal;
	use namespace sdatInternal;
	
	public class SDATTest extends Sprite {
		
		private var loader:URLLoader;
		
		private var reader:SDAT;
		private var nds:NDS;

		
		public function SDATTest() {
			loader=new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loaded);
			loader.load(new URLRequest("game.nds"));
		}
		
		private function loaded(e:Event):void {
			
			nds=new NDS();
			nds.parse(loader.data);
			
			reader=new SDAT();
			reader.parse(nds.fileSystem.openFileByName("sound_data.sdat"));
			
			//listWaveArchives();
			listStreams();
			streamTest(5,true);
			//swarTest(2,0);
			
		}
		
		private function listWaveArchives():void {
			var i:uint;
			for each(var info:BaseInfoRecord in reader.waveArchiveInfo) {
				var name:String=reader.waveArchiveSymbols[i];
				
				var swar:SWAR=reader.openSWAR(i);
				
				trace(name,swar.waves.length);
				listWaveArchiveContent(swar);
				i++;
			}
		}
		
		private function listWaveArchiveContent(swar:SWAR):void {
			var i:uint;
			for each(var wave:Wave in swar.waves) {
				var o:String="  "+i+" "+Wave.encodingAsString(wave.encoding)+" "+wave.timerLen+" "+wave.loops;
				if(wave.loops) {
					o+=" "+wave.loopStart+" "+wave.nonLoopLength;
				}
				trace(o);
				++i;
			}
		}
		
		private function listStreams():void {
			var i:uint;
			for each(var info:StreamInfoRecord in reader.streamInfo) {
				var name:String=reader.streamSymbols[i];
				var stream:STRM=reader.openSTRM(i);
				trace(i,name,stream.length,stream.channels,stream.loop,stream.loopPoint,stream.dataPos,stream.blockLength,stream.lastBlockSamples,stream.sampleCount);
				i++;
			}
		}
		
		private var streamPlayer:STRMPlayer;
		private function streamTest(streamNumber:uint,dump:Boolean):void {
			var stream:STRM=reader.openSTRM(streamNumber);
			
			trace(stream.dataPos,stream.blockLength,stream.nBlock,stream.blockSamples,stream.channels);
						
			if(dump) {
				dumpWave(stream);
			} else {
				streamPlayer=new STRMPlayer(stream);
				streamPlayer.play();
			}
		}
		
		private var wave:WaveWriter;
		private function dumpWave(stream:STRM):void {
			wave=new WaveWriter(true,32,stream.sampleRate);
			var buff:ByteArray=new ByteArray();
			
			var readSize:uint;
			
			const chunkSize:uint=100;
			const maxSize:uint=stream.sampleCount*2;
			var totalReadSize:uint=0;
			
			var decoder:STRMDecoder=new STRMDecoder(stream);
			
			//decoder.loopAllowed=false;//would get us into an infinite loop. That would be bad.
			
			do {
				buff.position=0;
				buff.length=0;
				readSize=decoder.render(buff,chunkSize);
				
				buff.position=0;
				wave.addSamples(buff);
				
				totalReadSize+=readSize;
			} while(readSize==chunkSize && totalReadSize<maxSize);
			wave.finalize();
			
			stage.addEventListener(MouseEvent.CLICK,saveIt);
		}
		
		private function saveIt(e:MouseEvent):void {
			var fr:FileReference=new FileReference();
			fr.save(wave.outBuffer,"strm.wav");
		}
		
		private var wavePlayer:WavePlayer;
		private function swarTest(swar:uint,sub:uint):void {
			var wave:Wave=reader.openSWAR(swar).waves[sub];
			wavePlayer=new WavePlayer(wave);
			wavePlayer.play();
		}
	}
	
}
