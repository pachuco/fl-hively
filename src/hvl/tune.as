package hvl {
    internal class tune{
        public var Name:String;                              //TEXT[128]
        public var SongNum:uint;                             //uint16
        public var Frequency:uint;                           //uint32
        public var FreqF:Number;                             //float64
        public var WaveformTab:Vector.<uint>;                //*int8[MAX_CHANNELS]
        public var WaveformTab_i2:Vector.<int>;
        public var Restart:uint;                             //uint16
        public var PositionNr:uint;                          //uint16
        public var SpeedMultiplier:uint;                     //uint8
        public var TrackLength:uint;                         //uint8
        public var TrackNr:uint;                             //uint8
        public var InstrumentNr:uint;                        //uint8
        public var SubsongNr:uint;                           //uint8
        public var PosJump:uint;                             //uint16
        public var PlayingTime:uint;                         //uint32
        public var Tempo:int;                                //int16
        public var PosNr:int;                                //int16
        public var StepWaitFrames:int;                       //int16
        public var NoteNr:int;                               //int16
        public var PosJumpNote:uint;                         //uint16
        public var GetNewPosition:uint;                      //uint8
        public var PatternBreak:uint;                        //uint8
        public var SongEndReached:uint;                      //uint8
        public var Stereo:uint;                              //uint8
        public var Subsongs:Vector.<uint>;                   //*uint16
        public var Channels:uint;                            //uint16
        public var Positions:Vector.<position>;          //struct hvl_position *ht_Positions;
        public var Tracks:Vector.<step>;                 //hvl_step[256][64]
        public var Instruments:Vector.<instrument>;      //struct hvl_instrument *ht_Instruments;
        public var Voices:Vector.<voice>;                //hvl_voice[MAX_CHANNELS]
        public var defstereo:int;                            //int32
        public var defpanleft:int;                           //int32
        public var defpanright:int;                          //int32
        public var mixgain:int;                              //int32
        public var Version:uint;                             //uint8
        
        public var VUMeters:Vector.<int>;
        public var FormatString:String;
        
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
        
        public function init_VUMeters():void {
            var i:uint;
            VUMeters = new Vector.<int>(Channels, true);
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