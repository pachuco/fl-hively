package hvl {
    public class instrument{
        public var
            Name:String,                             //TEXT[128]
            Volume:uint,                             //uint8
            WaveLength:uint,                         //uint8
            FilterLowerLimit:uint,                   //uint8
            FilterUpperLimit:uint,                   //uint8
            FilterSpeed:uint,                        //uint8
            SquareLowerLimit:uint,                   //uint8
            SquareUpperLimit:uint,                   //uint8
            SquareSpeed:uint,                        //uint8
            VibratoDelay:uint,                       //uint8
            VibratoSpeed:uint,                       //uint8
            VibratoDepth:uint,                       //uint8
            HardCutRelease:uint,                     //uint8
            HardCutReleaseFrames:uint,               //uint8
            Envelope:envelope,                   //
            PList:plist;                         //
        
        public function instrument(){
            Envelope = new envelope();
            PList = new plist();
        }
    }
}