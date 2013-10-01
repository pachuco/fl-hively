package hvl {
    internal class instrument{
        public var Name:String;                             //TEXT[128]
        public var Volume:uint;                             //uint8
        public var WaveLength:uint;                         //uint8
        public var FilterLowerLimit:uint;                   //uint8
        public var FilterUpperLimit:uint;                   //uint8
        public var FilterSpeed:uint;                        //uint8
        public var SquareLowerLimit:uint;                   //uint8
        public var SquareUpperLimit:uint;                   //uint8
        public var SquareSpeed:uint;                        //uint8
        public var VibratoDelay:uint;                       //uint8
        public var VibratoSpeed:uint;                       //uint8
        public var VibratoDepth:uint;                       //uint8
        public var HardCutRelease:uint;                     //uint8
        public var HardCutReleaseFrames:uint;               //uint8
        public var Envelope:envelope;                   //
        public var PList:plist;                         //
        
        public function instrument(){
            Envelope = new envelope();
            PList = new plist();
        }
    }
}