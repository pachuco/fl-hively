package hvl {
    internal class instrument{
        internal var Name:String;                             //TEXT[128]
        internal var Volume:uint;                             //uint8
        internal var WaveLength:uint;                         //uint8
        internal var FilterLowerLimit:uint;                   //uint8
        internal var FilterUpperLimit:uint;                   //uint8
        internal var FilterSpeed:uint;                        //uint8
        internal var SquareLowerLimit:uint;                   //uint8
        internal var SquareUpperLimit:uint;                   //uint8
        internal var SquareSpeed:uint;                        //uint8
        internal var VibratoDelay:uint;                       //uint8
        internal var VibratoSpeed:uint;                       //uint8
        internal var VibratoDepth:uint;                       //uint8
        internal var HardCutRelease:uint;                     //uint8
        internal var HardCutReleaseFrames:uint;               //uint8
        internal var Envelope:envelope;                   //
        internal var PList:plist;                         //
        
        public function instrument():void{
            Envelope = new envelope();
            PList = new plist();
        }
    }
}