package hvl {
    internal class voice{
        public var Track:int;                                    //int16
        public var NextTrack:int;                                //int16
        public var Transpose:int;                                //int16
        public var NextTranspose:int;                            //int16
        public var OverrideTranspose:int; // 1.5                 //int16
        public var ADSRVolume:int;                               //int32
        public var ADSR:envelope;                            //
        public var Instrument:instrument;                    //struct hvl_instrument *vc_Instrument;
        public var SamplePos:uint;                               //uint32
        public var Delta:uint;                                   //uint32
        public var InstrPeriod:uint;                             //uint16
        public var TrackPeriod:uint;                             //uint16
        public var VibratoPeriod:uint;                           //uint16
        public var WaveLength:uint;                              //uint16
        public var NoteMaxVolume:int;                            //int16
        public var PerfSubVolume:uint;                           //uint16
        public var NewWaveform:uint;                             //uint8
        public var Waveform:uint;                                //uint8
        public var PlantPeriod:uint;                             //uint8
        public var VoiceVolume:uint;                             //uint8
        public var PlantSquare:uint;                             //uint8
        public var IgnoreSquare:uint;                            //uint8
        public var FixedNote:uint;                               //uint8
        public var VolumeSlideUp:int;                            //int16
        public var VolumeSlideDown:int;                          //int16
        public var HardCut:int;                                  //int16
        public var HardCutRelease:uint;                          //uint8
        public var HardCutReleaseF:int;                          //int16
        public var PeriodSlideOn:uint;                           //uint8
        public var PeriodSlideSpeed:int;                         //int16
        public var PeriodSlidePeriod:int;                        //int16
        public var PeriodSlideLimit:int;                         //int16
        public var PeriodSlideWithLimit:int;                     //int16
        public var PeriodPerfSlideSpeed:int;                     //int16
        public var PeriodPerfSlidePeriod:int;                    //int16
        public var PeriodPerfSlideOn:uint;                       //uint8
        public var VibratoDelay:int;                             //int16
        public var VibratoSpeed:int;                             //int16
        public var VibratoCurrent:int;                           //int16
        public var VibratoDepth:int;                             //int16
        public var SquareOn:int;                                 //int16
        public var SquareInit:int;                               //int16
        public var SquareWait:int;                               //int16
        public var SquareLowerLimit:int;                         //int16
        public var SquareUpperLimit:int;                         //int16
        public var SquarePos:int;                                //int16
        public var SquareSign:int;                               //int16
        public var SquareSlidingIn:int;                          //int16
        public var SquareReverse:int;                            //int16
        public var FilterOn:uint;                                //uint8
        public var FilterInit:uint;                              //uint8
        public var FilterWait:int;                               //int16
        public var FilterSpeed:int;                              //int16
        public var FilterUpperLimit:int;                         //int16
        public var FilterLowerLimit:int;                         //int16
        public var FilterPos:int;                                //int16
        public var FilterSign:int;                               //int16
        public var FilterSlidingIn:int;                          //int16
        public var IgnoreFilter:int;                             //int16
        public var PerfCurrent:int;                              //int16
        public var PerfSpeed:int;                                //int16
        public var PerfWait:int;                                 //int16
        public var PerfList:plist;                           //struct hvl_plist *vc_PerfList;
        public var AudioPointer:uint;                            //*int8
        public var AudioSource:uint;                             //*int8
        public var NoteDelayOn:uint;                             //uint8
        public var NoteCutOn:uint;                               //uint8
        public var NoteDelayWait:int;                            //int16
        public var NoteCutWait:int;                              //int16
        public var AudioPeriod:int;                              //int16
        public var AudioVolume:int;                              //int16
        public var WNRandom:int;                                 //int32
        public var MixSource:Vector.<int>;                       //*int8
        public var SquareTempBuffer:Vector.<int>;                //int8[0x80]
        public var VoiceBuffer:Vector.<int>;                     //int8[0x282*4]
        public var VoiceNum:uint;                                //uint8
        public var TrackMasterVolume:uint;                       //uint8
        public var TrackOn:uint;                                 //uint8
        public var VoicePeriod:int;                              //int16
        public var Pan:uint;                                     //uint32
        public var SetPan:uint;   // New for 1.4                 //uint32
        public var PanMultLeft:uint;                             //uint32
        public var PanMultRight:uint;                            //uint32
        public var RingSamplePos:uint;                           //uint32
        public var RingDelta:uint;                               //uint32
        public var RingMixSource:Vector.<int>;                   //*int8
        public var RingPlantPeriod:uint;                         //uint8
        public var RingInstrPeriod:int;                          //int16
        public var RingBasePeriod:int;                           //int16
        public var RingAudioPeriod:int;                          //int16
        public var RingAudioSource:uint;                         //*int8
        public var RingNewWaveform:uint;                         //uint8
        public var RingWaveform:uint;                            //uint8
        public var RingFixedPeriod:uint;                         //uint8
        public var RingVoiceBuffer:Vector.<int>;                 //int8[0x282*4]
        
        //public var VUMeter:uint;                                 //uint32
        
        public function voice():void{
            ADSR = new envelope();
            SquareTempBuffer = new Vector.<int>(0x80, true);
            VoiceBuffer = new Vector.<int>(0x282*4, true);
            RingVoiceBuffer = new Vector.<int>(0x282 * 4, true);
        }
    }
}