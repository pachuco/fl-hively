package replay_hively {
    public class hvl_voice{
        public var vc_Track:int;                                    //int16
        public var vc_NextTrack:int;                                //int16
        public var vc_Transpose:int;                                //int16
        public var vc_NextTranspose:int;                            //int16
        public var vc_OverrideTranspose:int; // 1.5                 //int16
        public var vc_ADSRVolume:int;                               //int32
        public var vc_ADSR:hvl_envelope;                            //
        public var vc_Instrument:hvl_instrument;                    //struct hvl_instrument *vc_Instrument;
        public var vc_SamplePos:uint;                               //uint32
        public var vc_Delta:uint;                                   //uint32
        public var vc_InstrPeriod:uint;                             //uint16
        public var vc_TrackPeriod:uint;                             //uint16
        public var vc_VibratoPeriod:uint;                           //uint16
        public var vc_WaveLength:uint;                              //uint16
        public var vc_NoteMaxVolume:int;                            //int16
        public var vc_PerfSubVolume:uint;                           //uint16
        public var vc_NewWaveform:uint;                             //uint8
        public var vc_Waveform:uint;                                //uint8
        public var vc_PlantPeriod:uint;                             //uint8
        public var vc_VoiceVolume:uint;                             //uint8
        public var vc_PlantSquare:uint;                             //uint8
        public var vc_IgnoreSquare:uint;                            //uint8
        public var vc_FixedNote:uint;                               //uint8
        public var vc_VolumeSlideUp:int;                            //int16
        public var vc_VolumeSlideDown:int;                          //int16
        public var vc_HardCut:int;                                  //int16
        public var vc_HardCutRelease:uint;                          //uint8
        public var vc_HardCutReleaseF:int;                          //int16
        public var vc_PeriodSlideOn:uint;                           //uint8
        public var vc_PeriodSlideSpeed:int;                         //int16
        public var vc_PeriodSlidePeriod:int;                        //int16
        public var vc_PeriodSlideLimit:int;                         //int16
        public var vc_PeriodSlideWithLimit:int;                     //int16
        public var vc_PeriodPerfSlideSpeed:int;                     //int16
        public var vc_PeriodPerfSlidePeriod:int;                    //int16
        public var vc_PeriodPerfSlideOn:uint;                       //uint8
        public var vc_VibratoDelay:int;                             //int16
        public var vc_VibratoSpeed:int;                             //int16
        public var vc_VibratoCurrent:int;                           //int16
        public var vc_VibratoDepth:int;                             //int16
        public var vc_SquareOn:int;                                 //int16
        public var vc_SquareInit:int;                               //int16
        public var vc_SquareWait:int;                               //int16
        public var vc_SquareLowerLimit:int;                         //int16
        public var vc_SquareUpperLimit:int;                         //int16
        public var vc_SquarePos:int;                                //int16
        public var vc_SquareSign:int;                               //int16
        public var vc_SquareSlidingIn:int;                          //int16
        public var vc_SquareReverse:int;                            //int16
        public var vc_FilterOn:uint;                                //uint8
        public var vc_FilterInit:uint;                              //uint8
        public var vc_FilterWait:int;                               //int16
        public var vc_FilterSpeed:int;                              //int16
        public var vc_FilterUpperLimit:int;                         //int16
        public var vc_FilterLowerLimit:int;                         //int16
        public var vc_FilterPos:int;                                //int16
        public var vc_FilterSign:int;                               //int16
        public var vc_FilterSlidingIn:int;                          //int16
        public var vc_IgnoreFilter:int;                             //int16
        public var vc_PerfCurrent:int;                              //int16
        public var vc_PerfSpeed:int;                                //int16
        public var vc_PerfWait:int;                                 //int16
        public var vc_PerfList:hvl_plist;                           //struct hvl_plist *vc_PerfList;
        public var vc_AudioPointer:uint;                            //*int8
        public var vc_AudioSource:uint;                             //*int8
        public var vc_NoteDelayOn:uint;                             //uint8
        public var vc_NoteCutOn:uint;                               //uint8
        public var vc_NoteDelayWait:int;                            //int16
        public var vc_NoteCutWait:int;                              //int16
        public var vc_AudioPeriod:int;                              //int16
        public var vc_AudioVolume:int;                              //int16
        public var vc_WNRandom:int;                                 //int32
        //public var vc_MixSource:uint;                               //*int8
        public var vc_MixSource:Vector.<int>;
        public var vc_SquareTempBuffer:Vector.<int>;                //int8[0x80]
        public var vc_VoiceBuffer:Vector.<int>;                     //int8[0x282*4]
        public var vc_VoiceNum:uint;                                //uint8
        public var vc_TrackMasterVolume:uint;                       //uint8
        public var vc_TrackOn:uint;                                 //uint8
        public var vc_VoicePeriod:int;                              //int16
        public var vc_Pan:uint;                                     //uint32
        public var vc_SetPan:uint;   // New for 1.4                 //uint32
        public var vc_PanMultLeft:uint;                             //uint32
        public var vc_PanMultRight:uint;                            //uint32
        public var vc_RingSamplePos:uint;                           //uint32
        public var vc_RingDelta:uint;                               //uint32
        //public var vc_RingMixSource:uint;                           //*int8
        public var vc_RingMixSource:Vector.<int>;
        public var vc_RingPlantPeriod:uint;                         //uint8
        public var vc_RingInstrPeriod:int;                          //int16
        public var vc_RingBasePeriod:int;                           //int16
        public var vc_RingAudioPeriod:int;                          //int16
        public var vc_RingAudioSource:uint;                         //*int8
        public var vc_RingNewWaveform:uint;                         //uint8
        public var vc_RingWaveform:uint;                            //uint8
        public var vc_RingFixedPeriod:uint;                         //uint8
        public var vc_RingVoiceBuffer:Vector.<int>;                 //int8[0x282*4]
        
        public function hvl_voice():void{
            vc_ADSR = new hvl_envelope();
            //vc_Instrument = new hvl_instrument();
            //vc_PerfList = new hvl_plist();
            vc_SquareTempBuffer = Vector.<int>(0x80, true);
            vc_VoiceBuffer = Vector.<int>(0x282*4, true);
            vc_RingVoiceBuffer = Vector.<int>(0x282*4, true);
        }
    }
}