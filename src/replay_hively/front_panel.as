package replay_hively {
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
    import flash.utils.ByteArray;
    
    public class front_panel{
        private var ht:hvltune;
        private var is_playing:Boolean;
        private var resume_position:uint;
        private var resume_step:uint;
        
        private var audio_out:Sound;
        
        public function front_panel():void{
            audio_out = new Sound();
        }

        public function load( ba:ByteArray ):Boolean{
            ht = hvl_replayer.hvl_load_tune( ba, 0 );
        }
        
        public function unload(){
            
        }

        public function play():void{
            if( ht ){
                audio_out.addEventListener(SampleDataEvent.SAMPLE_DATA, audio_loop);
                audio_out.play();
                is_playing = true;
            }else{
                
            }
        }

        public function pause(     ):void{
            is_playing = false;
        }
        
        public function stop(     ):void{
            is_playing = false;
        }

        public function seek(     ):void{
        
        }

        public function fade_in(     ):void{
        
        }

        public function fade_out(     ):void{
        
        }
        
        
        private function audio_loop( event:SampleDataEvent ):void{
            
        }
    }
}