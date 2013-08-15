package hvl {
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    
    public class front_panel{
        private const buf_size:uint = 4092 * 8;
        
        private var ht:tune;
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
            this.pause();
            ba.endian = Endian.LITTLE_ENDIAN;
            ht = replayer.LoadTune( ba, stereo_separation );
            return true;
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
        
        public function stop(     ):void {
            this.pause();
            replayer.InitSubsong(ht, 0);
        }

        public function seek(     ):void{
        
        }

        public function fade_in(     ):void{
        
        }

        public function fade_out(     ):void{
        
        }
        
        public function get sample_names():Vector.<String> {
            var temp:Vector.<String> = new Vector.<String>(ht.InstrumentNr+1, true);
            for (var i:uint = 1; i <= ht.InstrumentNr; i++ ) {
                temp[i] = ht.Instruments[i].ins_Name;
            }
            return temp;
        }
        
        public function get song_title():String {
            return ht.Name;
        }
        
        public function get subsong_number():uint {
            return ht.SubsongNr;
        }
        
        
        private function audio_loop( event:SampleDataEvent ):void {
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