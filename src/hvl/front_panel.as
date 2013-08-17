package hvl {
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    
    public class front_panel{
        private const buf_size:uint = 4092 * 8;
        
        private var ht:tune;
        private var subsong:uint;
        private var replayer:replay;
        private var is_playing:Boolean;
        private var resume_position:uint;
        private var resume_step:uint;
        private var audio_out:Sound;
        private var sc:SoundChannel;
        
        public function front_panel():void{
            replayer = new replay();
            audio_out = new Sound();
        }

        public function load( ba:ByteArray, stereo_separation:uint = 4 ):Boolean {
            ht = null;
            subsong = 0;
            ba.endian = Endian.LITTLE_ENDIAN;
            ht = replayer.LoadTune( ba, stereo_separation );
            if (ht) {
                return true;
            }else {
                return false;
            }
            
        }
        
        public function init_subsong( nr:uint ):Boolean {
            if (ht) {
                return replayer.InitSubsong( ht, nr );
            }else {
                return false;
            }
        }
        
        public function unload():void{
            
        }

        public function play():void {
            if( true ){     //if( !is_playing )
                if( ht ){
                    is_playing = true;
                    audio_out.addEventListener(SampleDataEvent.SAMPLE_DATA, audio_loop);
                    sc = audio_out.play();
                }else{
                    
                }
            }
        }

        public function pause(     ):void {
            if ( is_playing ) {
                sc.stop();
            }
            is_playing = false;
        }
        
        public function stop():void {
            this.pause();
            replayer.InitSubsong(ht, ht.SongNum);
        }
        //! @param p_time target time in seconds.
        //virtual void playback_seek(double p_time) = 0;
        public function seek(     ):void{
        
        }

        public function fade_in(     ):void{
        
        }

        public function fade_out(     ):void{
        
        }
        
        public function get_VUmeter(index:uint):uint {
            return ht.Voices[index].VUMeter;
        }

        public function decrement_VUmeters(factor:Number):void {
            var i:uint;
            for (i = 0; i < ht.Channels; i++ ) {
                ht.Voices[i].VUMeter /=factor;
            }
        }
        
        public function get voice_number():int {
            if(ht){
                return ht.Channels;
            }else {
                return -1;
            }
        }
        
        public function get format():String{
            return ht.FormatString;
        }
        
        public function get sample_names():Vector.<String>{
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
        
        public function get song_title():String{
            if(ht){
                return ht.Name;
            }else {
                return "";
            }
        }
        
        public function get subsong_number():int{
            if(ht){
                return ht.SubsongNr;
            }else {
                return -1;
            }
        }
        
        public function get subsong_current():int{
            if(ht){
                return ht.SongNum;
            }else {
                return -1;
            }
        }
        
        //in seconds
        public function get total_time():Number{
            if(ht){
                var safety:uint = 2 * 60 * 60 * 50 * ht.SpeedMultiplier; // 2 hours, just like foo_dumb
                
                while ( ! ht.SongEndReached && safety ){
                    replayer.play_irq( ht, false );
                    --safety;
                }
                var temp:Number = ht.PlayingTime / ht.SpeedMultiplier / 50;
                replayer.InitSubsong(ht, ht.SongNum);
                return temp;
            }else {
                return NaN;
            }
        }
        
        public function get current_time():Number{
            if (ht) {
                return ht.PlayingTime / ht.SpeedMultiplier / 50;
            }else {
                return -1;
            }
        }
        
        public function get song_playing():Boolean{
            return is_playing;
        }
        
        
        private function audio_loop( event:SampleDataEvent ):void{
            if ( is_playing ) {
                while (event.data.position <= buf_size ){
                    replayer.DecodeFrame( ht, event.data );
                }
            }
        }
        
        //public function get getwaves():ByteArray {
            //return replayer.getdemwaves();
        //}
    }
}