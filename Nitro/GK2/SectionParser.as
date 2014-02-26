package Nitro.GK2 {
	
	import flash.utils.*;
	
	public class SectionParser {
		
		private var section:ByteArray;
		
		public static var unknownCommands:Object={};

		public function SectionParser(section:ByteArray) {
			this.section=section;
		}
		
		public function parse():XML {
			
			var o:XML=<scriptSection/>;
			
			parseLoop: while(section.position<section.length) {
				var word:uint=section.readUnsignedShort();
				
				var type:uint=word >> 8;
				
				var toAppend:*;
				var lastCommand:XML;
				
				switch(type) {
					case 0x00:
					case 0x01:
						if(word==0x000A) {
							toAppend=<br/>;
						} else {
							toAppend=<unknown data={word.toString(16)} />;
						}
					break;
					
					case 0xE0:
					case 0xE1:
					case 0xE2:
					case 0xE3:
					case 0xE4:
					case 0xE5:
					case 0xE6:
					case 0xE7:
					case 0xE8:
					case 0xE9:
					case 0xEA:
					case 0xEB:
					case 0xEC:
					case 0xED:
					case 0xEE:
					case 0xEF:
					case 0xF0:
					case 0xF1:
					case 0xF2:
					case 0xF3:
					case 0xF4:
					case 0xF5:
					case 0xF6:
					case 0xF7:
					case 0xF8:
						toAppend=parseCommand(word);
					break;
					
					default:
						var text:String=String.fromCharCode(word);
						toAppend=text;
					break;
				}
				
				if(lastCommand) {
					o.insertChildAfter(lastCommand,toAppend);
					lastCommand=null;
				} else {
					o.appendChild(toAppend);
				}
				
				lastCommand=toAppend as XML;
				//trace(word.toString(16));
			}
			
			o.normalize();
			
			return o;
		}
		
		private function parseCommand(commandType:uint):XML {			
			
			switch(commandType) {
				
				
				
				case 0xE040: return <whiteText/>;
				case 0xE041: return <orangeText command="0xE041"/>;
				case 0xE042: return <blueText/>;
				case 0xE043: return <greenText command="0xE043"/>;
				case 0xE04C: return <greenText command="0xE04C"/>;
				case 0xE04D: return <orangeText command="0xE04D"/>;

				case 0xE080:
					return <callSection section={section.readUnsignedShort()} />;
				break;
				
				case 0xE081:
					return <jumpToSection section={section.readUnsignedShort()} />;
				break;
					
				case 0xE0B0://random branch
					return commandE0B0();
				break;
				
				case 0xE091:
					return <videoAnalysisHotspot
						a={section.readUnsignedShort()}
						b={section.readUnsignedShort()}
						c={section.readUnsignedShort()}
						section={section.readUnsignedShort()}
					/>;
				break;
				
				case 0xE100:
					switch(section.readShort()) {
						case 0:
							return <showTextWindow />;
						break;
						
						case 1:
							return <hideTextWindow />;
						break;
						
						default:
							return <unknownCommand commandType={commandType.toString(16)}  />;
						break;
					}
				break;
					
				case 0xE101:
					return speakerBadge();
				break;
				
				case 0xE102: return <ack/>;
				
				case 0xE104: return <clear/>;
				
				case 0xE106: return <fullscreenAck />;
				
				case 0xE107:
					return <textSpeed speed={section.readShort()} />;
				break;
				
				case 0xE108:
					return <wait time={section.readShort()} />;
				break;
					
				case 0xE10D:
					return commandE10D();
				break;
				
				case 0xE10E:
					return <waitForSceneChange />;
				break;
				
				case 0xE10F:
					return <endBustDisplay a={section.readShort()} b={section.readShort()} />;
				break;
				
				case 0xE110:
					return <beginBustDisplay a={section.readShort()} b={section.readShort()} />;
				break;
				
				case 0xE111:
					return <addCharacter
						char={section.readShort()}
						b={section.readShort()}
						c={section.readShort()}
						d={section.readShort()}
						e={section.readShort()}
						f={section.readShort()}
					/>;
				
				case 0xE112:
					return <waitForCharTween char={section.readShort()} />;
				break;
				
				case 0xE113:
					return <fadeChar char={section.readShort()} b={section.readShort()} c={section.readShort()} />;
				break;

				case 0xE114:
					return <addMini char={section.readShort()} b={section.readShort()} x={section.readShort()} y={section.readShort()} e={section.readShort()} />;
				break;
					
				case 0xE115:
					return <removeMini char={section.readShort()} />;
				break;
				
				case 0xE118:
					return <fullscreenImage a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE119:
					return <panFullscreenImage a={section.readShort()} b={section.readShort()} />;
				break;
					
				
				case 0xE11B:
					return <checkForPresent evidence={section.readShort()} section={section.readShort()} />;
				break;
				
				case 0xE11E:
					return <ceDefStart />;
				break;
				
				case 0xE11F:
					return <ceStatement
						index={section.readShort()}
						statementSection={section.readShort()}
						pressSection={section.readShort()}
						presentSection={section.readShort()}
						startHidden={section.readShort()}
					/>;
				break;
				
				case 0xE120:
					return <ceAid index={section.readShort()} section={section.readShort()} />;
				break;
					
				case 0xE121:
					return <beginCrossExam />;
				break;
				
				
					
				case 0xE122:
					return <tweenChar char={section.readShort()} b={section.readShort()} c={section.readShort()} />;
				break;
					
				case 0xE123:
					return <panToCharacter char={section.readShort()} b={section.readShort()} c={section.readShort()} d={section.readShort()} command="0xE123" />;
				break;
				
				case 0xE124:
					return <waitForCharacterPan char={section.readShort()} />;
				break;
					
				case 0xE125:
					return <panToCharacter char={section.readShort()} b={section.readShort()} command="0xE125" />;
				break;
					
				case 0xE129:
					return <waitForFullscreenImagePan />;
				break;
				
				case 0xE12A: return <restoreCameraPosition a={section.readShort()} />;
				case 0xE12B: return <saveCameraPosition />;
					
				case 0xE12C:
					section.position+=2;//ignore one argument;
					return <clearFlag flag={section.readShort()} />;
				break;
					
				case 0xE12D:
					section.position+=2;//ignore one argument;
					return <setFlag flag={section.readShort()} />;
				break;
					
				case 0xE12E:
					section.position+=2;//ignored
					return <jumpIfFlag flag={section.readShort()} cond={section.readShort()} section={section.readShort()} />;
				break;
				
					
					
				case 0xE12F:
					return <charAnim char={section.readShort()} anim={section.readShort()} command="0xE12F"/>;
				break;
					
					
				
				
				case 0xE133:
					return <startOamScene
						sceneId={section.readShort()}
						b= {section.readShort()}
						c= {section.readShort()}
						d= {section.readShort()}
						e= {section.readShort()}
						f= {section.readShort()}
						g= {section.readShort()}
					/>;
					
				case 0xE134:
					return <waitForOamAnim scene={section.readShort()} />;
				break;
				
				case 0xE137:
					return <oamSceneAnim scene={section.readShort()} anim={section.readShort()} />;
				break;
					
					
				case 0xE13A:
					return <miniWalk
						command="0xE13A"
						char={section.readShort()}
						x={section.readShort()}
						y={section.readShort()}
						d={section.readShort()}
						e={section.readShort()}
						f={section.readShort()}
					/>;
				break;
						
				case 0xE13B:
					return <miniWalk
						command="0xE13B"
						char={section.readShort()}
						x={section.readShort()}
						y={section.readShort()}
						d={section.readShort()}
						e={section.readShort()}
						f={section.readShort()}
					/>;
				break;
					
				case 0xE13C:
					return <miniWalk
						command="0xE13C"
						char={section.readShort()}
						b={section.readShort()}
						c={section.readShort()}
						d={section.readShort()}
						e={section.readShort()}
						f={section.readShort()}
					/>;
				break;
					
				case 0xE13E:
					return <waitCharAnim char={section.readShort()} />;
				break;
					
				case 0xE13F:
					return <miniWalk
						command="0xE13F"
						char={section.readShort()}
						b={section.readShort()}
						x={section.readShort()}
						y={section.readShort()}
						e={section.readShort()}
						f={section.readShort()}
						g={section.readShort()}
					/>;
				break;
						
				case 0xE140:
					return <miniWalk
						command="0xE140"
						char={section.readShort()}
						b={section.readShort()}
						x={section.readShort()}
						y={section.readShort()}
						e={section.readShort()}
						f={section.readShort()}
						g={section.readShort()}
					/>;
					
				case 0xE141:
					return <panCamera x={section.readShort()} y={section.readShort()} c={section.readShort()} d={section.readShort()} command="0xE141"/>;
				break;
					
				case 0xE142:
					return <panCamera x={section.readShort()} y={section.readShort()} c={section.readShort()} d={section.readShort()} command="0xE142"/>;
				break;
					
				case 0xE143:
					return <waitForCameraPan />;
				break;
					
				case 0xE144:
					return <loadScene scene={section.readShort()} />;
				break;
					
				case 0xE145:
					return <longJump case={section.readShort()} part={section.readShort()} index={section.readShort()}/>;
				break;
					
					
				case 0xE148:
					return <fadeToGrayscale a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE150:
					return <charAnim char={section.readShort()} anim={section.readShort()} command="0xE150"/>;
				break
					
				case 0xE151:
					return <miniAnim char={section.readShort()} dir={section.readShort()} anim={section.readShort()} command="0xE151"/>;
				break;
					
				case 0xE152:
					return <charAnim char={section.readShort()} b={section.readShort()} c={section.readShort()} command="0xE152"/>;
				break;

				case 0xE153:
					return <fullscreenImage a={section.readShort()} b={section.readShort()} command="0xE153" />;
				break;
					
				case 0xE154:
					return <flash command="0xE154"/>;
				break;
					
				case 0xE155:
					return <miniAnim char={section.readShort()} anim={section.readShort()} dir={section.readShort()} command="0xE155"/>;
				break;
					
				case 0xE156:
					return <miniAnim char={section.readShort()} b={section.readShort()} c={section.readShort()} d={section.readShort()} command="0xE156" />;
				break;
					
				case 0xE157:
					return <miniAnim char={section.readShort()} anim={section.readShort()} dir={section.readShort()} command="0xE157" />;
				break;
					
				case 0xE158:
					return <revealEvidence evidence={section.readShort()} />;
				break;
					
				case 0xE159:
					return <hideEvidence evidence={section.readShort()} />;
				break;
					
				case 0xE15A:
					return <syncCtrl enable={section.readShort()} />;
				break;
				
				case 0xE160: return <pointAtPicture picture={section.readShort()} />;				
				case 0xE161:
					return <pointAtPictureHit area={section.readShort()} section={section.readShort()} />;
				break;
				case 0xE162:
					return <pointAtPictureMiss section={section.readShort()} />;
				break;
					
					
				case 0xE163:
					return <evidencePrompt a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE164:
					return <evidencePromptJump evidence={section.readShort()} section={section.readShort()} />;
				break;
					
					
				case 0xE165:
					return <investigationBranchTableStart contradictionRegion={section.readShort()} contradictionEnableFlag={section.readShort()} />;
				break;
				
				case 0xE166:
					return <investigationBranchTableEnd />;
				break;
				
				case 0xE168:
					return <investigationBranchTableEnt region={section.readShort()} section={section.readShort()} />;
				break;
				
				case 0xE169:
					return <investigationBranchTableDefEnt section={section.readShort()} />;
				break;
					
				case 0xE16A:
					return <investigationContradictionPress section={section.readShort()} />;
				break;
				
				case 0xE16B:
					return <investigationContradictionEvidencePrompt a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE16C:
					return <presentContradiction 
						evidence={section.readShort()}
						evidenceType={section.readShort()}
						section={section.readShort()}
					/>;
				break;
				
				case 0xE16D:
					return <presentContradictionDefault section={section.readShort()} />;
				break;
					

				case 0xE16F:
					return <positionMini char={section.readShort()} x={section.readShort()} y={section.readShort()} d={section.readShort()} />;
				break;
				
					
				case 0xE171:
					return <waitForSoundEffect />;
				break;
					
				case 0xE172:
					return <music a={section.readShort()} b={section.readShort()} command="0xE172" />;
				break;
				
				case 0xE173:
					return <stopMusic a={section.readShort() } />;
				break;
					
				case 0xE175:
					return <music command="0xE175" />;
				break;
					
				case 0xE176:
					return <fadeMusic a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE177:
					return <music a={section.readShort()} b={section.readShort()} command="0xE177" />;
				break;
					
				case 0xE178: return <pauseMusic />;
				case 0xE179: return <resumeMusic />;

				case 0xE17A:
					return <musicAttunetation a={section.readShort()} b={section.readShort()} c={section.readShort()} command="0xE17A"/>;//music enable/select
				break;
					
					
				//present evidence branch table
				case 0xE17C:
					return <presentBranchStart />;
				break;
				
				case 0xE17E:
					return <talkTopic button={section.readShort()} section={section.readShort()} c={section.readShort()} cond={section.readShort()} />;
				break;
				
				case 0xE17F:
					return <presentBranchEntry evidence={section.readShort()} section={section.readShort()} />;
				break;
				
				case 0xE180:
					return <presentBranchDefEntry section={section.readShort()} />;
				break;
				
				case 0xE181:
					return <presentBranchEnd />;
				break;
				
				case 0xE182:
					return <updateEvidence a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE183:
					return <returnToTalkTopicMenu section={section.readShort()} />
				case 0xE184:
					return <returnToPresentEvidencePrompt section={section.readShort()} />;
				break;
				
				case 0xE185: return <showChoiseMenu a={section.readShort()} />;				
				case 0xE186: return <initChoiseMenu />;
				
				case 0xE187:
					return <choiseMenuOption button={section.readShort()} section={section.readShort()} />;
				break;
					
				case 0xE188:
					return <sound a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE194: return <forceLogic />;
					
				case 0xE196:
					return <showArgumentOverlay a={section.readShort()} />;
				break;
					
				case 0xE197:
					return <hideArgumentOverlay />;
				break;
					
				case 0xE198:
					return <showNewLogic case={section.readShort()} logic={section.readShort()} />;
				break;
				
				case 0xE199: return <flashHp amount={section.readShort()} />;
				case 0xE19A: return <clearFlashingHp />;
				case 0xE19C: return <penalty />;
				
				case 0xE1A3: return <waitFor3DExamination flag={section.readShort()} />;
				
				case 0xE1A6:
					return <ceRevisedStatement
						index={section.readShort()}
						statementSection={section.readShort()}
						pressSection={section.readShort()}
						presentSection={section.readShort()}
						startHidden={section.readShort()}
					/>;
				break;
				
				case 0xE1A7:
					return <showEyeStripeCutIn char="Edgeworth"/>;
				break;
				
				case 0xE1C0:
					return <textboxAlignment a={section.readShort()} />;
				break;
					
				case 0xE1C1:
					return <noHPBranch section={section.readShort()} />;
				break;
					
				case 0xE1C3:
					return <gameOver />;
				break;
					
				case 0xE1C4:
					return <returnToTitleScreen />;
				break;
				
				case 0xE1C6:
					return <savePrompt type={section.readShort()} />;
				break;
					
				case 0xE1C9:
					return <fullscreenImagePan a={section.readShort()} b={section.readShort()} c={section.readShort()} />;
				break;
				
				case 0xE1CB:
					return <openPipWindow evidence={section.readShort()} side={section.readShort()} c={section.readShort()} />;
				break;
				
				case 0xE1CC:
					return <closePipWindow a={section.readShort()} />;
				break;
				
				case 0xE1CD:
					return <waitForPipWindowAnimation />;
				break;
				
				case 0xE1CE:
					return <showNewEvidenceAdded evidence={section.readShort()} />;
				break;
					
				case 0xE1CF:
					return <closeOrgaizer />;
				break;
				
				
				case 0xE1D1: return <screenShake strength="mild" />;
				case 0xE1D2: return <screenShake strength="moderate" />;
				case 0xE1D5: return <flash />;
				case 0xE1DA: return <flashAndShake command="0xE1DA" />;
				
				case 0xE1E0: return <highlightLogicButton />;

				case 0xE1EA:
					return <interjection a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE1Ec:
					return <gavelSlamAnim a={section.readShort()} b={section.readShort()} />;
				break;
					
				case 0xE1E6: return <enterCloseUp a={section.readShort()} />;				
				case 0xE1E7: return <exitCloseUp />;
				
				case 0xE1E8:
					return <crossExamVsBars topChar={section.readShort()} bottomChar={section.readShort()} />;
				break;
					
				case 0xE1F9: return <addOpponentChessPiece type={chessPieceList[section.readShort()]} />;
					
				case 0xE1FA:
					return <logicChessSwapSide a={section.readShort()} b={section.readShort()} c={section.readShort()} d={section.readShort()}/>;
				break;
				
				case 0xE1FB:
					return <logicChessTimeout section={section.readShort()} />;
				break;
					
				case 0xE1FD:
					return <logicChessTopic
						a={section.readShort()} 
						button={section.readShort()} 
						section={section.readShort()} 
						d={section.readShort()} 
						command="0xE1FD"
					/>;
				break;
						
				
					
				//case 0xE1FF: return <enableLogicTimer />;
					
				case 0xE200:
					return <logicChessChoiseAttack a={section.readShort()} button={section.readShort()} section={section.readShort()} d={section.readShort()} />;
				break;
					
				case 0xE201:
					return <logicChessChoiseRest section={section.readShort()} />;
				break;
					
				case 0xE202:
					return <logicChessPrompt />;
				break;
				
				case 0xE203: return <showAttackingChessPiece />;
				
				case 0xE206: <refillTimeBar a={section.readShort()} />;
				
				case 0xE205: return <showChessPieces />;
				
				case 0xE208: return <chessAttack a={section.readShort()} b={section.readShort()} c={section.readShort()} d={section.readShort()} />;
				

				case 0xE20A:
					return <logicChessTopic
						a={section.readShort()}
						button={section.readShort()}
						section={section.readShort()}
						d={section.readShort()}
						command="0xE20A"
					/>;
				break;
				
				case 0xE213:
					return <enter3dExaminationMode />;
				break;
				
				case 0xE216:
					return <switchTo3dExaminationView a={section.readShort()} b={section.readShort()} c={section.readShort()} d={section.readShort()} />;
				break;
				
				case 0xE218:
					return jumpIfFlagsEqTo(2);
				break;
				case 0xE219:
					return jumpIfFlagsEqTo(3);
				break;
				case 0xE21A:
					return jumpIfFlagsEqTo(4);
				break;
				case 0xE21B:
					return jumpIfFlagsEqTo(5);
				break;
				
				case 0xE20D: return <center/>;
				
				case 0xE227: return <investigationCompleteAnim />;				
				case 0xE228: return <showRebuttalAnim command="0xE228" mode="enter" />;
				case 0xE229: return <showBeginInvestigationAnim mode="leave" />;				
				case 0xE22A: return <showRebuttalAnim mode="leave" />;
				
				case 0xE22E: return <timePenalty a={section.readShort()} />;
				
				case 0xE234: return <blinkLogicChessTimerArrows />;
				
				case 0xE247: return <contradictionTutorial step="point" />;
				case 0xE248: return <contradictionTutorial step="push" />;
				case 0xE249: return <contradictionTutorial step="present" />;
				case 0xE24A: return <contradictionTutorial step="retry" />;
				
				
				case 0xE251: return <luminolTutorial step={section.readShort()} />;
				case 0xE252: return <waitForLuminolSpray />;
					
				case 0xE254:
					return <fadeToImage a={section.readShort()} b={section.readShort()} c={section.readShort()} d={section.readShort()} />;
				break;
					
				case 0xE25D: return <pointAtPictureWithReturn a={section.readShort()} />;
				case 0xE25E: return <returnFromPointAtPicture section={section.readShort()} />;
				
				case 0xE280: return <flashShakeAndSound sfx="Slash" command="0xE280" />;
				case 0xE281: return <flashShakeAndSound sfx="Klash" command="0xE281" />;
				case 0xE282: return <flashShakeAndSound sfx="Punch" command="0xE282" />;
				case 0xE283: return <flashShakeAndSound sfx="Slam" command="0xE283" />;
				case 0xE284: return <flashAndSound sfx="DingL" command="0xE284" />;
				case 0xE285: return <flashAndSound sfx="DingH" command="0xE285" />;
				
				case 0xE901: return <langScrollAnim />;
				
				//case 0xE175:
					//return <music confirmed="just a guess"/>;//music change?
					//not music change
				//break;
				
				//case 0xE118: music select or music mute?
				
				//unknown pairs 'n stuff
					
				case 0xE226://one of these is the
				case 0xE244://begin investigations animation
				
				case 0xE195://one of these tween in the 
				case 0xE10F://court record button
				
				case 0xE153://one is show fullscreen image
				case 0xE118://one is a moderate/controllable shake
				
				case 0xE148://one of these is fade bg to black
				case 0xE149:
				
				case 0xE1DD://fades chars?
				
				case 0xE158://One of these is the slide in evidcence
				case 0xE1CE://for addition to record anim command
					
				case 0xE106://one of these is the wait for
				case 0xE1CF://screen click command
			
				default:
					if(commandType in unknownCommands) {
						unknownCommands[commandType]++;
					} else {
						unknownCommands[commandType]=1;
					}
					return <unknownCommand commandType={commandType.toString(16)}  />;
				break;
			}
		}
		
		private function jumpIfFlagsEqTo(count:uint):XML {
			var out:XML=<jumpIfFlagsEqTo />;
			
			section.position+=2;//ignore one argument
				
			for(var i:uint=0;i<count;++i) {
				var flagXML:XML=<flag flag={section.readShort()} />;
				out.appendChild(flagXML);
			}
			
			out.@cond=section.readShort();
			out.@section=section.readShort();
			
			return out;
		}
		
		private function commandE0B0():XML {
			var cmd:XML=<randomBranch />;
			for(var i:uint=0;i<4;++i) {
				var weight:uint=section.readShort();
				var dst:uint=section.readShort();
				
				cmd.appendChild(<destination weight={weight} section={dst} />);
			}
			
			return cmd;
		}
		
		private function commandE10D():XML {
			var a:uint=section.readShort();
			var b:uint=section.readShort();
			var c:uint=section.readShort();
			
			return <sceneChange a={a} b={b} c={c} />;
		}
		
		private function speakerBadge():XML {
			var flags:uint=section.readUnsignedShort();
			var tagId:uint=section.readShort();
			
			var char:uint=flags;
			
			var tag:String;
			
			if(tagId in speakerNames) {
				tag=speakerNames[tagId];
			} else {
				tag="0x"+tagId.toString(16);
			}
			
			return <speaker char={char} nametag={tag} />;
		}
		
		private static const chessPieceList:Object = {
			0: "Pawn",
			1: "Knight",
			2: "Queen",
			3: "Rook",
			4: "Bishop",
			5: "King"
		};
		
		private static const speakerNames:Object = {
			0x00:"Edgeworth",
			0x01:"Gumshoe",
			0x02:"Kay",
			0x03:"Ema Skye",
			0x04:"Karma",
			0x05:"Gregory",
			0x06:"Badd",
			0x07:"Lang",
			0x08:"Judge",
			0x09:"Mikagami",
			0x0A:"Ichiyanagi",
			0x0B:"Shigaraki",
			0x0C:"von Karma",
			0x0D:"Larry",
			0x0E:"Lotta Hearth",
			0x0F:"Missile",
			0x10:"Dijun Wang",
			0x11:"Knight",
			0x12:"Hayami",
			0x13:"DeKiller",
			0x14:"John Doe",
			0x15:"Ryouken",
			0x16:"Souta",
			0x17:"orinaka",
			0x18:"Marie",
			0x19:"Sahwit",
			0x1A:"Regina",
			0x1B:"Staff",
			0x1C:"Shimon",
			0x1D:"Issei Tenkai",
			0x1E:"Tsukasa Oyashiki",
			0x1F:"Delish Scone",
			0x20:"kazami",
			0x21:"hyoudou",
			0x22:"Will Powers",
			0x23:"Itami",
			0x24:"bansai",
			0x25:"mutou",
			0x26:"Tojiro",
			0x27:"Kagome",
			0x28:"kamei",
			0x29:"officer",
			0x2A:"Guard",
			0x2B:"kakarikan",
			0x2C:"Forensics",
			0x2D:"Payne",
			0x2E:"audience",
			0x2F:"crowd",
			0x30:"TV Staff",
			0x31:"Bodyguard",
			0x32:"Prisoner",
			0x33:"ajizou",
			0x34:"???",
			0x35:"???",
			0x36:"Driver",
			0x37:"MIB",
			0x38:"Man",
			0x39:"Woman",
			0x3A:"Speaker",
			0x3B:"reporter",
			0x3C:"Shopkeeper",
			0x3D:"???",
			0x3E:"???",
			0x3F:"BLANK",
			0x40:"BLANK",
			0x41:"BLANK",
			0x43:"???",
			0x44:"Kay"
		};
			
		private static const charAnimNames:Object={};

	}
	
}
