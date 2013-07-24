package replay_hively {
    public class hvl_plist{
        public var pls_Speed:int;                        //int16
        public var pls_Length:int;                       //int16
        public var pls_Entries:Vector.<hvl_plsentry>;    //struct hvl_plsentry *pls_Entries;
        
        public function hvl_plist():void{
            pls_Entries = Vector.<hvl_plsentry>;
        }

        public function feed_me( ba:ByteArray, off:uint ):void{
            ba.position = off;
            pls_Speed = ba.readShort();
            pls_Length = ba.readShort();
            for( var i:uint=0; i<pls_Length; i++ ){
                var ple = new hvl_plsentry();
                ple.ple_Note        = ba.readUnsignedByte();
                ple.ple_Waveform    = ba.readUnsignedByte();
                ple.ple_Fixed       = ba.readShort();
                ple.ple_FX[0]       = ba.readByte();
                ple.ple_FX[1]       = ba.readByte();
                ple.ple_FXParam[0]  = ba.readByte();
                ple.ple_FXParam[1]  = ba.readByte();
                pls_Entries.push( ple );
            }
        }
    }
}