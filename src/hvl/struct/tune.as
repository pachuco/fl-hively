package hvl.struct {
    import hvl.cons;
    
    public class tune{
        public var
            Name:String,                              //TEXT[128]
            SongNum:uint,                             //uint16
            Frequency:uint,                           //uint32
            FreqF:Number,                             //float64
            WaveformTab:Vector.<uint>,                //*int8[MAX_CHANNELS]
            WaveformTab_i2:Vector.<int>,
            Restart:uint,                             //uint16
            PositionNr:uint,                          //uint16
            SpeedMultiplier:uint,                     //uint8
            TrackLength:uint,                         //uint8
            TrackNr:uint,                             //uint8
            InstrumentNr:uint,                        //uint8
            SubsongNr:uint,                           //uint8
            PosJump:uint,                             //uint16
            PlayingTime:uint,                         //uint32
            Tempo:int,                                //int16
            PosNr:int,                                //int16
            StepWaitFrames:int,                       //int16
            NoteNr:int,                               //int16
            PosJumpNote:uint,                         //uint16
            GetNewPosition:uint,                      //uint8
            PatternBreak:uint,                        //uint8
            SongEndReached:uint,                      //uint8
            Stereo:uint,                              //uint8
            Subsongs:Vector.<uint>,                   //*uint16
            Channels:uint,                            //uint16
            Positions:Vector.<position>,          //struct hvl_position *ht_Positions;
            Tracks:Vector.<step>,                 //hvl_step[256][64]
            Instruments:Vector.<instrument>,      //struct hvl_instrument *ht_Instruments;
            Voices:Vector.<voice>,                //hvl_voice[MAX_CHANNELS]
            defstereo:int,                            //int32
            defpanleft:int,                           //int32
            defpanright:int,                          //int32
            mixgain:int,                              //int32
            Version:uint,                             //uint8
            
            VUMeters:Vector.<int>,
            FormatString:String;
        
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
        
        public function malloc_positions( ind:uint ):void{
            for(var i:uint=0;i<ind;i++){
                Positions.push(new position());
            }
        }
        
        public function malloc_instruments( ind:uint ):void{
            for(var i:uint=0;i<=ind;i++){
                Instruments.push(new instrument());
            }
        }
        
        public function malloc_subsongs( ind:uint ):void{
            Subsongs = new Vector.<uint>(ind, true);
        }
    }
}