package hvl {
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    
    public class front_panel{
        private var buf_size:uint = 4092;
        private var is_playing:Boolean;
        private var framerate:uint;
        
        private var ht:tune;
        private var subsong:uint;
        private var replayer:replay;
        private var tune_length:Number;
        private var audio_out:Sound;
        private var sc:SoundChannel;
        
        /**Constructor.*/
        public function front_panel():void {
            replayer = new replay();
            audio_out = new Sound();
        }
        
        /**Load AHX/HVL tune and init subsong 0.*/
        public function com_loadTune( ba:ByteArray, stereo_separation:uint = 4 ):Boolean {
            ht = null;
            tune_length = NaN;
            subsong = 0;
            ba.endian = Endian.LITTLE_ENDIAN;
            ht = replayer.LoadTune( ba, stereo_separation );
            trace(50 * ht.SpeedMultiplier);
            if (ht) {
                return true;
            }else {
                return false;
            }
            
        }
        
        /**Inits selected subsong.*/
        public function com_initSubsong( nr:uint ):Boolean {
            if (ht) {
                tune_length = NaN;
                return replayer.InitSubsong( ht, nr );
            }else {
                return false;
            }
        }
        
        /**Discard loaded tune.*/
        public function com_unloadTune():void {
            com_stop();
            tune_length = NaN;
            ht = null;
            subsong = 0;
        }
        
        /**Start playback.*/
        public function com_play():void {
            if( true ){     //if( !is_playing )
                if( ht ){
                    is_playing = true;
                    audio_out.addEventListener(SampleDataEvent.SAMPLE_DATA, audio_loop);
                    sc = audio_out.play();
                }else{
                    
                }
            }
        }
        
        /**Stop playback but keep position.*/
        public function com_pause(     ):void {
            if ( is_playing ) {
                sc.stop();
            }
            is_playing = false;
        }
        
        /**Stop playback and reset position to 0.*/
        public function com_stop():void {
            com_pause();
            replayer.InitSubsong(ht, ht.SongNum);
        }

        /**Seek trough tune by x seconds.*/
        public function com_seek( time:Number ):void {
            var frame:uint = tools.time_to_samples( time, 50 * ht.SpeedMultiplier );
            if ( ht.PlayingTime > frame ){
                replayer.InitSubsong( ht, ht.SongNum );
            }
            while ( ht.PlayingTime < (frame%info_tuneLength) ) {
                //<del>We sacrifice accuracy for speed :(</del> Hell no! We sacrifice speed for accuracy.
                //Unless a trick is discovered. Inb4 using flascc instead of AS3.
                //I am not exactly fond of precompiled libs and would rather work with full source, in one language.
                replayer.play_irq( ht, true );
            }
        }
        
        /**Total number of channels.*/
        public function get info_channels():int {
            if(ht){
                return ht.Channels;
            }else {
                return 0;
            }
        }
        
        /**String with tune format and version.*/
        public function get info_format():String{
            return ht.FormatString;
        }
        
        /**Vector of all sample names.*/
        public function get info_sampleNames():Vector.<String>{
            if(ht){
                var temp:Vector.<String> = new Vector.<String>(ht.InstrumentNr, true);
                for (var i:uint = 1; i <= ht.InstrumentNr; i++ ) {
                    temp[i-1] = ht.Instruments[i].ins_Name;
                }
                return temp;
            }else {
                return null;
            }
        }
        
        /**Song title.*/
        public function get info_title():String {
            return ht?ht.Name:"";
        }
        
        /**Total number of subsongs.*/
        public function get info_subsongNr():int {
            return ht?ht.SubsongNr:-1;
        }
        
        /**Tune length in seconds.*/
        public function get info_tuneLength():Number{
            if (ht) {
                if (isNaN(tune_length)) {
                    var safety:uint = 2 * 60 * 60 * 50 * ht.SpeedMultiplier; // 2 hours, just like foo_dumb
                    while ( ! ht.SongEndReached && safety ){
                        replayer.play_irq( ht, false );
                        --safety;
                    }
                    var temp:Number = ht.PlayingTime / ht.SpeedMultiplier / 50;
                    replayer.InitSubsong(ht, ht.SongNum);
                    tune_length = temp;
                    return temp;
                }else {
                    return tune_length;
                }
            }else {
                return NaN;
            }
        }
        
        /**Number of currently loaded subsong.*/
        public function get cur_subsong():int{
            return ht?ht.SongNum:-1;
        }
        
        /**Current playtime in seconds.*/
        public function get cur_playTime():Number{
            return ht?ht.PlayingTime / ht.SpeedMultiplier / 50:-1
        }
        
        /**Is the player active?*/
        public function get cur_isPlaying():Boolean{
            return is_playing;
        }
        
        /**Has a tune been loaded?*/
        public function get cur_isLoaded():Boolean{
            return ht?true:false;
        }
        
        /**Length of audio buffer in float samples(not bytes).*/
        public function get cur_bufLength():uint{
            return buf_size;
        }
        
        /**Get reference to VU meter Vector.*/
        public function get_VUmeters():Vector.<int> {
            return ht?ht.VUMeters:null;
        }
        
        private function audio_loop( event:SampleDataEvent ):void{
            if ( is_playing ) {
                //VU_delay = ((event.data.position / 44.1) - sc.position);
                while (event.data.position <= buf_size * 8 ){
                    replayer.DecodeFrame( ht, event.data );
                }
            }
        }
        
        /**Get ByteArray of precalculated waveforms.*/
        //public function get getwaves():ByteArray {
            //return replayer.getdemwaves();
        //}
    }
}