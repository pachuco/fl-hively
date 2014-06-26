package hvl {
    public class voice{
        public var
            Track:int,                                    //int16
            NextTrack:int,                                //int16
            Transpose:int,                                //int16
            NextTranspose:int,                            //int16
            OverrideTranspose:int, // 1.5                 //int16
            ADSRVolume:int,                               //int32
            ADSR:envelope,                            //
            Instrument:instrument,                    //struct hvl_instrument *vc_Instrument;
            SamplePos:uint,                               //uint32
            Delta:uint,                                   //uint32
            InstrPeriod:uint,                             //uint16
            TrackPeriod:uint,                             //uint16
            VibratoPeriod:uint,                           //uint16
            WaveLength:uint,                              //uint16
            NoteMaxVolume:int,                            //int16
            PerfSubVolume:uint,                           //uint16
            NewWaveform:uint,                             //uint8
            Waveform:uint,                                //uint8
            PlantPeriod:uint,                             //uint8
            VoiceVolume:uint,                             //uint8
            PlantSquare:uint,                             //uint8
            IgnoreSquare:uint,                            //uint8
            FixedNote:uint,                               //uint8
            VolumeSlideUp:int,                            //int16
            VolumeSlideDown:int,                          //int16
            HardCut:int,                                  //int16
            HardCutRelease:uint,                          //uint8
            HardCutReleaseF:int,                          //int16
            PeriodSlideOn:uint,                           //uint8
            PeriodSlideSpeed:int,                         //int16
            PeriodSlidePeriod:int,                        //int16
            PeriodSlideLimit:int,                         //int16
            PeriodSlideWithLimit:int,                     //int16
            PeriodPerfSlideSpeed:int,                     //int16
            PeriodPerfSlidePeriod:int,                    //int16
            PeriodPerfSlideOn:uint,                       //uint8
            VibratoDelay:int,                             //int16
            VibratoSpeed:int,                             //int16
            VibratoCurrent:int,                           //int16
            VibratoDepth:int,                             //int16
            SquareOn:int,                                 //int16
            SquareInit:int,                               //int16
            SquareWait:int,                               //int16
            SquareLowerLimit:int,                         //int16
            SquareUpperLimit:int,                         //int16
            SquarePos:int,                                //int16
            SquareSign:int,                               //int16
            SquareSlidingIn:int,                          //int16
            SquareReverse:int,                            //int16
            FilterOn:uint,                                //uint8
            FilterInit:uint,                              //uint8
            FilterWait:int,                               //int16
            FilterSpeed:int,                              //int16
            FilterUpperLimit:int,                         //int16
            FilterLowerLimit:int,                         //int16
            FilterPos:int,                                //int16
            FilterSign:int,                               //int16
            FilterSlidingIn:int,                          //int16
            IgnoreFilter:int,                             //int16
            PerfCurrent:int,                              //int16
            PerfSpeed:int,                                //int16
            PerfWait:int,                                 //int16
            PerfList:plist,                           //struct hvl_plist *vc_PerfList;
            AudioPointer:uint,                            //*int8
            AudioSource:uint,                             //*int8
            NoteDelayOn:uint,                             //uint8
            NoteCutOn:uint,                               //uint8
            NoteDelayWait:int,                            //int16
            NoteCutWait:int,                              //int16
            AudioPeriod:int,                              //int16
            AudioVolume:int,                              //int16
            WNRandom:int,                                 //int32
            MixSource:Vector.<int>,                       //*int8
            SquareTempBuffer:Vector.<int>,                //int8[0x80]
            VoiceBuffer:Vector.<int>,                     //int8[0x282*4]
            VoiceNum:uint,                                //uint8
            TrackMasterVolume:uint,                       //uint8
            TrackOn:uint,                                 //uint8
            VoicePeriod:int,                              //int16
            Pan:uint,                                     //uint32
            SetPan:uint,   // New for 1.4                 //uint32
            PanMultLeft:uint,                             //uint32
            PanMultRight:uint,                            //uint32
            RingSamplePos:uint,                           //uint32
            RingDelta:uint,                               //uint32
            RingMixSource:Vector.<int>,                   //*int8
            RingPlantPeriod:uint,                         //uint8
            RingInstrPeriod:int,                          //int16
            RingBasePeriod:int,                           //int16
            RingAudioPeriod:int,                          //int16
            RingAudioSource:uint,                         //*int8
            RingNewWaveform:uint,                         //uint8
            RingWaveform:uint,                            //uint8
            RingFixedPeriod:uint,                         //uint8
            RingVoiceBuffer:Vector.<int>;                 //int8[0x282*4]
        
        //public var VUMeter:uint;                                 //uint32
        
        public function voice(){
            ADSR = new envelope();
            SquareTempBuffer = new Vector.<int>(0x80, true);
            VoiceBuffer = new Vector.<int>(0x282*4, true);
            RingVoiceBuffer = new Vector.<int>(0x282 * 4, true);
        }
    }
}