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
        public var ht_Positions:hvl_position;                   //struct hvl_position *ht_Positions;
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
    }
}