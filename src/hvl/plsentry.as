package hvl {
    internal class plsentry{
        public var Note:uint;               //uint8
        public var Waveform:uint;           //uint8
        public var Fixed:int;               //int16
        public var FX:Vector.<int>;         //int8
        public var FXParam:Vector.<int>;    //int8
        
        public function plsentry():void{
            FX = new Vector.<int>( 2, true );
            FXParam = new Vector.<int>( 2, true );
        }
    }
}