package replay_hively {
    public class hvl_tune{
        public var ht_Name:String;                              //TEXT[128]
        public var ht_SongNum:uint;                             //uint16
        public var ht_Frequency:uint;                           //uint32
        public var ht_FreqF:Number;                             //float64
        public var ht_WaveformTab:Vector.<uint>;                //*int8[MAX_CHANNELS]
        public var ht_Restart:uint;                             //uint16
        public var ht_PositionNr:uint;                          //uint16
        public var ht_SpeedMultiplier:uint;                     //uint8
        public var ht_TrackLength:uint;                         //uint8
        public var ht_TrackNr:uint;                             //uint8
        public var ht_InstrumentNr:uint;                        //uint8
        public var ht_SubsongNr:uint;                           //uint8
        public var ht_PosJump:uint;                             //uint16
        public var ht_PlayingTime:uint;                         //uint32
        public var ht_Tempo:int;                                //int16
        public var ht_PosNr:int;                                //int16
        public var ht_StepWaitFrames:int;                       //int16
        public var ht_NoteNr:int;                               //int16
        public var ht_PosJumpNote:uint;                         //uint16
        public var ht_GetNewPosition:uint;                      //uint8
        public var ht_PatternBreak:uint;                        //uint8
        public var ht_SongEndReached:uint;                      //uint8
        public var ht_Stereo:uint;                              //uint8
        public var ht_Subsongs:uint;                            //*uint16
        public var ht_Channels:uint;                            //uint16
        public var ht_Positions:uint;                           //struct hvl_position *ht_Positions;
        public var ht_Tracks:Vector.<Vector.<hvl_step>>;        //hvl_step[256][64]
        public var ht_Instruments:hvl_instrument;               //struct hvl_instrument *ht_Instruments;
        public var ht_Voices:Vector.<hvl_voice>;                //hvl_voice[MAX_CHANNELS]
        public var ht_defstereo:int;                            //int32
        public var ht_defpanleft:int;                           //int32
        public var ht_defpanright:int;                          //int32
        public var ht_mixgain:int;                              //int32
        public var ht_Version:uint;                             //uint8
        
        public function hvl_tune():void{
            
            ht_WaveformTab = Vector.<uint>(cons.MAX_CHANNELS, true);
            //ht_Positions = new hvl_position();
            
            ht_Tracks = Vector.<Vector.<hvl_step>>(256, true);
            for(i=0;i<256;i++){
                var track_temp:Vector.<hvl_step> = Vector.<hvl_step>(64, true);
                ht_Tracks[i]=track_temp;
            }
            track_temp=null;
            //ht_Instruments = new hvl_instrument();
            ht_Voices = Vector.<hvl_voice>(cons.MAX_CHANNELS, true);
        }
        
        public function hvl_reset_some_stuff():void{
            var i:uint;

            for( i=0; i<MAX_CHANNELS; i++ ){
                ht_Voices[i].vc_Delta=1;
                ht_Voices[i].vc_OverrideTranspose=1000;  // 1.5
                ht_Voices[i].vc_SamplePos=0;
                ht_Voices[i].vc_Track=0;
                ht_Voices[i].vc_Transpose=0;
                ht_Voices[i].vc_NextTrack=0;
                ht_Voices[i].vc_NextTranspose=0;
                
                ht_Voices[i].vc_ADSRVolume=0;
                ht_Voices[i].vc_InstrPeriod=0;
                ht_Voices[i].vc_TrackPeriod=0;
                ht_Voices[i].vc_VibratoPeriod=0;
                ht_Voices[i].vc_NoteMaxVolume=0;
                ht_Voices[i].vc_PerfSubVolume=0;
                ht_Voices[i].vc_TrackMasterVolume=0;
                
                ht_Voices[i].vc_NewWaveform=0;
                ht_Voices[i].vc_Waveform=0;
                ht_Voices[i].vc_PlantSquare=0;
                ht_Voices[i].vc_PlantPeriod=0;
                ht_Voices[i].vc_IgnoreSquare=0;
                
                ht_Voices[i].vc_TrackOn=0;
                ht_Voices[i].vc_FixedNote=0;
                ht_Voices[i].vc_VolumeSlideUp=0;
                ht_Voices[i].vc_VolumeSlideDown=0;
                ht_Voices[i].vc_HardCut=0;
                ht_Voices[i].vc_HardCutRelease=0;
                ht_Voices[i].vc_HardCutReleaseF=0;
                
                ht_Voices[i].vc_PeriodSlideSpeed=0;
                ht_Voices[i].vc_PeriodSlidePeriod=0;
                ht_Voices[i].vc_PeriodSlideLimit=0;
                ht_Voices[i].vc_PeriodSlideOn=0;
                ht_Voices[i].vc_PeriodSlideWithLimit=0;
                
                ht_Voices[i].vc_PeriodPerfSlideSpeed=0;
                ht_Voices[i].vc_PeriodPerfSlidePeriod=0;
                ht_Voices[i].vc_PeriodPerfSlideOn=0;
                ht_Voices[i].vc_VibratoDelay=0;
                ht_Voices[i].vc_VibratoCurrent=0;
                ht_Voices[i].vc_VibratoDepth=0;
                ht_Voices[i].vc_VibratoSpeed=0;
                
                ht_Voices[i].vc_SquareOn=0;
                ht_Voices[i].vc_SquareInit=0;
                ht_Voices[i].vc_SquareLowerLimit=0;
                ht_Voices[i].vc_SquareUpperLimit=0;
                ht_Voices[i].vc_SquarePos=0;
                ht_Voices[i].vc_SquareSign=0;
                ht_Voices[i].vc_SquareSlidingIn=0;
                ht_Voices[i].vc_SquareReverse=0;
                
                ht_Voices[i].vc_FilterOn=0;
                ht_Voices[i].vc_FilterInit=0;
                ht_Voices[i].vc_FilterLowerLimit=0;
                ht_Voices[i].vc_FilterUpperLimit=0;
                ht_Voices[i].vc_FilterPos=0;
                ht_Voices[i].vc_FilterSign=0;
                ht_Voices[i].vc_FilterSpeed=0;
                ht_Voices[i].vc_FilterSlidingIn=0;
                ht_Voices[i].vc_IgnoreFilter=0;
                
                ht_Voices[i].vc_PerfCurrent=0;
                ht_Voices[i].vc_PerfSpeed=0;
                ht_Voices[i].vc_WaveLength=0;
                ht_Voices[i].vc_NoteDelayOn=0;
                ht_Voices[i].vc_NoteCutOn=0;
                
                ht_Voices[i].vc_AudioPeriod=0;
                ht_Voices[i].vc_AudioVolume=0;
                ht_Voices[i].vc_VoiceVolume=0;
                ht_Voices[i].vc_VoicePeriod=0;
                ht_Voices[i].vc_VoiceNum=0;
                ht_Voices[i].vc_WNRandom=0;
                
                ht_Voices[i].vc_SquareWait=0;
                ht_Voices[i].vc_FilterWait=0;
                ht_Voices[i].vc_PerfWait=0;
                ht_Voices[i].vc_NoteDelayWait=0;
                ht_Voices[i].vc_NoteCutWait=0;
                
                ht_Voices[i].vc_PerfList=0;
                
                ht_Voices[i].vc_RingSamplePos=0;
                ht_Voices[i].vc_RingDelta=0;
                ht_Voices[i].vc_RingPlantPeriod=0;
                ht_Voices[i].vc_RingAudioPeriod=0;
                ht_Voices[i].vc_RingNewWaveform=0;
                ht_Voices[i].vc_RingWaveform=0;
                ht_Voices[i].vc_RingFixedPeriod=0;
                ht_Voices[i].vc_RingBasePeriod=0;

                ht_Voices[i].vc_RingMixSource = null;
                ht_Voices[i].vc_RingAudioSource = null;
                
                var j:uint;
                for(j=0;j<0x80;j++){
                    ht_Voices[i].vc_SquareTempBuffer[j]=0;
                }
                ht_Voices[i].vc_ADSR.aFrames=0;
                ht_Voices[i].vc_ADSR.aVolume=0;
                ht_Voices[i].vc_ADSR.dFrames=0;
                ht_Voices[i].vc_ADSR.dVolume=0;
                ht_Voices[i].vc_ADSR.sFrames=0;
                ht_Voices[i].vc_ADSR.rFrames=0;
                ht_Voices[i].vc_ADSR.rVolume=0;
                ht_Voices[i].vc_ADSR.pad=0;
                for(j=0;j<0x281;j++){ //Should be 0x282*4
                    ht_Voices[i].vc_VoiceBuffer[j]=0;
                }
                for(j=0;j<0x281;j++){ //same
                    ht_Voices[i].vc_RingVoiceBuffer[j]=0;
                }
            }

            for( i=0; i<MAX_CHANNELS; i++ ){
                ht_Voices[i].vc_WNRandom          = 0x280;
                ht_Voices[i].vc_VoiceNum          = i;
                ht_Voices[i].vc_TrackMasterVolume = 0x40;
                ht_Voices[i].vc_TrackOn           = 1;
                ht_Voices[i].vc_MixSource         = ht_Voices[i].vc_VoiceBuffer;
            }
        }
    }
}