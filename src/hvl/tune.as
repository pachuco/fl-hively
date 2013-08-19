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
        
        internal var VUMeters:Vector.<int>;
        internal var FormatString:String;
        
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