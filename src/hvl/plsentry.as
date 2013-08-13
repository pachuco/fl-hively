package hvl {
    internal class plsentry{
        internal var Note:uint;               //uint8
        internal var Waveform:uint;           //uint8
        internal var Fixed:int;               //int16
        internal var FX:Vector.<int>;         //int8
        internal var FXParam:Vector.<int>;    //int8
        
        public function plsentry():void{
            FX = new Vector.<int>( 2, true );
            FXParam = new Vector.<int>( 2, true );
        }
    }
}