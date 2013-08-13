package hvl {
    internal class instrument{
        internal var ins_Name:String;                             //TEXT[128]
        internal var ins_Volume:uint;                             //uint8
        internal var ins_WaveLength:uint;                         //uint8
        internal var ins_FilterLowerLimit:uint;                   //uint8
        internal var ins_FilterUpperLimit:uint;                   //uint8
        internal var ins_FilterSpeed:uint;                        //uint8
        internal var ins_SquareLowerLimit:uint;                   //uint8
        internal var ins_SquareUpperLimit:uint;                   //uint8
        internal var ins_SquareSpeed:uint;                        //uint8
        internal var ins_VibratoDelay:uint;                       //uint8
        internal var ins_VibratoSpeed:uint;                       //uint8
        internal var ins_VibratoDepth:uint;                       //uint8
        internal var ins_HardCutRelease:uint;                     //uint8
        internal var ins_HardCutReleaseFrames:uint;               //uint8
        internal var ins_Envelope:envelope;                   //
        internal var ins_PList:plist;                         //
        
        public function instrument():void{
            ins_Envelope = new envelope();
            ins_PList = new plist();
        }
    }
}