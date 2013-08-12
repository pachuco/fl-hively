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
            for(var i:uint=0; i<cons.WAVES_SIZE; i++){
                //we work with ByteArray and transfer to Vector.<int> after
                //because of some accuracy issues for working directly
                //with Vector.<int>
                //Why? no bloody idea. Rounding error, perhaps?
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
                return false;
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

            for( i=0; i<cons.MAX_CHANNELS; i+=4 ){
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

            return true;
        }
        
    //TODO    
        private function hvl_load_ahx( buf:ByteArray, buflen:uint, defstereo:uint ):hvl_tune{
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
			bptr = 14;
			bptr += ssn*2;    // Skip past the subsong list
			bptr += posn*4*2; // Skip past the positions
			bptr += trkn*trkl*3;
			if((buf[6]&0x80)==0) bptr += trkl*3;
  
			// *NOW* we can finally calculate PList space
			for( i=1; i<=insn; i++ ){
				bptr += 22 + buf[bptr+21]*4;
			}

			ht = new hvl_tune();
  
			ht.ht_Frequency       = cons.sample_rate;
			ht.ht_FreqF           = Number(cons.sample_rate);
  
            ht.malloc_positions(posn);
            ht.malloc_instruments(insn);
            ht.malloc_subsongs(ssn);

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
			ht.ht_defpanleft      = cons.stereopan_left[ht.ht_defstereo];
			ht.ht_defpanright     = cons.stereopan_right[ht.ht_defstereo];
			ht.ht_mixgain         = (defgain[ht.ht_defstereo]*256)/100;
  
			if( ht.ht_Restart >= ht.ht_PositionNr ){
					ht.ht_Restart = ht.ht_PositionNr - 1;
			}

			// Do some validation  
			if( ( ht.ht_PositionNr > 1000 ) ||
				( ht.ht_TrackLength > 64 ) ||
				( ht.ht_InstrumentNr > 64 ) ){
					trace( ht.ht_PositionNr+","+ht.ht_TrackLength+","+ht.ht_InstrumentNr );
					ht = null;
					buf.clear();
					trace( "Invalid file.\n" );
					return null;
			}

			ht.ht_Name = tools.strncpy(buf, (buf[4]<<8)|buf[5], 128);
			nptr = ((buf[4]<<8)|buf[5])+ht.ht_Name.length+1;

			bptr = 14;
  
			// Subsongs
			for( i=0; i<ht.ht_SubsongNr; i++ ){
				ht.ht_Subsongs[i] = (buf[bptr+0]<<8)|buf[bptr+1];
				if( ht.ht_Subsongs[i] >= ht.ht_PositionNr ){
					ht.ht_Subsongs[i] = 0;
				}
				bptr += 2;
			}
  
			// Position list
			for( i=0; i<ht.ht_PositionNr; i++ ){
				for( j=0; j<4; j++ ){
					ht.ht_Positions[i].pos_Track[j]     = buf[bptr++];
					ht.ht_Positions[i].pos_Transpose[j] = tools.ui2i8(buf[bptr++]);
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
					ht.ht_Tracks[i][j].stp_Note       = (buf[bptr+0]>>2)&0x3f;
					ht.ht_Tracks[i][j].stp_Instrument = ((buf[bptr+0]&0x3)<<4) | (buf[bptr+1]>>4);
					ht.ht_Tracks[i][j].stp_FX         = buf[bptr+1]&0xf;
					ht.ht_Tracks[i][j].stp_FXParam    = buf[bptr+2];
					ht.ht_Tracks[i][j].stp_FXb        = 0;
					ht.ht_Tracks[i][j].stp_FXbParam   = 0;
					bptr += 3;
				}
			}
  
			// Instruments
			for( i=1; i<=ht.ht_InstrumentNr; i++ ){
				if ( nptr < buf + buflen ) {
					ht.ht_Instruments[i].ins_Name = tools.strncpy(buf, nptr, 128);
					nptr += tools.strlen( buf, nptr )+1;
				} else {
					ht.ht_Instruments[i].ins_Name = "";
				}
    
				ht.ht_Instruments[i].ins_Volume      = buf[bptr+0];
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
				
				ht.ht_Instruments[i].ins_PList.ple_malloc( buf[bptr+21] );
    
				bptr += 22;
				for( j=0; j<ht.ht_Instruments[i].ins_PList.pls_Length; j++ ){
					k = (buf[bptr+0]>>5)&7;
					if( k == 6 ) k = 12;
					if( k == 7 ) k = 15;
					l = (buf[bptr+0]>>2)&7;
					if( l == 6 ) l = 12;
					if( l == 7 ) l = 15;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[1]      = k;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[0]      = l;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_Waveform   = ((buf[bptr+0]<<1)&6) | (buf[bptr+1]>>7);
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

        public function hvl_LoadTune( buf:ByteArray, defstereo:uint ):hvl_tune{
            
            var ht:hvl_tune;              //*
            var bptr:uint;      //*uint8
            var nptr:uint;              //*TEXT
            var buflen:uint, i:uint, j:uint, posn:uint, insn:uint, ssn:uint, chnn:uint, hs:uint, trkl:uint, trkn:uint;
            //var ple:hvl_plsentry;         //*

            buflen = buf.length;
			
			//THX
            if( ( buf[0] == 84 ) &&
                ( buf[1] == 72 ) &&
                ( buf[2] == 88 ) &&
                ( buf[3] < 3 ) ){
                    return hvl_load_ahx( buf, buflen, defstereo);
                }
			//HVL
            if( ( buf[0] != 72 ) ||
				( buf[1] != 86 ) ||
				( buf[2] != 76 ) ||
				( buf[3] > 1 ) ){
					buf.clear();
					trace( "Invalid file.\n" );
					return null;
            }
			
            posn = ((buf[6]&0x0f)<<8)|buf[7];
            insn = buf[12];
            ssn  = buf[13];
            chnn = (buf[8]>>2)+4;
            trkl = buf[10];
            trkn = buf[11];

            //hs  = sizeof( struct hvl_tune );
            //hs += sizeof( struct hvl_position ) * posn;
            //hs += sizeof( struct hvl_instrument ) * (insn+1);
            //hs += sizeof( uint16 ) * ssn;

            // Calculate the size of all instrument PList buffers
            bptr = 16;
            bptr += ssn*2;       // Skip past the subsong list
            bptr += posn*chnn*2; // Skip past the positions

            // Skip past the tracks
            // 1.4: Fixed two really stupid bugs that cancelled each other
            //      out if the module had a blank first track (which is how
            //      come they were missed.
            for( i=((buf[6]&0x80)==0x80)?1:0; i<=trkn; i++ ){
				for( j=0; j<trkl; j++ ){
					if( buf[bptr+0] == 0x3f ){
						bptr++;
						continue;
					}
					bptr += 5;
				}
			}

            // *NOW* we can finally calculate PList space
            for( i=1; i<=insn; i++ ){
				//hs += bptr[21] * sizeof( struct hvl_plsentry );
				bptr += 22 + buf[bptr+21]*5;
            }

            ht = new hvl_tune();

            ht.ht_Version         = buf[3]; // 1.5
            ht.ht_Frequency       = cons.sample_rate;
            ht.ht_FreqF           = Number(cons.sample_rate);

            ht.malloc_positions(posn);
            ht.malloc_instruments(insn);
            ht.malloc_subsongs(ssn);

            ht.ht_WaveformTab[0]  = cons.WO_TRIANGLE_04;
            ht.ht_WaveformTab[1]  = cons.WO_SAWTOOTH_04;
            ht.ht_WaveformTab[3]  = cons.WO_WHITENOISE;

            ht.ht_PositionNr      = posn;
            ht.ht_Channels        = (buf[8]>>2)+4;
            ht.ht_Restart         = ((buf[8]&3)<<8)|buf[9];
            ht.ht_SpeedMultiplier = ((buf[6]>>5)&3)+1;
            ht.ht_TrackLength     = buf[10];
            ht.ht_TrackNr         = buf[11];
            ht.ht_InstrumentNr    = insn;
            ht.ht_SubsongNr       = ssn;
            ht.ht_mixgain         = (buf[14]<<8)/100;
            ht.ht_defstereo       = buf[15];
            ht.ht_defpanleft      = cons.stereopan_left[ht.ht_defstereo];
            ht.ht_defpanright     = cons.stereopan_right[ht.ht_defstereo];

            if( ht.ht_Restart >= ht.ht_PositionNr ){
				ht.ht_Restart = ht.ht_PositionNr - 1;
			}

            // Do some validation  
            if( ( ht.ht_PositionNr > 1000 ) ||
				( ht.ht_TrackLength > 64 ) ||
				( ht.ht_InstrumentNr > 64 ) ){
					trace( ht.ht_PositionNr+","+ht.ht_TrackLength+","+ht.ht_InstrumentNr+"\n");
					ht = null;
					buf.clear();
					trace( "Invalid file.\n" );
					return null;
            }

			ht.ht_Name = tools.strncpy(buf, (buf[4]<<8)|buf[5], 128);
            nptr = ((buf[4]<<8)|buf[5])+ht.ht_Name.length+1;

            bptr = 16;

            // Subsongs
            for( i=0; i<ht.ht_SubsongNr; i++ ){
				ht.ht_Subsongs[i] = (buf[bptr+0]<<8)|buf[bptr+1];
				bptr += 2;
            }

            // Position list
            for( i=0; i<ht.ht_PositionNr; i++ ){
				for( j=0; j<ht.ht_Channels; j++ ){
					ht.ht_Positions[i].pos_Track[j]     = buf[bptr++];
					ht.ht_Positions[i].pos_Transpose[j] = tools.ui2i8(buf[bptr++]);
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
					if( buf[bptr+0] == 0x3f ){
						ht.ht_Tracks[i][j].stp_Note       = 0;
						ht.ht_Tracks[i][j].stp_Instrument = 0;
						ht.ht_Tracks[i][j].stp_FX         = 0;
						ht.ht_Tracks[i][j].stp_FXParam    = 0;
						ht.ht_Tracks[i][j].stp_FXb        = 0;
						ht.ht_Tracks[i][j].stp_FXbParam   = 0;
						bptr++;
						continue;
					}
				  
					ht.ht_Tracks[i][j].stp_Note       = buf[bptr+0];
					ht.ht_Tracks[i][j].stp_Instrument = buf[bptr+1];
					ht.ht_Tracks[i][j].stp_FX         = buf[bptr+2]>>4;
					ht.ht_Tracks[i][j].stp_FXParam    = buf[bptr+3];
					ht.ht_Tracks[i][j].stp_FXb        = buf[bptr+2]&0xf;
					ht.ht_Tracks[i][j].stp_FXbParam   = buf[bptr+4];
					bptr += 5;
				}
            }


            // Instruments
            for( i=1; i<=ht.ht_InstrumentNr; i++ ){
				if( nptr < buf+buflen ){
					ht.ht_Instruments[i].ins_Name = tools.strncpy(buf, nptr, 128);
					nptr += tools.strlen( buf, nptr )+1;
				} else {
					ht.ht_Instruments[i].ins_Name = "";
				}

				ht.ht_Instruments[i].ins_Volume      = buf[bptr+0];
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

				ht.ht_Instruments[i].ins_PList.ple_malloc( buf[bptr+21] );
				//ple += bptr[21];

				bptr += 22;
				for( j=0; j<ht.ht_Instruments[i].ins_PList.pls_Length; j++ ){
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[0] = buf[bptr+0]&0xf;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FX[1] = (buf[bptr+1]>>3)&0xf;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_Waveform = buf[bptr+1]&7;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_Fixed = (buf[bptr+2]>>6)&1;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_Note  = buf[bptr+2]&0x3f;
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[0] = buf[bptr+3];
					ht.ht_Instruments[i].ins_PList.pls_Entries[j].ple_FXParam[1] = buf[bptr+4];
					bptr += 5;
				}
            }

            hvl_InitSubsong( ht, 0 );
            buf.clear();
            return ht;
			
}   

        private function hvl_process_stepfx_1( ht:hvl_tune, voice:hvl_voice, FX:int, FXParam:int ):void{
            switch( FX ){
                case 0x0:  // Position Jump HI
                    if( ((FXParam&0x0f) > 0) && ((FXParam&0x0f) <= 9) ){
                        ht.ht_PosJump = FXParam & 0xf;
                    }
                    break;

                case 0x5:  // Volume Slide + Tone Portamento
                case 0xa:  // Volume Slide
                    voice.vc_VolumeSlideDown = FXParam & 0x0f;
                    voice.vc_VolumeSlideUp   = FXParam >> 4;
                    break;

                case 0x7:  // Panning
                    if( FXParam > 127 ){
                        FXParam -= 256;
                    }
                    voice.vc_Pan          = (FXParam+128);
                    voice.vc_SetPan       = (FXParam+128); // 1.4
                    voice.vc_PanMultLeft  = panning_left[voice.vc_Pan];
                    voice.vc_PanMultRight = panning_right[voice.vc_Pan];
                    break;

                case 0xb: // Position jump
                    ht.ht_PosJump      = ht.ht_PosJump*100 + (FXParam & 0x0f) + (FXParam >> 4)*10;
                    ht.ht_PatternBreak = 1;
                    if( ht.ht_PosJump <= ht.ht_PosNr ){
                        ht.ht_SongEndReached = 1;
                    }
                    break;

                case 0xd: // Pattern break
                    ht.ht_PosJump      = ht.ht_PosNr+1;
                    ht.ht_PosJumpNote  = (FXParam & 0x0f) + (FXParam>>4)*10;
                    ht.ht_PatternBreak = 1;
                    if( ht.ht_PosJumpNote >  ht.ht_TrackLength ){
                        ht.ht_PosJumpNote = 0;
                    }
                    break;

                case 0xe: // Extended commands
                    switch( FXParam >> 4 ){
                        case 0xc: // Note cut
                            if( (FXParam & 0x0f) < ht.ht_Tempo ){
                                voice.vc_NoteCutWait = FXParam & 0x0f;
                                if( voice.vc_NoteCutWait ){
                                    voice.vc_NoteCutOn      = 1;
                                    voice.vc_HardCutRelease = 0;
                                }
                            }
                            break;
                      
                            // 1.6: 0xd case removed
                    }
                    break;

                case 0xf: // Speed
                    ht.ht_Tempo = FXParam;
                    if( FXParam == 0 ){
                        ht.ht_SongEndReached = 1;
                    }
                    break;
            }  
        }

        private function hvl_process_stepfx_2( ht:hvl_tune, voice:hvl_voice, FX:int, FXParam:int, Note:int ):int{
            switch( FX ){
                case 0x9: // Set squarewave offset
                    voice.vc_SquarePos    = FXParam >> (5 - voice.vc_WaveLength);
                    //voice.vc_PlantSquare  = 1;
                    voice.vc_IgnoreSquare = 1;
                    break;

                    case 0x5: // Tone portamento + volume slide
                    case 0x3: // Tone portamento
                        if( FXParam != 0 ){
                            voice.vc_PeriodSlideSpeed = FXParam;
                        }
                        //TODO: Check *Note usage.
                        if( Note ){
                            var mew:int, diff:int;

                            mew   = cons.period_tab[Note];
                            diff  = cons.period_tab[voice.vc_TrackPeriod];
                            diff -= mew;
                            mew   = diff + voice.vc_PeriodSlidePeriod;
                
                            if( mew ){
                                voice.vc_PeriodSlideLimit = -diff;
                            }
                        }
                        voice.vc_PeriodSlideOn        = 1;
                        voice.vc_PeriodSlideWithLimit = 1;
                        Note = 0;
                        break;      
            }
            return Note;
        }

        private function hvl_process_stepfx_3( ht:hvl_tune, voice:hvl_voice, FX:int, FXParam:int ):void{
            var i:int;
          
            switch( FX ){
                case 0x01: // Portamento up (period slide down)
                    voice.vc_PeriodSlideSpeed     = -FXParam;
                    voice.vc_PeriodSlideOn        = 1;
                    voice.vc_PeriodSlideWithLimit = 0;
                    break;
                case 0x02: // Portamento down
                    voice.vc_PeriodSlideSpeed     = FXParam;
                    voice.vc_PeriodSlideOn        = 1;
                    voice.vc_PeriodSlideWithLimit = 0;
                    break;
                case 0x04: // Filter override
                    if( ( FXParam == 0 ) || ( FXParam == 0x40 ) ){
                        break;
                    }
                    if( FXParam < 0x40 ){
                        voice.vc_IgnoreFilter = FXParam;
                        break;
                    }
                    if( FXParam > 0x7f ){
                        break;
                    }
                    voice.vc_FilterPos = FXParam - 0x40;
                    break;
                case 0x0c: // Volume
                    FXParam &= 0xff;
                    if( FXParam <= 0x40 ){
                        voice.vc_NoteMaxVolume = FXParam;
                        break;
                    }
              
                    if( (FXParam -= 0x50) < 0 ){
                        break;  // 1.6
                    }

                    if( FXParam <= 0x40 ){
                        for( i=0; i<ht.ht_Channels; i++ ){
                            ht.ht_Voices[i].vc_TrackMasterVolume = FXParam;
                        }
                        break;
                    }
              
                    if( (FXParam -= 0xa0-0x50) < 0 ){
                        break; // 1.6
                    }

                    if( FXParam <= 0x40 ){
                        voice.vc_TrackMasterVolume = FXParam;
                    }
                    break;

                case 0xe: // Extended commands;
                    switch( FXParam >> 4 ){
                        case 0x1: // Fineslide up
                            voice.vc_PeriodSlidePeriod -= (FXParam & 0x0f); // 1.8
                            voice.vc_PlantPeriod = 1;
                            break;
                
                        case 0x2: // Fineslide down
                            voice.vc_PeriodSlidePeriod += (FXParam & 0x0f); // 1.8
                            voice.vc_PlantPeriod = 1;
                            break;
                
                        case 0x4: // Vibrato control
                            voice.vc_VibratoDepth = FXParam & 0x0f;
                            break;
                
                        case 0x0a: // Fine volume up
                            voice.vc_NoteMaxVolume += FXParam & 0x0f;
                  
                            if( voice.vc_NoteMaxVolume > 0x40 ){
                                voice.vc_NoteMaxVolume = 0x40;
                            }
                            break;
                
                        case 0x0b: // Fine volume down
                            voice.vc_NoteMaxVolume -= FXParam & 0x0f;
                  
                            if( voice.vc_NoteMaxVolume < 0 ){
                                voice.vc_NoteMaxVolume = 0;
                            }
                            break;
                
                            case 0x0f: // Misc flags (1.5)
                                if( ht.ht_Version < 1 ){
                                    break;
                                }
                                switch( FXParam & 0xf ){
                                    case 1:
                                        voice.vc_OverrideTranspose = voice.vc_Transpose;
                                        break;
                                }
                                break;
                    } 
                    break;
            }
        }

        private function hvl_process_step( ht:hvl_tune, voice:hvl_voice ):void{
            var Note:int, Instr:int, donenotedel:int; //int32
            var Step:hvl_step;                        //struct hvl_step *Step;
          
            if( voice.vc_TrackOn == 0 ){
                return;
            }
          
            voice.vc_VolumeSlideUp = voice.vc_VolumeSlideDown = 0;
          
            //TODO: a bit of a headache to read. Make sure we are doing things right.
            //Step = &ht->ht_Tracks[ht->ht_Positions[ht->ht_PosNr].pos_Track[voice->vc_VoiceNum]][ht->ht_NoteNr];
            Step = ht.ht_Tracks[ ht.ht_Positions[ ht.ht_PosNr ].pos_Track[ voice.vc_VoiceNum ] ]     [ ht.ht_NoteNr ];
          
            Note    = Step.stp_Note;
            Instr   = Step.stp_Instrument;
          
            // --------- 1.6: from here --------------

            donenotedel = 0;

            // Do notedelay here
            if( ((Step.stp_FX&0xf)==0xe) && ((Step.stp_FXParam&0xf0)==0xd0) ){
                if( voice.vc_NoteDelayOn ){
                    voice.vc_NoteDelayOn = 0;
                    donenotedel = 1;
                } else {
                    if( (Step.stp_FXParam&0x0f) < ht.ht_Tempo ){
                        voice.vc_NoteDelayWait = Step.stp_FXParam & 0x0f;
                        if( voice.vc_NoteDelayWait ){
                            voice.vc_NoteDelayOn = 1;
                            return;
                        }
                    }
                }
            }

            if( (donenotedel==0) && ((Step.stp_FXb&0xf)==0xe) && ((Step.stp_FXbParam&0xf0)==0xd0) ){
                if( voice.vc_NoteDelayOn ){
                    voice.vc_NoteDelayOn = 0;
                } else {
                    if( (Step.stp_FXbParam&0x0f) < ht.ht_Tempo ){
                        voice.vc_NoteDelayWait = Step.stp_FXbParam & 0x0f;
                        if( voice.vc_NoteDelayWait ){
                            voice.vc_NoteDelayOn = 1;
                            return;
                        }
                    }
                }
            }

            // --------- 1.6: to here --------------

            if( Note ){
                voice.vc_OverrideTranspose = 1000; // 1.5
            }

            hvl_process_stepfx_1( ht, voice, Step.stp_FX&0xf,  Step.stp_FXParam );  
            hvl_process_stepfx_1( ht, voice, Step.stp_FXb&0xf, Step.stp_FXbParam );
          
            if( ( Instr ) && ( Instr <=  ht.ht_InstrumentNr ) ){
                var Ins:hvl_instrument;
                var SquareLower:int, SquareUpper:int, d6:int, d3:int, d4:int; //int16
            
                /* 1.4: Reset panning to last set position */
                voice.vc_Pan          = voice.vc_SetPan;
                voice.vc_PanMultLeft  = panning_left[voice.vc_Pan];
                voice.vc_PanMultRight = panning_right[voice.vc_Pan];

                voice.vc_PeriodSlideSpeed =     0;
                voice.vc_PeriodSlidePeriod =    0;
                voice.vc_PeriodSlideLimit =     0;

                voice.vc_PerfSubVolume    = 0x40;
                voice.vc_ADSRVolume       = 0;
                //voice.vc_Instrument       = Ins = &ht.ht_Instruments[Instr];
                voice.vc_Instrument       = Ins = ht.ht_Instruments[Instr];
                voice.vc_SamplePos        = 0;
            
                voice.vc_ADSR.aFrames     = Ins.ins_Envelope.aFrames;
                voice.vc_ADSR.aVolume     = Ins.ins_Envelope.aVolume*256/voice.vc_ADSR.aFrames;
                voice.vc_ADSR.dFrames     = Ins.ins_Envelope.dFrames;
                voice.vc_ADSR.dVolume     = (Ins.ins_Envelope.dVolume-Ins.ins_Envelope.aVolume)*256/voice.vc_ADSR.dFrames;
                voice.vc_ADSR.sFrames     = Ins.ins_Envelope.sFrames;
                voice.vc_ADSR.rFrames     = Ins.ins_Envelope.rFrames;
                voice.vc_ADSR.rVolume     = (Ins.ins_Envelope.rVolume-Ins.ins_Envelope.dVolume)*256/voice.vc_ADSR.rFrames;
            
                voice.vc_WaveLength       = Ins.ins_WaveLength;
                voice.vc_NoteMaxVolume    = Ins.ins_Volume;
            
                voice.vc_VibratoCurrent   = 0;
                voice.vc_VibratoDelay     = Ins.ins_VibratoDelay;
                voice.vc_VibratoDepth     = Ins.ins_VibratoDepth;
                voice.vc_VibratoSpeed     = Ins.ins_VibratoSpeed;
                voice.vc_VibratoPeriod    = 0;
            
                voice.vc_HardCutRelease   = Ins.ins_HardCutRelease;
                voice.vc_HardCut          = Ins.ins_HardCutReleaseFrames;
            
                voice.vc_IgnoreSquare = voice.vc_SquareSlidingIn = 0;
                voice.vc_SquareWait   = voice.vc_SquareOn        = 0;
            
                SquareLower = Ins.ins_SquareLowerLimit >> (5 - voice.vc_WaveLength);
                SquareUpper = Ins.ins_SquareUpperLimit >> (5 - voice.vc_WaveLength);
            
                if( SquareUpper < SquareLower ){
                    var t:int = SquareUpper;            //int16
                    SquareUpper = SquareLower;
                    SquareLower = t;
                }
            
                voice.vc_SquareUpperLimit = SquareUpper;
                voice.vc_SquareLowerLimit = SquareLower;
            
                voice.vc_IgnoreFilter     = 0;
                voice.vc_FilterWait       = 0;
                voice.vc_FilterOn         = 0;
                voice.vc_FilterSlidingIn  = 0;

                d6 = Ins.ins_FilterSpeed;
                d3 = Ins.ins_FilterLowerLimit;
                d4 = Ins.ins_FilterUpperLimit;
            
                if( d3 & 0x80 ) d6 |= 0x20;
                if( d4 & 0x80 ) d6 |= 0x40;
            
                voice.vc_FilterSpeed = d6;
                d3 &= ~0x80;
                d4 &= ~0x80;
            
                if( d3 > d4 ){
                    var t:int = d3;                     //int16
                    d3 = d4;
                    d4 = t;
                }
            
                voice.vc_FilterUpperLimit = d4;
                voice.vc_FilterLowerLimit = d3;
                voice.vc_FilterPos        = 32;
            
                voice.vc_PerfWait    = 0;
                voice.vc_PerfCurrent = 0;
                voice.vc_PerfSpeed = Ins.ins_PList.pls_Speed;
                //voice.vc_PerfList  = &voice.vc_Instrument.ins_PList;
                voice.vc_PerfList  = voice.vc_Instrument.ins_PList;
                
                //WARNING: "unreachable" value
                //voice.vc_RingMixSource   = null;   // No ring modulation
                voice.vc_RingMixSource   = null;   // No ring modulation
                voice.vc_RingSamplePos   = 0;
                voice.vc_RingPlantPeriod = 0;
                voice.vc_RingNewWaveform = 0;
            }
          
            voice.vc_PeriodSlideOn = 0;
          
            Note = hvl_process_stepfx_2( ht, voice, Step.stp_FX&0xf,  Step.stp_FXParam,  Note );  
            Note = hvl_process_stepfx_2( ht, voice, Step.stp_FXb&0xf, Step.stp_FXbParam, Note );

            if( Note ){
                voice.vc_TrackPeriod = Note;
                voice.vc_PlantPeriod = 1;
            }
          
            hvl_process_stepfx_3( ht, voice, Step.stp_FX&0xf,  Step.stp_FXParam );  
            hvl_process_stepfx_3( ht, voice, Step.stp_FXb&0xf, Step.stp_FXbParam );  
        }

        private function hvl_plist_command_parse( ht:hvl_tune, voice:hvl_voice, FX:int, FXParam:int ):void{
            switch( FX ){
                case 0:
                    if( ( FXParam > 0 ) && ( FXParam < 0x40 ) ){
                        if( voice.vc_IgnoreFilter ){
                            voice.vc_FilterPos    = voice.vc_IgnoreFilter;
                            voice.vc_IgnoreFilter = 0;
                        } else {
                            voice.vc_FilterPos    = FXParam;
                        }
                        voice.vc_NewWaveform = 1;
                    }
                    break;

                case 1:
                    voice.vc_PeriodPerfSlideSpeed = FXParam;
                    voice.vc_PeriodPerfSlideOn    = 1;
                    break;

                case 2:
                    voice.vc_PeriodPerfSlideSpeed = -FXParam;
                    voice.vc_PeriodPerfSlideOn    = 1;
                    break;
            
                case 3:
                    if( voice.vc_IgnoreSquare == 0 ){
                        voice.vc_SquarePos = FXParam >> (5-voice.vc_WaveLength);
                    } else {
                        voice.vc_IgnoreSquare = 0;
                    }
                    break;
            
                case 4:
                    if( FXParam == 0 ){
                        voice.vc_SquareInit = (voice.vc_SquareOn ^= 1);
                        voice.vc_SquareSign = 1;
                    } else {

                        if( FXParam & 0x0f ){
                            voice.vc_SquareInit = (voice.vc_SquareOn ^= 1);
                            voice.vc_SquareSign = 1;
                            if(( FXParam & 0x0f ) == 0x0f ){
                                voice.vc_SquareSign = -1;
                            }
                        }
                
                        if( FXParam & 0xf0 ){
                            voice.vc_FilterInit = (voice.vc_FilterOn ^= 1);
                            voice.vc_FilterSign = 1;
                            if(( FXParam & 0xf0 ) == 0xf0 ){
                                voice.vc_FilterSign = -1;
                            }
                        }
                    }
                    break;
            
                case 5:
                    voice.vc_PerfCurrent = FXParam;
                    break;
            
                case 7:
                    // Ring modulate with triangle
                    if(( FXParam >= 1 ) && ( FXParam <= 0x3C )){
                        voice.vc_RingBasePeriod = FXParam;
                        voice.vc_RingFixedPeriod = 1;
                    } else if(( FXParam >= 0x81 ) && ( FXParam <= 0xBC )) {
                        voice.vc_RingBasePeriod = FXParam-0x80;
                        voice.vc_RingFixedPeriod = 0;
                    } else {
                        voice.vc_RingBasePeriod = 0;
                        voice.vc_RingFixedPeriod = 0;
                        voice.vc_RingNewWaveform = 0;
                        //WARNING: "unreachable" value
                        //voice.vc_RingAudioSource = NULL; // turn it off
                        //voice.vc_RingMixSource   = NULL;
                        voice.vc_RingAudioSource = uint.MAX_VALUE; // turn it off
                        voice.vc_RingMixSource   = null;
                        break;
                    }    
                    voice.vc_RingWaveform    = 0;
                    voice.vc_RingNewWaveform = 1;
                    voice.vc_RingPlantPeriod = 1;
                    break;
            
                case 8:  // Ring modulate with sawtooth
                    if(( FXParam >= 1 ) && ( FXParam <= 0x3C )){
                        voice.vc_RingBasePeriod = FXParam;
                        voice.vc_RingFixedPeriod = 1;
                    } else if(( FXParam >= 0x81 ) && ( FXParam <= 0xBC )) {
                        voice.vc_RingBasePeriod = FXParam-0x80;
                        voice.vc_RingFixedPeriod = 0;
                    } else {
                        voice.vc_RingBasePeriod = 0;
                        voice.vc_RingFixedPeriod = 0;
                        voice.vc_RingNewWaveform = 0;
                        //WARNING: "unreachable" value
                        //voice.vc_RingAudioSource = NULL; // turn it off
                        //voice.vc_RingMixSource   = NULL;
                        voice.vc_RingAudioSource = uint.MAX_VALUE; // turn it off
                        voice.vc_RingMixSource   = null;
                        break;
                    }

                    voice.vc_RingWaveform    = 1;
                    voice.vc_RingNewWaveform = 1;
                    voice.vc_RingPlantPeriod = 1;
                    break;

                /* New in HivelyTracker 1.4 */    
                case 9:    
                    if( FXParam > 127 ){
                        FXParam -= 256;
                    }
                    voice.vc_Pan          = (FXParam+128);
                    voice.vc_PanMultLeft  = panning_left[voice.vc_Pan];
                    voice.vc_PanMultRight = panning_right[voice.vc_Pan];
                    break;

                case 12:
                    if( FXParam <= 0x40 ){
                        voice.vc_NoteMaxVolume = FXParam;
                        break;
                    }
              
                    if( (FXParam -= 0x50) < 0 ) break;

                    if( FXParam <= 0x40 ){
                        voice.vc_PerfSubVolume = FXParam;
                        break;
                    }
              
                    if( (FXParam -= 0xa0-0x50) < 0 ) break;
              
                    if( FXParam <= 0x40 ){
                        voice.vc_TrackMasterVolume = FXParam;
                    }
                    break;
            
                case 15:
                    voice.vc_PerfSpeed = voice.vc_PerfWait = FXParam;
                    break;
            } 
        }

        private function hvl_process_frame( ht:hvl_tune, voice:hvl_voice ):void{
            const Offsets:Vector.<uint> = Vector.<uint>([0x00, 0x04, 0x04+0x08, 0x04+0x08+0x10, 0x04+0x08+0x10+0x20, 0x04+0x08+0x10+0x20+0x40]);

            if( voice.vc_TrackOn == 0 ){
                return;
            }

            if( voice.vc_NoteDelayOn ){
                if( voice.vc_NoteDelayWait <= 0 ){
                    hvl_process_step( ht, voice );
                } else {
                    voice.vc_NoteDelayWait--;
                }
            }
          
            if( voice.vc_HardCut ){
                var nextinst:int;     //int32
            
                if( ht.ht_NoteNr+1 < ht.ht_TrackLength ){
                    nextinst = ht.ht_Tracks[voice.vc_Track][ht.ht_NoteNr+1].stp_Instrument;
                } else {
                    nextinst = ht.ht_Tracks[voice.vc_NextTrack][0].stp_Instrument;
                }
            
                if( nextinst ){
                    var d1:int;         //int32
                  
                    d1 = ht.ht_Tempo - voice.vc_HardCut;
                  
                    if( d1 < 0 ) d1 = 0;
                
                    if( !voice.vc_NoteCutOn ){
                        voice.vc_NoteCutOn       = 1;
                        voice.vc_NoteCutWait     = d1;
                        voice.vc_HardCutReleaseF = -(d1-ht.ht_Tempo);
                    } else {
                        voice.vc_HardCut = 0;
                    }
                }
            }
            
            if( voice.vc_NoteCutOn ){
                if( voice.vc_NoteCutWait <= 0 ){
                    voice.vc_NoteCutOn = 0;
                
                    if( voice.vc_HardCutRelease ){
                        voice.vc_ADSR.rVolume = -(voice.vc_ADSRVolume - (voice.vc_Instrument.ins_Envelope.rVolume << 8)) / voice.vc_HardCutReleaseF;
                        voice.vc_ADSR.rFrames = voice.vc_HardCutReleaseF;
                        voice.vc_ADSR.aFrames = voice.vc_ADSR.dFrames = voice.vc_ADSR.sFrames = 0;
                    } else {
                        voice.vc_NoteMaxVolume = 0;
                    }
                } else {
                    voice.vc_NoteCutWait--;
                }
            }
            
            // ADSR envelope
            if( voice.vc_ADSR.aFrames ){
                voice.vc_ADSRVolume += voice.vc_ADSR.aVolume;
              
                if( --voice.vc_ADSR.aFrames <= 0 ){
                    voice.vc_ADSRVolume = voice.vc_Instrument.ins_Envelope.aVolume << 8;
                }

            } else if( voice.vc_ADSR.dFrames ) {
            
                voice.vc_ADSRVolume += voice.vc_ADSR.dVolume;
              
                if( --voice.vc_ADSR.dFrames <= 0 ){
                    voice.vc_ADSRVolume = voice.vc_Instrument.ins_Envelope.dVolume << 8;
                }
            
            } else if( voice.vc_ADSR.sFrames ) {
            
                voice.vc_ADSR.sFrames--;
            
            } else if( voice.vc_ADSR.rFrames ) {
            
                voice.vc_ADSRVolume += voice.vc_ADSR.rVolume;
            
                if( --voice.vc_ADSR.rFrames <= 0 ){
                    voice.vc_ADSRVolume = voice.vc_Instrument.ins_Envelope.rVolume << 8;
                }
            }

            // VolumeSlide
            voice.vc_NoteMaxVolume = voice.vc_NoteMaxVolume + voice.vc_VolumeSlideUp - voice.vc_VolumeSlideDown;

            if( voice.vc_NoteMaxVolume < 0 ){
                voice.vc_NoteMaxVolume = 0;
            } else if ( voice.vc_NoteMaxVolume > 0x40 ){
                voice.vc_NoteMaxVolume = 0x40;
            }

            // Portamento
            if( voice.vc_PeriodSlideOn ){
                if( voice.vc_PeriodSlideWithLimit ){
                    var d0:int, d2:int;      //int32
                  
                    d0 = voice.vc_PeriodSlidePeriod - voice.vc_PeriodSlideLimit;
                    d2 = voice.vc_PeriodSlideSpeed;
              
                    if( d0 > 0 ) d2 = -d2;
              
                    if( d0 ){
                        var d3:int;          //int32
                 
                        d3 = (d0 + d2) ^ d0;
                
                        if( d3 >= 0 ){
                            d0 = voice.vc_PeriodSlidePeriod + d2;
                        } else {
                            d0 = voice.vc_PeriodSlideLimit;
                        }
                
                        voice.vc_PeriodSlidePeriod = d0;
                        voice.vc_PlantPeriod = 1;
                    }
                } else {
                    voice.vc_PeriodSlidePeriod += voice.vc_PeriodSlideSpeed;
                    voice.vc_PlantPeriod = 1;
                }
            }
          
            // Vibrato
            if( voice.vc_VibratoDepth ){
                if( voice.vc_VibratoDelay <= 0 ){
                    voice.vc_VibratoPeriod = (cons.vib_tab[voice.vc_VibratoCurrent] * voice.vc_VibratoDepth) >> 7;
                    voice.vc_PlantPeriod = 1;
                    voice.vc_VibratoCurrent = (voice.vc_VibratoCurrent + voice.vc_VibratoSpeed) & 0x3f;
                } else {
                    voice.vc_VibratoDelay--;
                }
            }
          
            // PList
            if( voice.vc_PerfList ){
                if( voice.vc_Instrument && voice.vc_PerfCurrent < voice.vc_Instrument.ins_PList.pls_Length ){
                    if( --voice.vc_PerfWait <= 0 ){
                        var i:uint;       //uint32
                        var cur:int;      //int32
                
                        cur = voice.vc_PerfCurrent++;
                        voice.vc_PerfWait = voice.vc_PerfSpeed;
                
                        if( voice.vc_PerfList.pls_Entries[cur].ple_Waveform ){
                            voice.vc_Waveform             = voice.vc_PerfList.pls_Entries[cur].ple_Waveform-1;
                            voice.vc_NewWaveform          = 1;
                            voice.vc_PeriodPerfSlideSpeed = voice.vc_PeriodPerfSlidePeriod = 0;
                        }
                
                        // Holdwave
                        voice.vc_PeriodPerfSlideOn = 0;
                
                        for( i=0; i<2; i++ ){
                            hvl_plist_command_parse( ht, voice, voice.vc_PerfList.pls_Entries[cur].ple_FX[i]&0xff, voice.vc_PerfList.pls_Entries[cur].ple_FXParam[i]&0xff );
                        }
                
                        // GetNote
                        if( voice.vc_PerfList.pls_Entries[cur].ple_Note ){
                            voice.vc_InstrPeriod = voice.vc_PerfList.pls_Entries[cur].ple_Note;
                            voice.vc_PlantPeriod = 1;
                            voice.vc_FixedNote   = voice.vc_PerfList.pls_Entries[cur].ple_Fixed;
                        }
                    }
                } else {
                    if( voice.vc_PerfWait ){
                        voice.vc_PerfWait--;
                    } else {
                        voice.vc_PeriodPerfSlideSpeed = 0;
                    }
                }
            }
          
            // PerfPortamento
            if( voice.vc_PeriodPerfSlideOn ){
                voice.vc_PeriodPerfSlidePeriod -= voice.vc_PeriodPerfSlideSpeed;
            
                if( voice.vc_PeriodPerfSlidePeriod ){
                    voice.vc_PlantPeriod = 1;
                }
            }
          
            if( voice.vc_Waveform == 3-1 && voice.vc_SquareOn ){
                if( --voice.vc_SquareWait <= 0 ){
                    var d1:int, d2:int, d3:int;     //int32
              
                    d1 = voice.vc_SquareLowerLimit;
                    d2 = voice.vc_SquareUpperLimit;
                    d3 = voice.vc_SquarePos;
              
                    if( voice.vc_SquareInit ){
                        voice.vc_SquareInit = 0;
                
                        if( d3 <= d1 ){
                            voice.vc_SquareSlidingIn = 1;
                            voice.vc_SquareSign = 1;
                        } else if( d3 >= d2 ) {
                            voice.vc_SquareSlidingIn = 1;
                            voice.vc_SquareSign = -1;
                        }
                    }
              
                    // NoSquareInit
                    if( d1 == d3 || d2 == d3 ){
                        if( voice.vc_SquareSlidingIn ){
                            voice.vc_SquareSlidingIn = 0;
                        } else {
                            voice.vc_SquareSign = -voice.vc_SquareSign;
                        }
                    }
              
                    d3 += voice.vc_SquareSign;
                    voice.vc_SquarePos   = d3;
                    voice.vc_PlantSquare = 1;
                    voice.vc_SquareWait  = voice.vc_Instrument.ins_SquareSpeed;
                }
            }
          
            if( voice.vc_FilterOn && --voice.vc_FilterWait <= 0 ){ //TODO: check C vs AS3 operator precedence!
                var i:uint, FMax:uint;            //uint32
                var d1:int, d2:int, d3:int;       //int32
            
                d1 = voice.vc_FilterLowerLimit;
                d2 = voice.vc_FilterUpperLimit;
                d3 = voice.vc_FilterPos;
            
                if( voice.vc_FilterInit ){
                    voice.vc_FilterInit = 0;
                    if( d3 <= d1 ){
                        voice.vc_FilterSlidingIn = 1;
                        voice.vc_FilterSign      = 1;
                    } else if( d3 >= d2 ) {
                        voice.vc_FilterSlidingIn = 1;
                        voice.vc_FilterSign      = -1;
                    }
                }
            
                // NoFilterInit
                FMax = (voice.vc_FilterSpeed < 3) ? (5-voice.vc_FilterSpeed) : 1;

                for( i=0; i<FMax; i++ ){
                    if( ( d1 == d3 ) || ( d2 == d3 ) ){
                        if( voice.vc_FilterSlidingIn ){
                            voice.vc_FilterSlidingIn = 0;
                        } else {
                            voice.vc_FilterSign = -voice.vc_FilterSign;
                        }
                    }
                    d3 += voice.vc_FilterSign;
                }
            
                if( d3 < 1 )  d3 = 1;
                if( d3 > 63 ) d3 = 63;
                voice.vc_FilterPos   = d3;
                voice.vc_NewWaveform = 1;
                voice.vc_FilterWait  = voice.vc_FilterSpeed - 3;
            
                if( voice.vc_FilterWait < 1 ){
                    voice.vc_FilterWait = 1;
                }
            }

            if( voice.vc_Waveform == 3-1 || voice.vc_PlantSquare ){
                // CalcSquare
                var i:uint;              //uint32
                var Delta:int;           //int32
                var SquarePtr:uint;      //*int8
                var X:int;               //int32
            
                //SquarePtr = &waves[WO_SQUARES+(voice.vc_FilterPos-0x20)*(0xfc+0xfc+0x80*0x1f+0x80+0x280*3)];
                SquarePtr = cons.WO_SQUARES+(voice.vc_FilterPos-0x20)*(0xfc+0xfc+0x80*0x1f+0x80+0x280*3);
                X = voice.vc_SquarePos << (5 - voice.vc_WaveLength);
            
                if( X > 0x20 ){
                    X = 0x40 - X;
                    voice.vc_SquareReverse = 1;
                }
            
                // OkDownSquare
                if( X > 0 ){
                    SquarePtr += (X-1) << 7;
                }
            
                Delta = 32 >> voice.vc_WaveLength;
                //TODO: fix this!
				
                ht.ht_WaveformTab_i2 = voice.vc_SquareTempBuffer;
				ht.ht_WaveformTab[2] = 0;
            
                for( i=0; i<(1<<voice.vc_WaveLength)*4; i++ ){
                    voice.vc_SquareTempBuffer[i] = waves[SquarePtr];
                    SquarePtr += Delta;
                }
				
                voice.vc_NewWaveform = 1;
                voice.vc_Waveform    = 3-1;
                voice.vc_PlantSquare = 0;
            }
          
            if( voice.vc_Waveform == 4-1 ){
                voice.vc_NewWaveform = 1;
            }
          
            if( voice.vc_RingNewWaveform ){
                var rasrc:uint;        //*int8
            
                if( voice.vc_RingWaveform > 1 ){
                    voice.vc_RingWaveform = 1;
                }
                //TODO: check this!
                rasrc = ht.ht_WaveformTab[voice.vc_RingWaveform];
                rasrc += Offsets[voice.vc_WaveLength];
            
                voice.vc_RingAudioSource = rasrc;
            }    
                
          
            if( voice.vc_NewWaveform ){
                var AudioSource:uint;       //*int8

                AudioSource = ht.ht_WaveformTab[voice.vc_Waveform];
                
                if( voice.vc_Waveform != 3-1 ){
                    AudioSource += (voice.vc_FilterPos-0x20)*(0xfc+0xfc+0x80*0x1f+0x80+0x280*3);
                }

                if( voice.vc_Waveform < 3-1){
                    // GetWLWaveformlor2
                    AudioSource += Offsets[voice.vc_WaveLength];
                }

                if( voice.vc_Waveform == 4-1 ){
                    // AddRandomMoving
                    AudioSource += ( voice.vc_WNRandom & (2*0x280-1) ) & ~1;
                    // GoOnRandom
                    voice.vc_WNRandom += 2239384;
                    //voice.vc_WNRandom  = ((((voice.vc_WNRandom >> 8) | (voice.vc_WNRandom << 24)) + 782323) ^ 75) - 6735;
                    voice.vc_WNRandom  = ((tools.bitRotate(8, voice.vc_WNRandom, 32) + 782323) ^ 75) - 6735;
                }

                voice.vc_AudioSource = AudioSource;
            }
          
            // Ring modulation period calculation
            //TODO: Check! We use uint.MAX_VALUE instead of NULL.
            if( voice.vc_RingAudioSource != uint.MAX_VALUE ){
                voice.vc_RingAudioPeriod = voice.vc_RingBasePeriod;
          
                if( !(voice.vc_RingFixedPeriod) ){
                    if( voice.vc_OverrideTranspose != 1000 ){  // 1.5
                        voice.vc_RingAudioPeriod += voice.vc_OverrideTranspose + voice.vc_TrackPeriod - 1;
                    } else {
                        voice.vc_RingAudioPeriod += voice.vc_Transpose + voice.vc_TrackPeriod - 1;
                    }
                }
          
                if( voice.vc_RingAudioPeriod > 5*12 ){
                    voice.vc_RingAudioPeriod = 5*12;
                }
          
                if( voice.vc_RingAudioPeriod < 0 ){
                    voice.vc_RingAudioPeriod = 0;
                }
          
                voice.vc_RingAudioPeriod = cons.period_tab[voice.vc_RingAudioPeriod];

                if( !(voice.vc_RingFixedPeriod) ){
                    voice.vc_RingAudioPeriod += voice.vc_PeriodSlidePeriod;
                }

                voice.vc_RingAudioPeriod += voice.vc_PeriodPerfSlidePeriod + voice.vc_VibratoPeriod;

                if( voice.vc_RingAudioPeriod > 0x0d60 ){
                    voice.vc_RingAudioPeriod = 0x0d60;
                }

                if( voice.vc_RingAudioPeriod < 0x0071 ){
                    voice.vc_RingAudioPeriod = 0x0071;
                }
            }
          
            // Normal period calculation
            voice.vc_AudioPeriod = voice.vc_InstrPeriod;
          
            if( !(voice.vc_FixedNote) ){
                if( voice.vc_OverrideTranspose != 1000 ){ // 1.5
                    voice.vc_AudioPeriod += voice.vc_OverrideTranspose + voice.vc_TrackPeriod - 1;
                } else {
                    voice.vc_AudioPeriod += voice.vc_Transpose + voice.vc_TrackPeriod - 1;
                }
            }
            
            if( voice.vc_AudioPeriod > 5*12 ){
                voice.vc_AudioPeriod = 5*12;
            }
          
            if( voice.vc_AudioPeriod < 0 ){
                voice.vc_AudioPeriod = 0;
            }
          
            voice.vc_AudioPeriod = cons.period_tab[voice.vc_AudioPeriod];
          
            if( !(voice.vc_FixedNote) ){
                voice.vc_AudioPeriod += voice.vc_PeriodSlidePeriod;
            }

            voice.vc_AudioPeriod += voice.vc_PeriodPerfSlidePeriod + voice.vc_VibratoPeriod;    

            if( voice.vc_AudioPeriod > 0x0d60 ){
                voice.vc_AudioPeriod = 0x0d60;
            }

            if( voice.vc_AudioPeriod < 0x0071 ){
                voice.vc_AudioPeriod = 0x0071;
            }
          
            voice.vc_AudioVolume = (((((((voice.vc_ADSRVolume >> 8) * voice.vc_NoteMaxVolume) >> 6) * voice.vc_PerfSubVolume) >> 6) * voice.vc_TrackMasterVolume) >> 6);
        }

        private function hvl_set_audio( voice:hvl_voice, freqf:Number ):void{
            if( voice.vc_TrackOn == 0 ){
                voice.vc_VoiceVolume = 0;
                return;
            }
  
            voice.vc_VoiceVolume = voice.vc_AudioVolume;
  
            if( voice.vc_PlantPeriod ){
                var freq2:Number;   //float64
                var delta:uint;     //uint32
    
                voice.vc_PlantPeriod = 0;
                voice.vc_VoicePeriod = voice.vc_AudioPeriod;
    
                freq2 = Period2Freq( voice.vc_AudioPeriod );
                delta = uint(freq2 / freqf);

                if( delta > (0x280<<16) ) delta -= (0x280<<16);
                if( delta == 0 ) delta = 1;
                voice.vc_Delta = delta;
            }
  
            if( voice.vc_NewWaveform ){
                var src:uint;        //*int8
				var ref:Vector.<int>;
				if (voice.vc_Waveform == 2) {
					ref = voice.vc_SquareTempBuffer;
				}else {
					ref = waves;
				}
                src = voice.vc_AudioSource;
    
                if( voice.vc_Waveform == 4-1 ){
                    //memcpy( &voice->vc_VoiceBuffer[0], src, 0x280 );
                    for ( var ii:uint = 0; ii < 0x280; ii++ ) {
                         voice.vc_VoiceBuffer[ii] = ref[src + ii];
                    }
                } else {
                    var i:uint, WaveLoops:uint;        //uint32

                    WaveLoops = (1 << (5 - voice.vc_WaveLength)) * 5;

                    for( i=0; i<WaveLoops; i++ ){
                        //memcpy( &voice->vc_VoiceBuffer[i*4*(1<<voice->vc_WaveLength)], src, 4*(1<<voice->vc_WaveLength) );
                        for( var j:uint=0; j<4*(1<<voice.vc_WaveLength); j++ ){
                            voice.vc_VoiceBuffer[i*4*(1<<voice.vc_WaveLength)+j] = ref[src+j];
                        }
                    }
                }

                voice.vc_VoiceBuffer[0x280] = voice.vc_VoiceBuffer[0];
                voice.vc_MixSource          = voice.vc_VoiceBuffer;
            }

            /* Ring Modulation */
            if( voice.vc_RingPlantPeriod ){
                var freq2:Number;     //float64
                var delta:uint;       //uint32
    
                voice.vc_RingPlantPeriod = 0;
                freq2 = Period2Freq( voice.vc_RingAudioPeriod );
                //delta = (uint32)(freq2 / freqf);
				delta = uint(freq2 / freqf);
    
                if( delta > (0x280<<16) ) delta -= (0x280<<16);
                if( delta == 0 ) delta = 1;
                voice.vc_RingDelta = delta;
            }
  
            if( voice.vc_RingNewWaveform ){
                var src:uint;                  //*int8
                var i:uint, WaveLoops:uint;    //uint32
				var ref:Vector.<int>;
				if (voice.vc_Waveform == 2) {
					ref = voice.vc_SquareTempBuffer;
				}else {
					ref = waves;
				}
				
                src = voice.vc_RingAudioSource;

                WaveLoops = (1 << (5 - voice.vc_WaveLength)) * 5;

                for( i=0; i<WaveLoops; i++ ){
                    //memcpy( &voice->vc_RingVoiceBuffer[i*4*(1<<voice->vc_WaveLength)], src, 4*(1<<voice->vc_WaveLength) );
                    for( var j:uint=0; j<4*(1<<voice.vc_WaveLength);j++ ){
                        voice.vc_RingVoiceBuffer[i*4*(1<<voice.vc_WaveLength)+j] = ref[src+j];
                    }
                }

                voice.vc_RingVoiceBuffer[0x280] = voice.vc_RingVoiceBuffer[0];
                voice.vc_RingMixSource          = voice.vc_RingVoiceBuffer;
            }
        }

        private function hvl_play_irq( ht:hvl_tune ):void{
            var i:uint;         //uint32

            if( ht.ht_StepWaitFrames <= 0 ){
                if( ht.ht_GetNewPosition ){
                    var nextpos:int = (ht.ht_PosNr+1==ht.ht_PositionNr)?0:(ht.ht_PosNr+1);     //int32

                    for( i=0; i<ht.ht_Channels; i++ ){
                        ht.ht_Voices[i].vc_Track         = ht.ht_Positions[ht.ht_PosNr].pos_Track[i];
                        ht.ht_Voices[i].vc_Transpose     = ht.ht_Positions[ht.ht_PosNr].pos_Transpose[i];
                        ht.ht_Voices[i].vc_NextTrack     = ht.ht_Positions[nextpos].pos_Track[i];
                        ht.ht_Voices[i].vc_NextTranspose = ht.ht_Positions[nextpos].pos_Transpose[i];
                    }
                    ht.ht_GetNewPosition = 0;
                }
    
                for( i=0; i<ht.ht_Channels; i++ ){
                    hvl_process_step( ht, ht.ht_Voices[i] );
                }
    
                ht.ht_StepWaitFrames = ht.ht_Tempo;
            }
  
            for( i=0; i<ht.ht_Channels; i++ ){
                hvl_process_frame( ht, ht.ht_Voices[i] );
            }

            ht.ht_PlayingTime++;
            if( ht.ht_Tempo > 0 && --ht.ht_StepWaitFrames <= 0 ){
                if( !ht.ht_PatternBreak ){
                    ht.ht_NoteNr++;
                    if( ht.ht_NoteNr >= ht.ht_TrackLength ){
                        ht.ht_PosJump      = ht.ht_PosNr+1;
                        ht.ht_PosJumpNote  = 0;
                        ht.ht_PatternBreak = 1;
                    }
                }
    
                if( ht.ht_PatternBreak ){
                    ht.ht_PatternBreak = 0;
                    ht.ht_PosNr        = ht.ht_PosJump;
                    ht.ht_NoteNr       = ht.ht_PosJumpNote;
                    if( ht.ht_PosNr == ht.ht_PositionNr ){
                        ht.ht_SongEndReached = 1;
                        ht.ht_PosNr          = ht.ht_Restart;
                    }
                    ht.ht_PosJumpNote  = 0;
                    ht.ht_PosJump      = 0;

                    ht.ht_GetNewPosition = 1;
                }
            }

            for( i=0; i<ht.ht_Channels; i++ ){
                hvl_set_audio( ht.ht_Voices[i], ht.ht_Frequency );
            }
        }

        //void hvl_mixchunk( ht:hvl_tune, samples:uint, int8 *buf1, int8 *buf2, int32 bufmod ){
        private function hvl_mixchunk( ht:hvl_tune, samples:uint, buf12:ByteArray ):void{
            //int8   *src[MAX_CHANNELS];      //*int8
            //int8   *rsrc[MAX_CHANNELS];     //*int8
            var src:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(cons.MAX_CHANNELS, true);  //*int8
			var rsrc:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(cons.MAX_CHANNELS, true); //*int8
            var delta:Vector.<uint> = new Vector.<uint>(cons.MAX_CHANNELS, true);                //uint32
            var rdelta:Vector.<uint> = new Vector.<uint>(cons.MAX_CHANNELS, true);               //uint32
            var vol:Vector.<int> = new Vector.<int>(cons.MAX_CHANNELS, true);                    //int32
            var pos:Vector.<uint> = new Vector.<uint>(cons.MAX_CHANNELS, true);                  //uint32
            var rpos:Vector.<uint> = new Vector.<uint>(cons.MAX_CHANNELS, true);                 //uint32
            var cnt:uint;                                                                        //uint32
            var panl:Vector.<int> = new Vector.<int>(cons.MAX_CHANNELS, true);                   //int32
            var panr:Vector.<int> = new Vector.<int>(cons.MAX_CHANNELS, true);                   //int32
            var vu:Vector.<uint> = new Vector.<uint>(cons.MAX_CHANNELS, true);                   //uint32
            var a:int=0, b:int=0, j:int;                                                         //int32
            var af:Number, bf:Number;
            var i:uint, chans:uint, loops:uint;                                                  //unit32
  
            chans = ht.ht_Channels;
            for( i=0; i<chans; i++ ){
                delta[i] = ht.ht_Voices[i].vc_Delta;
                vol[i]   = ht.ht_Voices[i].vc_VoiceVolume;
                pos[i]   = ht.ht_Voices[i].vc_SamplePos;
                src[i]   = ht.ht_Voices[i].vc_MixSource;
                panl[i]  = ht.ht_Voices[i].vc_PanMultLeft;
                panr[i]  = ht.ht_Voices[i].vc_PanMultRight;
				
				//ref[i] = ht.ht_Voices[i].vc_Waveform;
				
    
                /* Ring Modulation */
                rdelta[i]= ht.ht_Voices[i].vc_RingDelta;
                rpos[i]  = ht.ht_Voices[i].vc_RingSamplePos;
                rsrc[i]  = ht.ht_Voices[i].vc_RingMixSource;
    
                vu[i] = 0;
            }
  
            do{
                loops = samples;
                for( i=0; i<chans; i++ ){
                    if( pos[i] >= (0x280 << 16)) pos[i] -= 0x280<<16;
                    cnt = ((0x280<<16) - pos[i] - 1) / delta[i] + 1;
                    if( cnt < loops ) loops = cnt;
      
                    if( rsrc[i] ){
                        if( rpos[i] >= (0x280<<16)) rpos[i] -= 0x280<<16;
                        cnt = ((0x280<<16) - rpos[i] - 1) / rdelta[i] + 1;
                        if( cnt < loops ) loops = cnt;
                    }
      
                }
    
                samples -= loops;
                // Inner loop
                do{
                    a=0;
                    b=0;
                    for( i=0; i<chans; i++ ){
                        if( rsrc[i] ){
                            // Ring Modulation
                            j = ((src[i][pos[i]>>16]*rsrc[i][rpos[i]>>16])>>7)*vol[i];
                            rpos[i] += rdelta[i];
                        } else {
                            j = src[i][pos[i]>>16]*vol[i];
                        }
                        
                        if( Math.abs( j ) > vu[i] ) vu[i] = Math.abs( j );

                        a += (j * panl[i]) >> 7;
                        b += (j * panr[i]) >> 7;
                        pos[i] += delta[i];
                    }
      
                    a = (a*ht.ht_mixgain)>>8;
                    b = (b*ht.ht_mixgain)>>8;
                    //*(int16 *)buf1 = a;
                    //*(int16 *)buf2 = b;
                    if( a >= 0 ){
                        af = a / 32767; 
                    }else{
                        af = a / 32768;
                    }
                    
                    if( b >= 0 ){
                        bf = a / 32767;
                    }else{
                        bf = a / 32768;
                    }
                    buf12.writeFloat(af);
                    buf12.writeFloat(bf);
      
                    loops--;
      
                    //buf1 += bufmod;
                    //buf2 += bufmod;
                } while( loops > 0 );
            } while( samples > 0 );

            for( i=0; i<chans; i++ ){
                ht.ht_Voices[i].vc_SamplePos = pos[i];
                ht.ht_Voices[i].vc_RingSamplePos = rpos[i];
                ht.ht_Voices[i].vc_VUMeter = vu[i];
            }
        }
        
        
        //event.data as buf12; ByteArray
        //public function hvl_DecodeFrame( ht:hvl_tune, int8 *buf1, int8 *buf2, int32 bufmod ):void
        public function hvl_DecodeFrame( ht:hvl_tune, buf12:ByteArray ):void{
            var samples:uint, loops:uint;       //uint32
  
            samples = ht.ht_Frequency/50/ht.ht_SpeedMultiplier;
            loops   = ht.ht_SpeedMultiplier;
  
            do{
                hvl_play_irq( ht );
                //hvl_mixchunk( ht, samples, buf1, buf2, bufmod );
                hvl_mixchunk( ht, samples, buf12 );
                //buf1 += samples * bufmod;
                //buf2 += samples * bufmod;
                loops--;
            } while( loops );
        }









    }
}
        
        
