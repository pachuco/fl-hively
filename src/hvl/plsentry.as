package hvl {
    public class plsentry{
        public var
            Note:uint,               //uint8
            Waveform:uint,           //uint8
            Fixed:int,               //int16
            FX:Vector.<int>,         //int8
            FXParam:Vector.<int>;    //int8
        
        public function plsentry(){
            FX = new Vector.<int>( 2, true );
            FXParam = new Vector.<int>( 2, true );
        }
    }
}