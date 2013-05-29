package replay_hively {
    import flash.events.*;
    import flash.media.*;
    import flash.utils.*;
    public class hvl_replay{
        private var waves_t:ByteArray = new ByteArray();
        private var waves:Vector.<int> = new Vector.<int>( cons.WAVES_SIZE, true );
        private var panning_left:Vector.<uint> = new Vector.<uint>( 256, true );
        private var panning_right:Vector.<uint> = new Vector.<uint>( 256, true );
        
        public function hvl_replay():void{
            hvl_GenPanningTables();
            hvl_GenSawtooth( cons.WO_SAWTOOTH_04, 0x04 );
            hvl_GenSawtooth( cons.WO_SAWTOOTH_08, 0x08 );
            hvl_GenSawtooth( cons.WO_SAWTOOTH_10, 0x10 );
            hvl_GenSawtooth( cons.WO_SAWTOOTH_20, 0x20 );
            hvl_GenSawtooth( cons.WO_SAWTOOTH_40, 0x40 );
            hvl_GenSawtooth( cons.WO_SAWTOOTH_80, 0x80 );
            hvl_GenTriangle( cons.WO_TRIANGLE_04, 0x04 );
            hvl_GenTriangle( cons.WO_TRIANGLE_08, 0x08 );
            hvl_GenTriangle( cons.WO_TRIANGLE_10, 0x10 );
            hvl_GenTriangle( cons.WO_TRIANGLE_20, 0x20 );
            hvl_GenTriangle( cons.WO_TRIANGLE_40, 0x40 );
            hvl_GenTriangle( cons.WO_TRIANGLE_80, 0x80 );
            hvl_GenSquare( cons.WO_SQUARES );
            hvl_GenWhiteNoise( cons.WO_WHITENOISE, cons.WHITENOISELEN );
            hvl_GenFilterWaves( cons.WO_TRIANGLE_04, cons.WO_LOWPASSES, cons.WO_HIGHPASSES );
            var i:uint;
            for(i=0; i<cons.WAVES_SIZE; i++){
                //we work with ByteArray and transfer to Vector.<int> after
                //because of some accuracy issues for working directly
                //with Vector.<int>
                //Why? no bloody idea.
                waves[i]=tools.ui2i8(waves_t[i]);
                //There is no point in using tools.ui2i8() to access our waves
                //every bloody time.
            }
            //waves_t=null;
        }
        
        public function getdemwaves():ByteArray{
            return waves_t;
        }
        
        private function Period2Freq(period:int):Number{
            return 3546897.0 * 65536.0 / period;
        }
        
        private function hvl_GenPanningTables():void{
            var i:uint;
            var aa:Number, ab:Number;

            // Sine based panning table
            aa = (3.14159265*2.0)/4.0;     // Quarter of the way through the sinewave == top peak
            ab = 0.0;                      // Start of the climb from zero

            for( i=0; i<256; i++ ){
                panning_left[i]  = uint(Math.sin(aa)*255.0);
                panning_right[i] = uint(Math.sin(ab)*255.0);

                aa += (3.14159265*2.0/4.0)/256.0;
                ab += (3.14159265*2.0/4.0)/256.0;
            }
            panning_left[255] = 0;
            panning_right[0] = 0;
        }
        
        private function hvl_GenSawtooth( buf:uint, len:uint ):void{
            var i:uint;
            var val:int, add:int;

            add = 256 / (len-1);
            val = -128;

            for( i=0; i<len; i++, val += add )
                waves_t[buf++] = int(val);  
        }
        
        private function hvl_GenTriangle( buf:uint, len:uint ):void{
            var i:uint;
            var d2:int, d5:int, d1:int, d4:int;
            var val:int;
            var buf2:uint;

            d2  = len;
            d5  = len >> 2;
            d1  = 128/d5;
            d4  = -(d2 >> 1);
            val = 0;

            for( i=0; i<d5; i++ ){
                waves_t[buf++] = val;
                val += d1;
            }
            waves_t[buf++] = 0x7f;

            if( d5 != 1 ){
                val = 128;
                for( i=0; i<d5-1; i++ ){
                    val -= d1;
                    waves_t[buf++] = val;
                }
            }

            buf2 = buf + d4;
            for( i=0; i<d5*2; i++ ){
                var c:int;

                c = waves_t[buf2++];
                if( c == 0x7f ){
                    c = 0x80;
                }else{
                    c = -c;
                }
                waves_t[buf++] = c;
            }
        }
        
        private function hvl_GenSquare( buf:uint ):void{
            var i:uint, j:uint;

            for( i=1; i<=0x20; i++ ){
                for( j=0; j<(0x40-i)*2; j++ ){
                    waves_t[buf++] = 0x80;
                }
                for( j=0; j<i*2; j++ ){
                    waves_t[buf++] = 0x7f;
                }
            }
        }
        
        private function clip( x:Number ):Number{
            if( x > 127.0 ){
                x = 127.0;
            }else if( x < -128.0 ){
                x = -128.0;
            }
            return x;
        }
        
        private function hvl_GenFilterWaves( buf:uint, lowbuf:uint, highbuf:uint ):void{
            const lentab:Vector.<uint> = Vector.<uint>([
                3, 7, 0xf, 0x1f, 0x3f, 0x7f, 3, 7, 0xf, 0x1f, 0x3f, 0x7f,
                0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,
                0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,
                (0x280*3)-1 ]);

            var freq:Number;
            var temp:uint;

            for( temp=0, freq=8.0; temp<31; temp++, freq+=3.0 ){
                var wv:uint;
                var a0:uint = buf;

                for( wv=0; wv<6+6+0x20+1; wv++ ){
                    var fre:Number, high:Number, mid:Number, low:Number;
                    var i:uint;

                    mid = 0.0;
                    low = 0.0;
                    fre = freq * 1.25 / 100.0;

                    for( i=0; i<=lentab[wv]; i++ ){
                        high  = tools.ui2i8(waves_t[a0+i]) - mid - low;
                        high  = clip( high );
                        mid  += high * fre;
                        mid   = clip( mid );
                        low  += mid * fre;
                        low   = clip( low );
                    }

                    for( i=0; i<=lentab[wv]; i++ ){
                        high  = tools.ui2i8(waves_t[a0+i]) - mid - low;
                        high  = clip( high );
                        mid  += high * fre;
                        mid   = clip( mid );
                        low  += mid * fre;
                        low   = clip( low );
                        waves_t[lowbuf++]  = int(low);
                        waves_t[highbuf++] = int(high);
                    }

                    a0 += lentab[wv]+1;

                }
            }
        }

        private function hvl_GenWhiteNoise( buf:uint, len:uint ):void{
            var ays:uint;

            ays = 0x41595321;

            do{
                var ax:uint, bx:uint; //uint16
                var s:int; //int8

                s = ays & 0xff;

                if( ays & 0x100 )
                {
                s = 0x80;

                if((ays & 0xffff) >= 0 )
                s = 0x7f;
                }

                waves_t[buf++] = s;
                len--;
                
                //ays = (ays >> 5) | (ays << 27);
                ays = tools.bitRotate(ays, 5, 32);
                ays = (ays & 0xffffff00) | ((ays & 0xff) ^ 0x9a);
                bx  = ays;
                //ays = (ays << 2) | (ays >> 30);
                ays = tools.bitRotate(ays, -2, 32);
                ax  = ays & 0xffff;
                bx  += ax;
                ax  ^= bx & 0xffff;
                ays  = (ays & 0xffff0000) | ax;
                //ays  = (ays >> 3) | (ays << 29);
                ays = tools.bitRotate(ays, 3, 32);
            }while( len );
        }
        
        
    }
}