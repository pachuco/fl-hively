package hvl {
    internal class voice{
        internal var Track:int;                                    //int16
        internal var NextTrack:int;                                //int16
        internal var Transpose:int;                                //int16
        internal var NextTranspose:int;                            //int16
        internal var OverrideTranspose:int; // 1.5                 //int16
        internal var ADSRVolume:int;                               //int32
        internal var ADSR:envelope;                            //
        internal var Instrument:instrument;                    //struct hvl_instrument *vc_Instrument;
        internal var SamplePos:uint;                               //uint32
        internal var Delta:uint;                                   //uint32
        internal var InstrPeriod:uint;                             //uint16
        internal var TrackPeriod:uint;                             //uint16
        internal var VibratoPeriod:uint;                           //uint16
        internal var WaveLength:uint;                              //uint16
        internal var NoteMaxVolume:int;                            //int16
        internal var PerfSubVolume:uint;                           //uint16
        internal var NewWaveform:uint;                             //uint8
        internal var Waveform:uint;                                //uint8
        internal var PlantPeriod:uint;                             //uint8
        internal var VoiceVolume:uint;                             //uint8
        internal var PlantSquare:uint;                             //uint8
        internal var IgnoreSquare:uint;                            //uint8
        internal var FixedNote:uint;                               //uint8
        internal var VolumeSlideUp:int;                            //int16
        internal var VolumeSlideDown:int;                          //int16
        internal var HardCut:int;                                  //int16
        internal var HardCutRelease:uint;                          //uint8
        internal var HardCutReleaseF:int;                          //int16
        internal var PeriodSlideOn:uint;                           //uint8
        internal var PeriodSlideSpeed:int;                         //int16
        internal var PeriodSlidePeriod:int;                        //int16
        internal var PeriodSlideLimit:int;                         //int16
        internal var PeriodSlideWithLimit:int;                     //int16
        internal var PeriodPerfSlideSpeed:int;                     //int16
        internal var PeriodPerfSlidePeriod:int;                    //int16
        internal var PeriodPerfSlideOn:uint;                       //uint8
        internal var VibratoDelay:int;                             //int16
        internal var VibratoSpeed:int;                             //int16
        internal var VibratoCurrent:int;                           //int16
        internal var VibratoDepth:int;                             //int16
        internal var SquareOn:int;                                 //int16
        internal var SquareInit:int;                               //int16
        internal var SquareWait:int;                               //int16
        internal var SquareLowerLimit:int;                         //int16
        internal var SquareUpperLimit:int;                         //int16
        internal var SquarePos:int;                                //int16
        internal var SquareSign:int;                               //int16
        internal var SquareSlidingIn:int;                          //int16
        internal var SquareReverse:int;                            //int16
        internal var FilterOn:uint;                                //uint8
        internal var FilterInit:uint;                              //uint8
        internal var FilterWait:int;                               //int16
        internal var FilterSpeed:int;                              //int16
        internal var FilterUpperLimit:int;                         //int16
        internal var FilterLowerLimit:int;                         //int16
        internal var FilterPos:int;                                //int16
        internal var FilterSign:int;                               //int16
        internal var FilterSlidingIn:int;                          //int16
        internal var IgnoreFilter:int;                             //int16
        internal var PerfCurrent:int;                              //int16
        internal var PerfSpeed:int;                                //int16
        internal var PerfWait:int;                                 //int16
        internal var PerfList:plist;                           //struct hvl_plist *vc_PerfList;
        internal var AudioPointer:uint;                            //*int8
        internal var AudioSource:uint;                             //*int8
        internal var NoteDelayOn:uint;                             //uint8
        internal var NoteCutOn:uint;                               //uint8
        internal var NoteDelayWait:int;                            //int16
        internal var NoteCutWait:int;                              //int16
        internal var AudioPeriod:int;                              //int16
        internal var AudioVolume:int;                              //int16
        internal var WNRandom:int;                                 //int32
        internal var MixSource:Vector.<int>;                       //*int8
        internal var SquareTempBuffer:Vector.<int>;                //int8[0x80]
        internal var VoiceBuffer:Vector.<int>;                     //int8[0x282*4]
        internal var VoiceNum:uint;                                //uint8
        internal var TrackMasterVolume:uint;                       //uint8
        internal var TrackOn:uint;                                 //uint8
        internal var VoicePeriod:int;                              //int16
        internal var Pan:uint;                                     //uint32
        internal var SetPan:uint;   // New for 1.4                 //uint32
        internal var PanMultLeft:uint;                             //uint32
        internal var PanMultRight:uint;                            //uint32
        internal var RingSamplePos:uint;                           //uint32
        internal var RingDelta:uint;                               //uint32
        internal var RingMixSource:Vector.<int>;                   //*int8
        internal var RingPlantPeriod:uint;                         //uint8
        internal var RingInstrPeriod:int;                          //int16
        internal var RingBasePeriod:int;                           //int16
        internal var RingAudioPeriod:int;                          //int16
        internal var RingAudioSource:uint;                         //*int8
        internal var RingNewWaveform:uint;                         //uint8
        internal var RingWaveform:uint;                            //uint8
        internal var RingFixedPeriod:uint;                         //uint8
        internal var RingVoiceBuffer:Vector.<int>;                 //int8[0x282*4]
        
        internal var VUMeter:uint;                                 //uint32
        
        public function voice():void{
            ADSR = new envelope();
            SquareTempBuffer = new Vector.<int>(0x80, true);
            VoiceBuffer = new Vector.<int>(0x282*4, true);
            RingVoiceBuffer = new Vector.<int>(0x282*4, true);
        }
    }
}