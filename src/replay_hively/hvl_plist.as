package replay_hively {
    public class hvl_plist{
        public var pls_Speed:int;               //int16
        public var pls_Length:int;              //int16
        public var pls_Entries:hvl_plsentry;    //struct hvl_plsentry *pls_Entries;
        
        public function hvl_plist():void{
            //pls_Entries = new hvl_plsentry();
        }
    }
}