package replay_hively {
    public class hvl_plsentry{
        public var ple_Note:uint;               //uint8
        public var ple_Waveform:uint;           //uint8
        public var ple_Fixed:int;               //int16
        public var ple_FX:Vector.<int>;         //int8
        public var ple_FXParam:Vector.<int>;    //int8
        
        public function hvl_plsentry():void{
            ple_FX = Vector.<int>( 2, true );
            ple_FXParam = Vector.<int>( 2, true );
        }
    }
}