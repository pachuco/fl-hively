package replay_hively {
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    
    public class front_panel{
        private const buf_size:uint = 4092 * 8;
        
        private var ht:hvl_tune;
        private var replayer:hvl_replay;
        private var is_playing:Boolean;
        private var resume_position:uint;
        private var resume_step:uint;
        private var audio_out:Sound;
        private var sc:SoundChannel;
        
        public function front_panel():void{
            replayer = new hvl_replay();
            audio_out = new Sound();
        }

        public function load( ba:ByteArray, stereo_separation:uint = 4 ):Boolean {
            this.pause();
            ba.endian = Endian.LITTLE_ENDIAN;
            ht = replayer.hvl_LoadTune( ba, stereo_separation );
            return true;
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
        
        public function stop(     ):void {
            this.pause();
            replayer.hvl_InitSubsong(ht, 0);
        }

        public function seek(     ):void{
        
        }

        public function fade_in(     ):void{
        
        }

        public function fade_out(     ):void{
        
        }
        
        
        private function audio_loop( event:SampleDataEvent ):void {
            if ( is_playing ) {
                while (event.data.position <= buf_size ){
                    replayer.hvl_DecodeFrame( ht, event.data );
                }
            }
        }
        
        public function getwaves():ByteArray {
            return replayer.getdemwaves();
        }
    }
}