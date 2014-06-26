package hvl {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    
    import hvl.struct.*;

    
    public class front_panel extends EventDispatcher{
        private var buf_size:uint = 4092;
        private var is_playing:Boolean;
        private var start_dispatched:Boolean;
        private var latencyMs:int = -1;
        private var stereo:uint = 4;
        
        private var ht:tune;
        private var subsong:uint;
        private var replayer:replay;
        private var tune_length:Number = new Number(-1);
        private var audio_out:Sound;
        private var sc:SoundChannel;
        
        public static const evt_playerInit:String  = "hvl_playerInit";
        public static const evt_tuneLoad:String    = "hvl_tuneLoad";
        //public static const evt_subtuneInit:String = "hvl_subtuneInit";
        public static const evt_tuneUnload:String  = "hvl_tuneUnload";
        public static const evt_audioStart:String  = "hvl_audioStart";
        public static const evt_audioStop:String   = "hvl_audioStop";
        
        /**Constructor.*/
        public function front_panel() {
            replayer = new replay();
            audio_out = new Sound();
            dispatchEvent(new Event(evt_playerInit));
        }
        
        /**Load AHX/HVL tune and init subsong 0.*/
        public function com_loadTune( ba:ByteArray):Boolean {
            ht = null;
            tune_length = -1;
            subsong = 0;
            ba.endian = Endian.LITTLE_ENDIAN;
            ht = replayer.LoadTune( ba, stereo );
            if (ht) {
                dispatchEvent(new Event(evt_tuneLoad));
                return true;
            }else {
                return false;
            }
            
        }
        
        /**Inits selected subsong.*/
        public function com_initSubsong( nr:uint ):Boolean {
            if (ht) {
                tune_length = -1;
                //dispatchEvent(new Event(evt_subtuneInit));
                return replayer.InitSubsong( ht, nr );
            }else {
                return false;
            }
        }
        
        /**Discard loaded tune.*/
        public function com_unloadTune():void {
            com_stop();
            tune_length = -1;
            ht = null;
            subsong = 0;
            dispatchEvent(new Event(evt_tuneUnload));
        }
        
        /**Start playback.*/
        public function com_play():void {
            if( !is_playing ){
                if( ht ){
                    is_playing = true;
                    audio_out.addEventListener(SampleDataEvent.SAMPLE_DATA, audio_loop);
                    sc = audio_out.play();
                }else{
                    
                }
            }
        }
        
        /**Like com_play(), except it doesn't care if current song is already playing. Press play multiple times for psychedelic effect.*/
        public function funky_play():void {
            if( true ){
                if( ht ){
                    is_playing = true;
                    audio_out.addEventListener(SampleDataEvent.SAMPLE_DATA, audio_loop);
                    sc = audio_out.play();
                }else{
                    
                }
            }
        }
        
        /**Stop playback but keep position.*/
        public function com_pause( ):void {
            if ( is_playing ) {
                sc.stop();
                latencyMs = -1;
                dispatchEvent(new Event(evt_audioStop));
            }
            is_playing = false;
        }
        
        /**Stop playback and reset position to 0.*/
        public function com_stop():void {
            if(ht){
                com_pause();
                latencyMs = -1;
                replayer.InitSubsong(ht, ht.SongNum);
                dispatchEvent(new Event(evt_audioStop));
            }
        }

        /**Seek trough tune by time, in seconds.*/
        public function com_seekTime( time:Number ):void {
            var frame:uint = tools.time_to_samples( time, 50 * ht.SpeedMultiplier );
            if ( ht.PlayingTime > frame ){
                replayer.InitSubsong( ht, ht.SongNum );
            }
            while ( ht.PlayingTime < frame ) {
                //<del>Let's hope this doesn't break tunes up</del> Yes it does.
                //Renderless seeking, even with reset does break stuff.
                replayer.play_irq( ht, true );
                replayer.reset_some_stuff( ht );
            }
        }
        
        /**Seek trough tune by position and row. Faster seeking, but might not land you where you want if song uses pattern break/position jump effects.*/
        public function com_seekPos( posNr:uint, noteNr:uint = 0 ):void {
            if (ht) {
                replayer.reset_some_stuff( ht );
                ht.PosNr = posNr;
                ht.NoteNr = noteNr;
            }
        }
        
        /**Length of track in rows.*/
        public function get info_trackLength():int {
            return ht?ht.TrackLength:-1;
        }
        /**Number of positions.*/
        public function get info_positionNr():int {
            return ht?ht.PositionNr:-1;
        }
        
        /**Total number of channels.*/
        public function get info_channels():int {
            return ht?ht.Channels:-1;
        }
        
        /**String with tune format and version.*/
        public function get info_format():String{
            return ht?ht.FormatString:"";
        }
        
        /**Number of samples.*/
        public function get info_instrumentNr():int {
            return ht?ht.InstrumentNr:-1;
        }
        
        /**Vector of all sample names.*/
        public function get info_instrumentNames():Vector.<String>{
            if(ht){
                var temp:Vector.<String> = new Vector.<String>(ht.InstrumentNr, true);
                for (var i:uint = 1; i <= ht.InstrumentNr; i++ ) {
                    temp[i-1] = ht.Instruments[i].Name;
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
                if (tune_length<0) {
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
                return -1;
            }
        }
        /**Audio latency in miliseconds. This changes frequently, so keep that in mind.*/
        public function get cur_latencyMs():int {
            return sc?latencyMs:-1;
        }
        
        /**Current position in song. Playback tracking.*/
        public function get cur_positionNr():int {
            return ht?ht.PosNr:-1;
        }
                
        /**Current row in current position in song. Playback tracking.*/
        public function get cur_noteNr():int {
            return ht?ht.NoteNr:-1;
        }
        
        /**Has song's end been reached?*/
        public function get cur_isSongEnd():int {
            return ht?ht.SongEndReached:-1;
        }
        
        /**Number of currently loaded subsong.*/
        public function get cur_subsong():int{
            return ht?ht.SongNum:-1;
        }
        
        /**Current playtime in seconds.*/
        public function get cur_playTime():Number{
            return ht?ht.PlayingTime / ht.SpeedMultiplier / 50: -1;
        }
        
        /**Current playtime in seconds, wrapped acording to looping information.*/
        //public function get cur_playTimeWrapped():Number {
        //    ht.PositionNr
        //    return ht?ht.PlayingTime / ht.SpeedMultiplier / 50:-1;
        //}
        
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
        
        /**Set panning from 0 to 4. Only applies to AHX.*/
        public function set panning(pan:uint):void {
            stereo = pan;
            if (ht && pan <= 4) {
                replayer.setPan(ht, pan);
            }
        }
        
        /**Get reference to VU meter Vector.*/
        public function get_VUmeters():Vector.<int> {
            return ht?ht.VUMeters:null;
        }
        
        /**Get ByteArray of precalculated waveforms.*/
        public function get waves():ByteArray {
            var bat:ByteArray = new ByteArray();
            //for (var i:uint = 0; i < cons.WAVES_SIZE; i++) {
            //    bat[i] = replayer.waves[i];
            //}
            //return bat;
            return replayer.waves_t;
        }
        
        /**Return reference to loaded tune, if you want to skip the API and work directly with it.*/
        public function get htune():tune {
            return ht?ht:null;
        }
        
        
        
        
        private function audio_loop( event:SampleDataEvent ):void{
            if ( is_playing ) {
                if (sc) {
                    latencyMs = ((event.position / 44.1) - sc.position);
                    if (!start_dispatched) {
                        dispatchEvent(new Event(evt_audioStart));
                        start_dispatched = true;
                    }
                }
                while (event.data.position <= buf_size * 8 ){
                    replayer.DecodeFrame( ht, event.data );
                }
            }else {
                start_dispatched = false;
            }
        }
    }
}