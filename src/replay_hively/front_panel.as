package replay_hively {
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.utils.Endian;
    import flash.utils.ByteArray;
    
    public class front_panel{
        private const buf_size:uint = 4092;
        
        private var ht:hvl_tune;
		private var replayer:hvl_replay;
        private var is_playing:Boolean;
        private var resume_position:uint;
        private var resume_step:uint;
        
        public function front_panel():void{
			replayer = new hvl_replay();
        }

        public function load( ba:ByteArray ):Boolean {
			is_playing = false;
			ba.endian = Endian.LITTLE_ENDIAN;
            ht = replayer.hvl_LoadTune( ba, 0 );
			return true;
        }
        
        public function unload():void{
            
        }

        public function play():void {
			//leave this here for fun
			if( true ){		//!is_playing
				if( ht ){
					is_playing = true;
					var audio_out:Sound = new Sound();
					audio_out.addEventListener(SampleDataEvent.SAMPLE_DATA, audio_loop);
					audio_out.play();
				}else{
					
				}
			}
        }

        public function pause(     ):void{
            is_playing = false;
        }
        
        public function stop(     ):void{
            is_playing = false;
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
                while (event.data.position <= buf_size*8 ){
                    replayer.hvl_DecodeFrame( ht, event.data );
                }
            }
        }
    }
}