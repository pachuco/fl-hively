package hvl {
    public class plist{
        public var
            Speed:int,                        //int16
            Length:int,                       //int16
            Entries:Vector.<plsentry>;    //struct hvl_plsentry *pls_Entries;
        
        public function plist(){
            Entries = new Vector.<plsentry>;
        }

        internal function ple_malloc( len:uint ):void{
            for( var i:uint=0; i<len; i++ ){
                var ple:plsentry = new plsentry();
                Entries.push( ple );
            }
        }
    }
}