package hvl {
    internal class tune{
        internal var Name:String;                              //TEXT[128]
        internal var SongNum:uint;                             //uint16
        internal var Frequency:uint;                           //uint32
        internal var FreqF:Number;                             //float64
        internal var WaveformTab:Vector.<uint>;                //*int8[MAX_CHANNELS]
        internal var WaveformTab_i2:Vector.<int>;
        internal var Restart:uint;                             //uint16
        internal var PositionNr:uint;                          //uint16
        internal var SpeedMultiplier:uint;                     //uint8
        internal var TrackLength:uint;                         //uint8
        internal var TrackNr:uint;                             //uint8
        internal var InstrumentNr:uint;                        //uint8
        internal var SubsongNr:uint;                           //uint8
        internal var PosJump:uint;                             //uint16
        internal var PlayingTime:uint;                         //uint32
        internal var Tempo:int;                                //int16
        internal var PosNr:int;                                //int16
        internal var StepWaitFrames:int;                       //int16
        internal var NoteNr:int;                               //int16
        internal var PosJumpNote:uint;                         //uint16
        internal var GetNewPosition:uint;                      //uint8
        internal var PatternBreak:uint;                        //uint8
        internal var SongEndReached:uint;                      //uint8
        internal var Stereo:uint;                              //uint8
        internal var Subsongs:Vector.<uint>;                   //*uint16
        internal var Channels:uint;                            //uint16
        internal var Positions:Vector.<position>;          //struct hvl_position *ht_Positions;
        internal var Tracks:Vector.<step>;        //hvl_step[256][64]
        internal var Instruments:Vector.<instrument>;      //struct hvl_instrument *ht_Instruments;
        internal var Voices:Vector.<voice>;                //hvl_voice[MAX_CHANNELS]
        internal var defstereo:int;                            //int32
        internal var defpanleft:int;                           //int32
        internal var defpanright:int;                          //int32
        internal var mixgain:int;                              //int32
        internal var Version:uint;                             //uint8
        
        private static const xy:uint = 256 * 64;
        
        public function tune():void {
            var i:uint;
            WaveformTab = new Vector.<uint>(cons.MAX_CHANNELS, true);
            WaveformTab_i2 = new Vector.<int>();
            Positions = new Vector.<position>();                                     //malloc();
            Tracks = new Vector.<step>(xy, true);
            for(i=0; i<xy; i++){
                Tracks[i] = new step();
            }
            Instruments = new Vector.<instrument>();                  //malloc();
            Voices = new Vector.<voice>(cons.MAX_CHANNELS, true);
            for(i=0; i<cons.MAX_CHANNELS; i++ ){
                Voices[i] = new voice();;
            }
        }
        
        internal function reset_some_stuff():void{
            var i:uint;

            for( i=0; i<cons.MAX_CHANNELS; i++ ){
                Voices[i].Delta=1;
                Voices[i].OverrideTranspose=1000;  // 1.5
                Voices[i].SamplePos=0;
                Voices[i].Track=0;
                Voices[i].Transpose=0;
                Voices[i].NextTrack=0;
                Voices[i].NextTranspose=0;
                
                Voices[i].ADSRVolume=0;
                Voices[i].InstrPeriod=0;
                Voices[i].TrackPeriod=0;
                Voices[i].VibratoPeriod=0;
                Voices[i].NoteMaxVolume=0;
                Voices[i].PerfSubVolume=0;
                Voices[i].TrackMasterVolume=0;
                
                Voices[i].NewWaveform=0;
                Voices[i].Waveform=0;
                Voices[i].PlantSquare=0;
                Voices[i].PlantPeriod=0;
                Voices[i].IgnoreSquare=0;
                
                Voices[i].TrackOn=0;
                Voices[i].FixedNote=0;
                Voices[i].VolumeSlideUp=0;
                Voices[i].VolumeSlideDown=0;
                Voices[i].HardCut=0;
                Voices[i].HardCutRelease=0;
                Voices[i].HardCutReleaseF=0;
                
                Voices[i].PeriodSlideSpeed=0;
                Voices[i].PeriodSlidePeriod=0;
                Voices[i].PeriodSlideLimit=0;
                Voices[i].PeriodSlideOn=0;
                Voices[i].PeriodSlideWithLimit=0;
                
                Voices[i].PeriodPerfSlideSpeed=0;
                Voices[i].PeriodPerfSlidePeriod=0;
                Voices[i].PeriodPerfSlideOn=0;
                Voices[i].VibratoDelay=0;
                Voices[i].VibratoCurrent=0;
                Voices[i].VibratoDepth=0;
                Voices[i].VibratoSpeed=0;
                
                Voices[i].SquareOn=0;
                Voices[i].SquareInit=0;
                Voices[i].SquareLowerLimit=0;
                Voices[i].SquareUpperLimit=0;
                Voices[i].SquarePos=0;
                Voices[i].SquareSign=0;
                Voices[i].SquareSlidingIn=0;
                Voices[i].SquareReverse=0;
                
                Voices[i].FilterOn=0;
                Voices[i].FilterInit=0;
                Voices[i].FilterLowerLimit=0;
                Voices[i].FilterUpperLimit=0;
                Voices[i].FilterPos=0;
                Voices[i].FilterSign=0;
                Voices[i].FilterSpeed=0;
                Voices[i].FilterSlidingIn=0;
                Voices[i].IgnoreFilter=0;
                
                Voices[i].PerfCurrent=0;
                Voices[i].PerfSpeed=0;
                Voices[i].WaveLength=0;
                Voices[i].NoteDelayOn=0;
                Voices[i].NoteCutOn=0;
                
                Voices[i].AudioPeriod=0;
                Voices[i].AudioVolume=0;
                Voices[i].VoiceVolume=0;
                Voices[i].VoicePeriod=0;
                Voices[i].VoiceNum=0;
                Voices[i].WNRandom=0;
                
                Voices[i].SquareWait=0;
                Voices[i].FilterWait=0;
                Voices[i].PerfWait=0;
                Voices[i].NoteDelayWait=0;
                Voices[i].NoteCutWait=0;
                
                Voices[i].PerfList=null;
                
                Voices[i].RingSamplePos=0;
                Voices[i].RingDelta=0;
                Voices[i].RingPlantPeriod=0;
                Voices[i].RingAudioPeriod=0;
                Voices[i].RingNewWaveform=0;
                Voices[i].RingWaveform=0;
                Voices[i].RingFixedPeriod=0;
                Voices[i].RingBasePeriod=0;

                Voices[i].RingMixSource = null;
                Voices[i].RingAudioSource = uint.MAX_VALUE;
                
                var j:uint;
                for(j=0;j<0x80;j++){
                    Voices[i].SquareTempBuffer[j]=0;
                }
                Voices[i].ADSR.aFrames=0;
                Voices[i].ADSR.aVolume=0;
                Voices[i].ADSR.dFrames=0;
                Voices[i].ADSR.dVolume=0;
                Voices[i].ADSR.sFrames=0;
                Voices[i].ADSR.rFrames=0;
                Voices[i].ADSR.rVolume=0;
                Voices[i].ADSR.pad=0;
                for(j=0;j<0x281;j++){ //Should be 0x282*4
                    Voices[i].VoiceBuffer[j]=0;
                }
                for(j=0;j<0x281;j++){ //same
                    Voices[i].RingVoiceBuffer[j]=0;
                }
            }

            for( i=0; i<cons.MAX_CHANNELS; i++ ){
                Voices[i].WNRandom          = 0x280;
                Voices[i].VoiceNum          = i;
                Voices[i].TrackMasterVolume = 0x40;
                Voices[i].TrackOn           = 1;
                Voices[i].MixSource         = Voices[i].VoiceBuffer;
            }
        }
        
        internal function malloc_positions( ind:uint ):void{
            for(var i:uint=0;i<ind;i++){
                Positions.push(new position());
            }
        }
        
        internal function malloc_instruments( ind:uint ):void{
            for(var i:uint=0;i<=ind;i++){
                Instruments.push(new instrument());
            }
        }
        
        internal function malloc_subsongs( ind:uint ):void{
            Subsongs = new Vector.<uint>(ind, true);
        }
    }
}