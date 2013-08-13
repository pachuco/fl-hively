package replay_hively {
    internal class hvl_plist{
        internal var pls_Speed:int;                        //int16
        internal var pls_Length:int;                       //int16
        internal var pls_Entries:Vector.<hvl_plsentry>;    //struct hvl_plsentry *pls_Entries;
        
        public function hvl_plist():void{
            pls_Entries = new Vector.<hvl_plsentry>;
        }

        internal function ple_malloc( len:uint ):void{
            for( var i:uint=0; i<len; i++ ){
                var ple:hvl_plsentry = new hvl_plsentry();
                pls_Entries.push( ple );
            }
        }
    }
}