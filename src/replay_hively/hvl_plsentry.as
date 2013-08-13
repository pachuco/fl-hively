package replay_hively {
    internal class hvl_plsentry{
        internal var ple_Note:uint;               //uint8
        internal var ple_Waveform:uint;           //uint8
        internal var ple_Fixed:int;               //int16
        internal var ple_FX:Vector.<int>;         //int8
        internal var ple_FXParam:Vector.<int>;    //int8
        
        public function hvl_plsentry():void{
            ple_FX = new Vector.<int>( 2, true );
            ple_FXParam = new Vector.<int>( 2, true );
        }
    }
}