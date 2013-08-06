package replay_hively {
    public class hvl_plist{
        public var pls_Speed:int;                        //int16
        public var pls_Length:int;                       //int16
        public var pls_Entries:Vector.<hvl_plsentry>;    //struct hvl_plsentry *pls_Entries;
        
        public function hvl_plist():void{
            pls_Entries = new Vector.<hvl_plsentry>;
        }

        public function ple_malloc( len:uint ):void{
            for( var i:uint=0; i<len; i++ ){
                var ple:hvl_plsentry = new hvl_plsentry();
                pls_Entries.push( ple );
            }
        }
    }
}