/*
** Changes for the 1.4 release are commented. You can do
** a search for "1.4" and merge them into your own replay
** code.
**
** Changes for 1.5 are marked also.
**
** ... as are those for 1.6
**
** ... and for 1.8
*/

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
            return cons.AMIGA_PAULA_PAL_CLK * 65536.0 / period;
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

                if( ays & 0x100 ){
                    s = 0x7f;

                    if( ays & 0x8000 ){
                        s = 0x80;
                    }
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
        
        public function hvl_InitSubsong( ht:hvl_tune, nr:uint ):Boolean{
            var PosNr:uint, i:uint;

            if( nr > ht.ht_SubsongNr ){
                return FALSE;
            }

            ht.ht_SongNum = nr;

            PosNr = 0;
            if( nr ){
                PosNr = ht.ht_Subsongs[nr-1];
            }

            ht.ht_PosNr          = PosNr;
            ht.ht_PosJump        = 0;
            ht.ht_PatternBreak   = 0;
            ht.ht_NoteNr         = 0;
            ht.ht_PosJumpNote    = 0;
            ht.ht_Tempo          = 6;
            ht.ht_StepWaitFrames = 0;
            ht.ht_GetNewPosition = 1;
            ht.ht_SongEndReached = 0;
            ht.ht_PlayingTime    = 0;

            for( i=0; i<MAX_CHANNELS; i+=4 ){
                ht.ht_Voices[i+0].vc_Pan          = ht.ht_defpanleft;
                ht.ht_Voices[i+0].vc_SetPan       = ht.ht_defpanleft; // 1.4
                ht.ht_Voices[i+0].vc_PanMultLeft  = panning_left[ht.ht_defpanleft];
                ht.ht_Voices[i+0].vc_PanMultRight = panning_right[ht.ht_defpanleft];
                ht.ht_Voices[i+1].vc_Pan          = ht.ht_defpanright;
                ht.ht_Voices[i+1].vc_SetPan       = ht.ht_defpanright; // 1.4
                ht.ht_Voices[i+1].vc_PanMultLeft  = panning_left[ht.ht_defpanright];
                ht.ht_Voices[i+1].vc_PanMultRight = panning_right[ht.ht_defpanright];
                ht.ht_Voices[i+2].vc_Pan          = ht.ht_defpanright;
                ht.ht_Voices[i+2].vc_SetPan       = ht.ht_defpanright; // 1.4
                ht.ht_Voices[i+2].vc_PanMultLeft  = panning_left[ht.ht_defpanright];
                ht.ht_Voices[i+2].vc_PanMultRight = panning_right[ht.ht_defpanright];
                ht.ht_Voices[i+3].vc_Pan          = ht.ht_defpanleft;
                ht.ht_Voices[i+3].vc_SetPan       = ht.ht_defpanleft;  // 1.4
                ht.ht_Voices[i+3].vc_PanMultLeft  = panning_left[ht.ht_defpanleft];
                ht.ht_Voices[i+3].vc_PanMultRight = panning_right[ht.ht_defpanleft];
            }

            ht.hvl_reset_some_stuff();

            return TRUE;
        }
        
    //TODO    
        private function hvl_load_ahx( buf:ByteArray, buflen:uint, defstereo:uint, freq:uint ):hvl_tune{
            var bptr:uint;      //*uint8
            var nptr:uint;      //*TEXT
            var i:uint, j:uint, k:uint, l:uint, posn:uint, insn:uint, ssn:uint, hs:uint, trkn:uint, trkl:uint;
            var ht:hvl_tune;
            var ple:hvl_plsentry;
            const defgain:Vector.<int> = Vector.<int>([ 71, 72, 76, 85, 100 ]);

            posn = ((buf[6]&0x0f)<<8)|buf[7];
            insn = buf[12];
            ssn  = buf[13];
            trkl = buf[10];
            trkn = buf[11];

            // Calculate the size of all instrument PList buffers
            bptr = 14;//&buf[14];
            bptr += ssn*2;    // Skip past the subsong list
            bptr += posn*4*2; // Skip past the positions
            bptr += trkn*trkl*3;
            if((buf[6]&0x80)==0){
                bptr += trkl*3;
            }

            // *NOW* we can finally calculate PList space
            for( i=1; i<=insn; i++ ){
                //hs += bptr[21] * sizeof( struct hvl_plsentry );
                bptr += 22 + buf[bptr+21]*4;
            }

            ht = new hvl_tune();

            ht.ht_Frequency       = freq;
            ht.ht_FreqF           = Number(freq);

            ht.malloc_positions(posn);
            ht.malloc_instruments(insn);
            ht.malloc_subsongs(ssn);
            ple                = new hvl_plsentry(); //No!

            //ht.ht_Positions   = (struct hvl_position *)(&ht[1]);   // :-/
            //ht.ht_Instruments = (struct hvl_instrument *)(&ht.ht_Positions[posn]);
            //ht.ht_Subsongs    = (uint16 *)(&ht.ht_Instruments[(insn+1)]);
            //ple                = (struct hvl_plsentry *)(&ht.ht_Subsongs[ssn]);

            ht.ht_WaveformTab[0]  = cons.WO_TRIANGLE_04;
            ht.ht_WaveformTab[1]  = cons.WO_SAWTOOTH_04;
            ht.ht_WaveformTab[3]  = cons.WO_WHITENOISE;

            ht.ht_Channels        = 4;
            ht.ht_PositionNr      = posn;
            ht.ht_Restart         = (buf[8]<<8)|buf[9];
            ht.ht_SpeedMultiplier = ((buf[6]>>5)&3)+1;
            ht.ht_TrackLength     = trkl;
            ht.ht_TrackNr         = trkn;
            ht.ht_InstrumentNr    = insn;
            ht.ht_SubsongNr       = ssn;
            ht.ht_defstereo       = defstereo;
            ht.ht_defpanleft      = stereopan_left[ht.ht_defstereo];
            ht.ht_defpanright     = stereopan_right[ht.ht_defstereo];
            ht.ht_mixgain         = (defgain[ht.ht_defstereo]*256)/100;

            if( ht.ht_Restart >= ht.ht_PositionNr ){
                ht.ht_Restart = ht.ht_PositionNr-1;
            }

            // Do some validation  
            if( ( ht.ht_PositionNr > 1000 ) ||
              ( ht.ht_TrackLength > 64 ) ||
              ( ht.ht_InstrumentNr > 64 ) ){
                    trace( ht.ht_PositionNr +","+ht.ht_TrackLength+","+ht.ht_InstrumentNr );
                    ht=null;
                    buf=null;
                    trace( "Invalid file.\n" );
                    return NULL;
            }
            
            ht.ht_Name = tools.strncpy(buf, (buf[4]<<8)|buf[5], 128);
            //strncpy( ht.ht_Name, (TEXT *)&buf[(buf[4]<<8)|buf[5]], 128 );
            nptr = ((buf[4]<<8)|buf[5])+ht.ht_Name.length+1;

            bptr = 14; //&buf[14];

            // Subsongs
            for( i=0; i<ht.ht_SubsongNr; i++ ){
                ht.ht_Subsongs[i] = (buf[bptr]<<8)|buf[bptr+1];
                if( ht.ht_Subsongs[i] >= ht.ht_PositionNr )
                    ht.ht_Subsongs[i] = 0;
                bptr += 2;
            }

            // Position list
            for( i=0; i<ht.ht_PositionNr; i++ ){
                for( j=0; j<4; j++ ){
                    ht.ht_Positions[i].pos_Track[j]     = buf[bptr++];
                    ht.ht_Positions[i].pos_Transpose[j] = tools.ui2i8(buf[bptr++]);  //TODO:check if all goes well here
                }
            }

            // Tracks
            for( i=0; i<=ht.ht_TrackNr; i++ ){
                if( ( ( buf[6]&0x80 ) == 0x80 ) && ( i == 0 ) ){
                    for( j=0; j<ht.ht_TrackLength; j++ ){
                        ht.ht_Tracks[i][j].stp_Note       = 0;
                        ht.ht_Tracks[i][j].stp_Instrument = 0;
                        ht.ht_Tracks[i][j].stp_FX         = 0;
                        ht.ht_Tracks[i][j].stp_FXParam    = 0;
                        ht.ht_Tracks[i][j].stp_FXb        = 0;
                        ht.ht_Tracks[i][j].stp_FXbParam   = 0;
                    }
                    continue;
                }

                for( j=0; j<ht.ht_TrackLength; j++ ){
                        ht.ht_Tracks[i][j].stp_Note       = (buf[bptr]>>2)&0x3f;
                        ht.ht_Tracks[i][j].stp_Instrument = ((buf[bptr]&0x3)<<4) | (buf[bptr+1]>>4);
                        ht.ht_Tracks[i][j].stp_FX         = buf[bptr+1]&0xf;
                        ht.ht_Tracks[i][j].stp_FXParam    = buf[bptr+2];
                        ht.ht_Tracks[i][j].stp_FXb        = 0;
                        ht.ht_Tracks[i][j].stp_FXbParam   = 0;
                        bptr += 3;
                }
            }

            // Instruments
            for( i=1; i<=ht.ht_InstrumentNr; i++ ){
                if( nptr < buflen) ){
                    //strncpy( ht.ht_Instruments[i].ins_Name, nptr, 128 );
                    ht.ht_Instruments[i].ins_Name = tools.strncpy(buf, nptr, 128);
                    nptr += tools.strlen( buf, nptr )+1;
                } else {
                    ht.ht_Instruments[i].ins_Name[0] = 0;
                }

                ht.ht_Instruments[i].ins_Volume      = buf[bptr];
                ht.ht_Instruments[i].ins_FilterSpeed = ((buf[bptr+1]>>3)&0x1f)|((buf[bptr+12]>>2)&0x20);
                ht.ht_Instruments[i].ins_WaveLength  = buf[bptr+1]&0x07;

                ht.ht_Instruments[i].ins_Envelope.aFrames = buf[bptr+2];
                ht.ht_Instruments[i].ins_Envelope.aVolume = buf[bptr+3];
                ht.ht_Instruments[i].ins_Envelope.dFrames = buf[bptr+4];
                ht.ht_Instruments[i].ins_Envelope.dVolume = buf[bptr+5];
                ht.ht_Instruments[i].ins_Envelope.sFrames = buf[bptr+6];
                ht.ht_Instruments[i].ins_Envelope.rFrames = buf[bptr+7];
                ht.ht_Instruments[i].ins_Envelope.rVolume = buf[bptr+8];

                ht.ht_Instruments[i].ins_FilterLowerLimit     = buf[bptr+12]&0x7f;
                ht.ht_Instruments[i].ins_VibratoDelay         = buf[bptr+13];
                ht.ht_Instruments[i].ins_HardCutReleaseFrames = (buf[bptr+14]>>4)&0x07;
                ht.ht_Instruments[i].ins_HardCutRelease       = buf[bptr+14]&0x80?1:0;
                ht.ht_Instruments[i].ins_VibratoDepth         = buf[bptr+14]&0x0f;
                ht.ht_Instruments[i].ins_VibratoSpeed         = buf[bptr+15];
                ht.ht_Instruments[i].ins_SquareLowerLimit     = buf[bptr+16];
                ht.ht_Instruments[i].ins_SquareUpperLimit     = buf[bptr+17];
                ht.ht_Instruments[i].ins_SquareSpeed          = buf[bptr+18];
                ht.ht_Instruments[i].ins_FilterUpperLimit     = buf[bptr+19]&0x3f;
                ht.ht_Instruments[i].ins_PList.pls_Speed      = buf[bptr+20];
                ht.ht_Instruments[i].ins_PList.pls_Length     = buf[bptr+21];

                ht.ht_Instruments[i].ins_PList.pls_Entries    = ple;
                ple += buf[bptr+21];

                bptr += 22;
                for( j=0; j<ht.ht_Instruments[i].ins_PList.pls_Length; j++ ){
                    k = (buf[bptr]>>5)&7;
                    if( k == 6 ) k = 12;
                    if( k == 7 ) k = 15;
                    l = (buf[bptr]>>2)&7;
                    if( l == 6 ) l = 12;
                    if( l == 7 ) l = 15;
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[1]      = k;
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[0]      = l;
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_Waveform   = (buf[bptr]<<1)&6) | (buf[bptr+1]>>7);
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_Fixed      = (buf[bptr+1]>>6)&1;
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_Note       = buf[bptr+1]&0x3f;
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[0] = buf[bptr+2];
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[1] = buf[bptr+3];

                    // 1.6: Strip "toggle filter" commands if the module is
                    //      version 0 (pre-filters). This is what AHX also does.
                    if( ( buf[3] == 0 ) && ( l == 4 ) && ( (buf[bptr+2]&0xf0) != 0 ) )
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[0] &= 0x0f;
                    if( ( buf[3] == 0 ) && ( k == 4 ) && ( (buf[bptr+3]&0xf0) != 0 ) )
                    ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[1] &= 0x0f; // 1.8

                    bptr += 4;
                }
            }

            hvl_InitSubsong( ht, 0 );
            buf.clear();
            return ht;
}

        public function hvl_LoadTune( buf:ByteArray, freq:uint, defstereo:uint ):hvl_tune{
            var ht:hvl_tune;              //*
            var bptr:uint;      //*uint8
            var nptr:String;              //*TEXT
            var buflen:uint, i:uint, j:uint, posn:uint, insn:uint, ssn:uint, chnn:uint, hs:uint, trkl:uint, trkn:uint;
            var ple:hvl_plsentry;         //*

            buflen = buf.length;
  
            if( ( buf[0] == 'T' ) &&
                ( buf[1] == 'H' ) &&
                ( buf[2] == 'X' ) &&
                ( buf[3] < 3 ) ){
                    return hvl_load_ahx( buf, buflen, defstereo, freq );
                }
            /*
            if( ( buf[0] != 'H' ) ||
              ( buf[1] != 'V' ) ||
              ( buf[2] != 'L' ) ||
              ( buf[3] > 1 ) )
            {
            free( buf );
            printf( "Invalid file.\n" );
            return NULL;
            }

            posn = ((buf[6]&0x0f)<<8)|buf[7];
            insn = buf[12];
            ssn  = buf[13];
            chnn = (buf[8]>>2)+4;
            trkl = buf[10];
            trkn = buf[11];

            hs  = sizeof( struct hvl_tune );
            hs += sizeof( struct hvl_position ) * posn;
            hs += sizeof( struct hvl_instrument ) * (insn+1);
            hs += sizeof( uint16 ) * ssn;

            // Calculate the size of all instrument PList buffers
            bptr = &buf[16];
            bptr += ssn*2;       // Skip past the subsong list
            bptr += posn*chnn*2; // Skip past the positions

            // Skip past the tracks
            // 1.4: Fixed two really stupid bugs that cancelled each other
            //      out if the module had a blank first track (which is how
            //      come they were missed.
            for( i=((buf[6]&0x80)==0x80)?1:0; i<=trkn; i++ )
            for( j=0; j<trkl; j++ )
            {
              if( bptr[0] == 0x3f )
              {
                bptr++;
                continue;
              }
              bptr += 5;
            }

            // *NOW* we can finally calculate PList space
            for( i=1; i<=insn; i++ )
            {
            hs += bptr[21] * sizeof( struct hvl_plsentry );
            bptr += 22 + bptr[21]*5;
            }

            ht = malloc( hs );    
            if( !ht )
            {
            free( buf );
            printf( "Out of memory!\n" );
            return NULL;
            }

            ht->ht_Version         = buf[3]; // 1.5
            ht->ht_Frequency       = freq;
            ht->ht_FreqF           = (float64)freq;

            ht->ht_Positions       = (struct hvl_position *)(&ht[1]);
            ht->ht_Instruments     = (struct hvl_instrument *)(&ht->ht_Positions[posn]);
            ht->ht_Subsongs        = (uint16 *)(&ht->ht_Instruments[(insn+1)]);
            ple                    = (struct hvl_plsentry *)(&ht->ht_Subsongs[ssn]);

            ht->ht_WaveformTab[0]  = &waves[WO_TRIANGLE_04];
            ht->ht_WaveformTab[1]  = &waves[WO_SAWTOOTH_04];
            ht->ht_WaveformTab[3]  = &waves[WO_WHITENOISE];

            ht->ht_PositionNr      = posn;
            ht->ht_Channels        = (buf[8]>>2)+4;
            ht->ht_Restart         = ((buf[8]&3)<<8)|buf[9];
            ht->ht_SpeedMultiplier = ((buf[6]>>5)&3)+1;
            ht->ht_TrackLength     = buf[10];
            ht->ht_TrackNr         = buf[11];
            ht->ht_InstrumentNr    = insn;
            ht->ht_SubsongNr       = ssn;
            ht->ht_mixgain         = (buf[14]<<8)/100;
            ht->ht_defstereo       = buf[15];
            ht->ht_defpanleft      = stereopan_left[ht->ht_defstereo];
            ht->ht_defpanright     = stereopan_right[ht->ht_defstereo];

            if( ht->ht_Restart >= ht->ht_PositionNr )
            ht->ht_Restart = ht->ht_PositionNr-1;

            // Do some validation  
            if( ( ht->ht_PositionNr > 1000 ) ||
              ( ht->ht_TrackLength > 64 ) ||
              ( ht->ht_InstrumentNr > 64 ) )
            {
            printf( "%d,%d,%d\n", ht->ht_PositionNr,
                                  ht->ht_TrackLength,
                                  ht->ht_InstrumentNr );
            free( ht );
            free( buf );
            printf( "Invalid file.\n" );
            return NULL;
            }

            strncpy( ht->ht_Name, (TEXT *)&buf[(buf[4]<<8)|buf[5]], 128 );
            nptr = (TEXT *)&buf[((buf[4]<<8)|buf[5])+strlen( ht->ht_Name )+1];

            bptr = &buf[16];

            // Subsongs
            for( i=0; i<ht->ht_SubsongNr; i++ )
            {
            ht->ht_Subsongs[i] = (bptr[0]<<8)|bptr[1];
            bptr += 2;
            }

            // Position list
            for( i=0; i<ht->ht_PositionNr; i++ )
            {
            for( j=0; j<ht->ht_Channels; j++ )
            {
              ht->ht_Positions[i].pos_Track[j]     = *bptr++;
              ht->ht_Positions[i].pos_Transpose[j] = *(int8 *)bptr++;
            }
            }

            // Tracks
            for( i=0; i<=ht->ht_TrackNr; i++ )
            {
            if( ( ( buf[6]&0x80 ) == 0x80 ) && ( i == 0 ) )
            {
              for( j=0; j<ht->ht_TrackLength; j++ )
              {
                ht->ht_Tracks[i][j].stp_Note       = 0;
                ht->ht_Tracks[i][j].stp_Instrument = 0;
                ht->ht_Tracks[i][j].stp_FX         = 0;
                ht->ht_Tracks[i][j].stp_FXParam    = 0;
                ht->ht_Tracks[i][j].stp_FXb        = 0;
                ht->ht_Tracks[i][j].stp_FXbParam   = 0;
              }
              continue;
            }

            for( j=0; j<ht->ht_TrackLength; j++ )
            {
              if( bptr[0] == 0x3f )
              {
                ht->ht_Tracks[i][j].stp_Note       = 0;
                ht->ht_Tracks[i][j].stp_Instrument = 0;
                ht->ht_Tracks[i][j].stp_FX         = 0;
                ht->ht_Tracks[i][j].stp_FXParam    = 0;
                ht->ht_Tracks[i][j].stp_FXb        = 0;
                ht->ht_Tracks[i][j].stp_FXbParam   = 0;
                bptr++;
                continue;
              }
              
              ht->ht_Tracks[i][j].stp_Note       = bptr[0];
              ht->ht_Tracks[i][j].stp_Instrument = bptr[1];
              ht->ht_Tracks[i][j].stp_FX         = bptr[2]>>4;
              ht->ht_Tracks[i][j].stp_FXParam    = bptr[3];
              ht->ht_Tracks[i][j].stp_FXb        = bptr[2]&0xf;
              ht->ht_Tracks[i][j].stp_FXbParam   = bptr[4];
              bptr += 5;
            }
            }


            // Instruments
            for( i=1; i<=ht->ht_InstrumentNr; i++ )
            {
            if( nptr < (TEXT *)(buf+buflen) )
            {
              strncpy( ht->ht_Instruments[i].ins_Name, nptr, 128 );
              nptr += strlen( nptr )+1;
            } else {
              ht->ht_Instruments[i].ins_Name[0] = 0;
            }

            ht->ht_Instruments[i].ins_Volume      = bptr[0];
            ht->ht_Instruments[i].ins_FilterSpeed = ((bptr[1]>>3)&0x1f)|((bptr[12]>>2)&0x20);
            ht->ht_Instruments[i].ins_WaveLength  = bptr[1]&0x07;

            ht->ht_Instruments[i].ins_Envelope.aFrames = bptr[2];
            ht->ht_Instruments[i].ins_Envelope.aVolume = bptr[3];
            ht->ht_Instruments[i].ins_Envelope.dFrames = bptr[4];
            ht->ht_Instruments[i].ins_Envelope.dVolume = bptr[5];
            ht->ht_Instruments[i].ins_Envelope.sFrames = bptr[6];
            ht->ht_Instruments[i].ins_Envelope.rFrames = bptr[7];
            ht->ht_Instruments[i].ins_Envelope.rVolume = bptr[8];

            ht->ht_Instruments[i].ins_FilterLowerLimit     = bptr[12]&0x7f;
            ht->ht_Instruments[i].ins_VibratoDelay         = bptr[13];
            ht->ht_Instruments[i].ins_HardCutReleaseFrames = (bptr[14]>>4)&0x07;
            ht->ht_Instruments[i].ins_HardCutRelease       = bptr[14]&0x80?1:0;
            ht->ht_Instruments[i].ins_VibratoDepth         = bptr[14]&0x0f;
            ht->ht_Instruments[i].ins_VibratoSpeed         = bptr[15];
            ht->ht_Instruments[i].ins_SquareLowerLimit     = bptr[16];
            ht->ht_Instruments[i].ins_SquareUpperLimit     = bptr[17];
            ht->ht_Instruments[i].ins_SquareSpeed          = bptr[18];
            ht->ht_Instruments[i].ins_FilterUpperLimit     = bptr[19]&0x3f;
            ht->ht_Instruments[i].ins_PList.pls_Speed      = bptr[20];
            ht->ht_Instruments[i].ins_PList.pls_Length     = bptr[21];

            ht->ht_Instruments[i].ins_PList.pls_Entries    = ple;
            ple += bptr[21];

            bptr += 22;
            for( j=0; j<ht->ht_Instruments[i].ins_PList.pls_Length; j++ )
            {
              ht->ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[0] = bptr[0]&0xf;
              ht->ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[1] = (bptr[1]>>3)&0xf;
              ht->ht_Instruments[i].ins_PList.pls_Entries[j].ple_Waveform = bptr[1]&7;
              ht->ht_Instruments[i].ins_PList.pls_Entries[j].ple_Fixed = (bptr[2]>>6)&1;
              ht->ht_Instruments[i].ins_PList.pls_Entries[j].ple_Note  = bptr[2]&0x3f;
              ht->ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[0] = bptr[3];
              ht->ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[1] = bptr[4];
              bptr += 5;
            }
            }

            hvl_InitSubsong( ht, 0 );
            free( buf );
            return ht;
            */
}

        
        
        
        
    }
}