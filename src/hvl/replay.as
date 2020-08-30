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

package hvl {
    import flash.events.*;
    import flash.media.*;
    import flash.utils.*;
    import hvl.struct.*;
    
    internal class replay{
        
        private static const stepW:uint = 64;
        
        public function replay():void {
            new tables();
        } 
        
        /*  inlined
        private function Period2Freq(period:int):Number{
            return cons.AMIGA_PAULA_PAL_CLK * 65536.0 / period;
        }
        */
        
        internal function reset_some_stuff(ht:tune):void{
            var i:uint;
            var htVoice:voice;
            
            for( i=0; i<cons.MAX_CHANNELS; i++ ){
                htVoice= ht.Voices[i];
                
                htVoice.Delta=1;
                htVoice.OverrideTranspose=1000;  // 1.5
                htVoice.SamplePos=0;
                htVoice.Track=0;
                htVoice.Transpose=0;
                htVoice.NextTrack=0;
                htVoice.NextTranspose=0;
                
                htVoice.ADSRVolume=0;
                htVoice.InstrPeriod=0;
                htVoice.TrackPeriod=0;
                htVoice.VibratoPeriod=0;
                htVoice.NoteMaxVolume=0;
                htVoice.PerfSubVolume=0;
                htVoice.TrackMasterVolume=0;
                
                htVoice.NewWaveform=0;
                htVoice.Waveform=0;
                htVoice.PlantSquare=0;
                htVoice.PlantPeriod=0;
                htVoice.IgnoreSquare=0;
                
                htVoice.TrackOn=0;
                htVoice.FixedNote=0;
                htVoice.VolumeSlideUp=0;
                htVoice.VolumeSlideDown=0;
                htVoice.HardCut=0;
                htVoice.HardCutRelease=0;
                htVoice.HardCutReleaseF=0;
                
                htVoice.PeriodSlideSpeed=0;
                htVoice.PeriodSlidePeriod=0;
                htVoice.PeriodSlideLimit=0;
                htVoice.PeriodSlideOn=0;
                htVoice.PeriodSlideWithLimit=0;
                
                htVoice.PeriodPerfSlideSpeed=0;
                htVoice.PeriodPerfSlidePeriod=0;
                htVoice.PeriodPerfSlideOn=0;
                htVoice.VibratoDelay=0;
                htVoice.VibratoCurrent=0;
                htVoice.VibratoDepth=0;
                htVoice.VibratoSpeed=0;
                
                htVoice.SquareOn=0;
                htVoice.SquareInit=0;
                htVoice.SquareLowerLimit=0;
                htVoice.SquareUpperLimit=0;
                htVoice.SquarePos=0;
                htVoice.SquareSign=0;
                htVoice.SquareSlidingIn=0;
                htVoice.SquareReverse=0;
                
                htVoice.FilterOn=0;
                htVoice.FilterInit=0;
                htVoice.FilterLowerLimit=0;
                htVoice.FilterUpperLimit=0;
                htVoice.FilterPos=0;
                htVoice.FilterSign=0;
                htVoice.FilterSpeed=0;
                htVoice.FilterSlidingIn=0;
                htVoice.IgnoreFilter=0;
                
                htVoice.PerfCurrent=0;
                htVoice.PerfSpeed=0;
                htVoice.WaveLength=0;
                htVoice.NoteDelayOn=0;
                htVoice.NoteCutOn=0;
                
                htVoice.AudioPeriod=0;
                htVoice.AudioVolume=0;
                htVoice.VoiceVolume=0;
                htVoice.VoicePeriod=0;
                htVoice.VoiceNum=0;
                htVoice.WNRandom=0;
                
                htVoice.SquareWait=0;
                htVoice.FilterWait=0;
                htVoice.PerfWait=0;
                htVoice.NoteDelayWait=0;
                htVoice.NoteCutWait=0;
                
                htVoice.PerfList=null;
                
                htVoice.RingSamplePos=0;
                htVoice.RingDelta=0;
                htVoice.RingPlantPeriod=0;
                htVoice.RingAudioPeriod=0;
                htVoice.RingNewWaveform=0;
                htVoice.RingWaveform=0;
                htVoice.RingFixedPeriod=0;
                htVoice.RingBasePeriod=0;

                htVoice.RingMixSource = null;
                htVoice.RingAudioSource = uint.MAX_VALUE;
                
                var j:uint;
                for(j=0;j<0x80;j++){
                    htVoice.SquareTempBuffer[j]=0;
                }
                htVoice.ADSR.aFrames=0;
                htVoice.ADSR.aVolume=0;
                htVoice.ADSR.dFrames=0;
                htVoice.ADSR.dVolume=0;
                htVoice.ADSR.sFrames=0;
                htVoice.ADSR.rFrames=0;
                htVoice.ADSR.rVolume=0;
                htVoice.ADSR.pad=0;
                for(j=0;j<0x281;j++){ //Should be 0x282*4
                    htVoice.VoiceBuffer[j]=0;
                }
                for(j=0;j<0x281;j++){ //same
                    htVoice.RingVoiceBuffer[j]=0;
                }
                
                htVoice.WNRandom          = 0x280;
                htVoice.VoiceNum          = i;
                htVoice.TrackMasterVolume = 0x40;
                htVoice.TrackOn           = 1;
                htVoice.MixSource         = htVoice.VoiceBuffer;
            }
        }
        
        internal function InitSubsong( ht:tune, nr:uint ):Boolean{
            var PosNr:uint, i:uint; j:uint;

            if( nr > ht.SubsongNr ){
                return false;
            }

            ht.SongNum = nr;

            PosNr = 0;
            if( nr ){
                PosNr = ht.Subsongs[nr-1];
            }

            ht.PosNr          = PosNr;
            ht.PosJump        = 0;
            ht.PatternBreak   = 0;
            ht.NoteNr         = 0;
            ht.PosJumpNote    = 0;
            ht.Tempo          = 6;
            ht.StepWaitFrames = 0;
            ht.GetNewPosition = 1;
            ht.SongEndReached = 0;
            ht.PlayingTime    = 0;

            var htVoices:Vector.<voice> = ht.Voices;
            for( i=0; i<cons.MAX_CHANNELS; i+=4 ){
                htVoices[i+0].Pan          = ht.defpanleft;
                htVoices[i+0].SetPan       = ht.defpanleft; // 1.4
                htVoices[i+0].PanMultLeft  = tables.panning_left[ht.defpanleft];
                htVoices[i+0].PanMultRight = tables.panning_right[ht.defpanleft];
                htVoices[i+1].Pan          = ht.defpanright;
                htVoices[i+1].SetPan       = ht.defpanright; // 1.4
                htVoices[i+1].PanMultLeft  = tables.panning_left[ht.defpanright];
                htVoices[i+1].PanMultRight = tables.panning_right[ht.defpanright];
                htVoices[i+2].Pan          = ht.defpanright;
                htVoices[i+2].SetPan       = ht.defpanright; // 1.4
                htVoices[i+2].PanMultLeft  = tables.panning_left[ht.defpanright];
                htVoices[i+2].PanMultRight = tables.panning_right[ht.defpanright];
                htVoices[i+3].Pan          = ht.defpanleft;
                htVoices[i+3].SetPan       = ht.defpanleft;  // 1.4
                htVoices[i+3].PanMultLeft  = tables.panning_left[ht.defpanleft];
                htVoices[i+3].PanMultRight = tables.panning_right[ht.defpanleft];
            }

            reset_some_stuff(ht);

            return true;
        }
        
        internal function setPan( ht:tune, defstereo:uint ):void {
            if ( ht.FormatString.indexOf("AHX") < 0 ) {
                return;
            }
            var i:uint;
            ht.defstereo       = defstereo;
            ht.defpanleft      = tables.stereopan_left[ht.defstereo];
            ht.defpanright     = tables.stereopan_right[ht.defstereo];
            ht.mixgain         = (tables.defgain[ht.defstereo]*256)/100;
            
            var htVoices:Vector.<voice> = ht.Voices;
            for( i=0; i<cons.MAX_CHANNELS; i+=4 ){
                htVoices[i+0].Pan          = ht.defpanleft;
                htVoices[i+0].SetPan       = ht.defpanleft; // 1.4
                htVoices[i+0].PanMultLeft  = tables.panning_left[ht.defpanleft];
                htVoices[i+0].PanMultRight = tables.panning_right[ht.defpanleft];
                htVoices[i+1].Pan          = ht.defpanright;
                htVoices[i+1].SetPan       = ht.defpanright; // 1.4
                htVoices[i+1].PanMultLeft  = tables.panning_left[ht.defpanright];
                htVoices[i+1].PanMultRight = tables.panning_right[ht.defpanright];
                htVoices[i+2].Pan          = ht.defpanright;
                htVoices[i+2].SetPan       = ht.defpanright; // 1.4
                htVoices[i+2].PanMultLeft  = tables.panning_left[ht.defpanright];
                htVoices[i+2].PanMultRight = tables.panning_right[ht.defpanright];
                htVoices[i+3].Pan          = ht.defpanleft;
                htVoices[i+3].SetPan       = ht.defpanleft;  // 1.4
                htVoices[i+3].PanMultLeft  = tables.panning_left[ht.defpanleft];
                htVoices[i+3].PanMultRight = tables.panning_right[ht.defpanleft];
            }

            //reset_some_stuff(ht);
        }
        
        private function load_ahx( buf:ByteArray, defstereo:uint ):tune{
            var bptr:uint;      //*uint8
            var nptr:uint;      //*TEXT
            var buflen:uint, i:uint, j:uint, k:uint, l:uint, posn:uint, insn:uint, ssn:uint, hs:uint, trkn:uint, trkl:uint;
            var ht:tune;
            var ple:plsentry;
            
            buflen = buf.length;
            
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

            ht = new tune();
            ht.FormatString = "AHX" + "v" + buf[3];
            
            //Xeron says we don't do this.
            //ht.Version         = buf[3]; // 1.5
            ht.Frequency       = cons.sample_rate;
            ht.FreqF           = Number(cons.sample_rate);
  
            ht.malloc_positions(posn);
            ht.malloc_instruments(insn);
            ht.malloc_subsongs(ssn);

            ht.WaveformTab[0]  = tables.WO_TRIANGLE_04;
            ht.WaveformTab[1]  = tables.WO_SAWTOOTH_04;
            ht.WaveformTab[3]  = tables.WO_WHITENOISE;

            ht.Channels        = 4;
            ht.PositionNr      = posn;
            ht.Restart         = (buf[8]<<8)|buf[9];
            ht.SpeedMultiplier = ((buf[6]>>5)&3)+1;
            ht.TrackLength     = trkl;
            ht.TrackNr         = trkn;
            ht.InstrumentNr    = insn;
            ht.SubsongNr       = ssn;
            ht.defstereo       = defstereo;
            ht.defpanleft      = tables.stereopan_left[ht.defstereo];
            ht.defpanright     = tables.stereopan_right[ht.defstereo];
            ht.mixgain         = (tables.defgain[ht.defstereo]*256)/100;
  
            if( ht.Restart >= ht.PositionNr ){
                    ht.Restart = ht.PositionNr - 1;
            }

            // Do some validation  
            if( ( ht.PositionNr > 1000 ) ||
                ( ht.TrackLength > 64 ) ||
                ( ht.InstrumentNr > 64 ) ){
                    trace( ht.PositionNr+","+ht.TrackLength+","+ht.InstrumentNr );
                    ht = null;
                    buf.clear();
                    trace( "Invalid file.\n" );
                    return null;
            }

            ht.Name = tools.strncpy(buf, (buf[4]<<8)|buf[5], 128);
            nptr = ((buf[4]<<8)|buf[5])+ht.Name.length+1;

            bptr = 14;
  
            // Subsongs
            for( i=0; i<ht.SubsongNr; i++ ){
                ht.Subsongs[i] = (buf[bptr+0]<<8)|buf[bptr+1];
                if( ht.Subsongs[i] >= ht.PositionNr ){
                    ht.Subsongs[i] = 0;
                }
                bptr += 2;
            }
  
            // Position list
            for( i=0; i<ht.PositionNr; i++ ){
                for( j=0; j<4; j++ ){
                    ht.Positions[i].Track[j]     = buf[bptr++];
                    ht.Positions[i].Transpose[j] = tools.ui2i8(buf[bptr++]);
                }
            }
            
            // Tracks
            var htTrack:Vector.<step> = ht.Tracks;
            for( i=0; i<=ht.TrackNr; i++ ){
                if( ( ( buf[6]&0x80 ) == 0x80 ) && ( i == 0 ) ){
                    for( j=0; j<ht.TrackLength; j++ ){
                        htTrack[i*stepW+j].Note       = 0;
                        htTrack[i*stepW+j].Instrument = 0;
                        htTrack[i*stepW+j].FX         = 0;
                        htTrack[i*stepW+j].FXParam    = 0;
                        htTrack[i*stepW+j].FXb        = 0;
                        htTrack[i*stepW+j].FXbParam   = 0;
                    }
                    continue;
                }
    
                for( j=0; j<ht.TrackLength; j++ ){
                    htTrack[i*stepW+j].Note       = (buf[bptr+0]>>2)&0x3f;
                    htTrack[i*stepW+j].Instrument = ((buf[bptr+0]&0x3)<<4) | (buf[bptr+1]>>4);
                    htTrack[i*stepW+j].FX         = buf[bptr+1]&0xf;
                    htTrack[i*stepW+j].FXParam    = buf[bptr+2];
                    htTrack[i*stepW+j].FXb        = 0;
                    htTrack[i*stepW+j].FXbParam   = 0;
                    bptr += 3;
                }
            }
  
            // Instruments
            for( i=1; i<=ht.InstrumentNr; i++ ){
                var htInstr:instrument = ht.Instruments[i];
                
                if ( nptr < buflen ) {
                    htInstr.Name = tools.strncpy(buf, nptr, 128);
                    nptr += tools.strlen( buf, nptr )+1;
                } else {
                    htInstr.Name = "";
                }
    
                htInstr.Volume      = buf[bptr+0];
                htInstr.FilterSpeed = ((buf[bptr+1]>>3)&0x1f)|((buf[bptr+12]>>2)&0x20);
                htInstr.WaveLength  = buf[bptr+1]&0x07;

                htInstr.Envelope.aFrames = buf[bptr+2];
                htInstr.Envelope.aVolume = buf[bptr+3];
                htInstr.Envelope.dFrames = buf[bptr+4];
                htInstr.Envelope.dVolume = buf[bptr+5];
                htInstr.Envelope.sFrames = buf[bptr+6];
                htInstr.Envelope.rFrames = buf[bptr+7];
                htInstr.Envelope.rVolume = buf[bptr+8];
                
                //if (!htInstr.Envelope.aFrames ) trace("ht.Instruments["+i+"].Envelope.aFrames == 0");
                //if (!htInstr.Envelope.dFrames ) trace("ht.Instruments["+i+"].Envelope.dFrames == 0");
                //if (!htInstr.Envelope.rFrames ) trace("ht.Instruments["+i+"].Envelope.rFrames == 0");
                
                htInstr.FilterLowerLimit     = buf[bptr+12]&0x7f;
                htInstr.VibratoDelay         = buf[bptr+13];
                htInstr.HardCutReleaseFrames = (buf[bptr+14]>>4)&0x07;
                htInstr.HardCutRelease       = buf[bptr+14]&0x80?1:0;
                htInstr.VibratoDepth         = buf[bptr+14]&0x0f;
                htInstr.VibratoSpeed         = buf[bptr+15];
                htInstr.SquareLowerLimit     = buf[bptr+16];
                htInstr.SquareUpperLimit     = buf[bptr+17];
                htInstr.SquareSpeed          = buf[bptr+18];
                htInstr.FilterUpperLimit     = buf[bptr+19]&0x3f;
                htInstr.PList.Speed      = buf[bptr+20];
                htInstr.PList.Length     = buf[bptr+21];
                
                htInstr.PList.ple_malloc( buf[bptr+21] );
    
                bptr += 22;
                for( j=0; j<htInstr.PList.Length; j++ ){
                    var htPlsentry:plsentry = htInstr.PList.Entries[j];
                    
                    k = (buf[bptr+0]>>5)&7;
                    if( k == 6 ) k = 12;
                    if( k == 7 ) k = 15;
                    l = (buf[bptr+0]>>2)&7;
                    if( l == 6 ) l = 12;
                    if( l == 7 ) l = 15;
                    htPlsentry.FX[1]      = k;
                    htPlsentry.FX[0]      = l;
                    htPlsentry.Waveform   = ((buf[bptr+0]<<1)&6) | (buf[bptr+1]>>7);
                    htPlsentry.Fixed      = (buf[bptr+1]>>6)&1;
                    htPlsentry.Note       = buf[bptr+1]&0x3f;
                    htPlsentry.FXParam[0] = buf[bptr+2];
                    htPlsentry.FXParam[1] = buf[bptr+3];

                    // 1.6: Strip "toggle filter" commands if the module is
                    //      version 0 (pre-filters). This is what AHX also does.
                    if( ( buf[3] == 0 ) && ( l == 4 ) && ( (buf[bptr+2]&0xf0) != 0 ) )
                        htPlsentry.FXParam[0] &= 0x0f;
                    if( ( buf[3] == 0 ) && ( k == 4 ) && ( (buf[bptr+3]&0xf0) != 0 ) )
                        htPlsentry.FXParam[1] &= 0x0f; // 1.8

                    bptr += 4;
                }
            }
  
            InitSubsong( ht, 0 );
            buf.clear();
            ht.init_VUMeters();
            return ht;
        }

        public function LoadTune( buf:ByteArray, defstereo:uint ):tune {
            
            //THX
            if( ( buf[0] == 0x54 ) &&
                ( buf[1] == 0x48 ) &&
                ( buf[2] == 0x58 ) &&
                ( buf[3] < 3 ) ){
                    
                    return load_ahx( buf, defstereo);
                }
            //HVL
            else if( ( buf[0] == 0x48 ) ||
                     ( buf[1] == 0x56 ) ||
                     ( buf[2] == 0x4C ) ||
                     ( buf[3] > 1 ) ) {
                    
                    return load_hvl( buf, defstereo);
            }
            else{
                    trace( "Invalid file.\n" );
                    return null;
            }
            
        }
        
        private function load_hvl( buf:ByteArray, defstereo:uint ):tune{
            
            var ht:tune;            //*
            var bptr:uint;              //*uint8
            var nptr:uint;              //*TEXT
            var buflen:uint, i:uint, j:uint, posn:uint, insn:uint, ssn:uint, chnn:uint, hs:uint, trkl:uint, trkn:uint;

            buflen = buf.length;
            
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

            ht = new tune();
            ht.FormatString = "HVL" + "v" + buf[3];

            ht.Version         = buf[3]; // 1.5
            ht.Frequency       = cons.sample_rate;
            ht.FreqF           = Number(cons.sample_rate);

            ht.malloc_positions(posn);
            ht.malloc_instruments(insn);
            ht.malloc_subsongs(ssn);

            ht.WaveformTab[0]  = tables.WO_TRIANGLE_04;
            ht.WaveformTab[1]  = tables.WO_SAWTOOTH_04;
            ht.WaveformTab[3]  = tables.WO_WHITENOISE;

            ht.PositionNr      = posn;
            ht.Channels        = (buf[8]>>2)+4;
            ht.Restart         = ((buf[8]&3)<<8)|buf[9];
            ht.SpeedMultiplier = ((buf[6]>>5)&3)+1;
            ht.TrackLength     = buf[10];
            ht.TrackNr         = buf[11];
            ht.InstrumentNr    = insn;
            ht.SubsongNr       = ssn;
            ht.mixgain         = (buf[14]<<8)/100;
            ht.defstereo       = buf[15];
            ht.defpanleft      = tables.stereopan_left[ht.defstereo];
            ht.defpanright     = tables.stereopan_right[ht.defstereo];

            if( ht.Restart >= ht.PositionNr ){
                ht.Restart = ht.PositionNr - 1;
            }

            // Do some validation  
            if( ( ht.PositionNr > 1000 ) ||
                ( ht.TrackLength > 64 ) ||
                ( ht.InstrumentNr > 64 ) ){
                    trace( ht.PositionNr+","+ht.TrackLength+","+ht.InstrumentNr+"\n");
                    ht = null;
                    buf.clear();
                    trace( "Invalid file.\n" );
                    return null;
            }

            ht.Name = tools.strncpy(buf, (buf[4]<<8)|buf[5], 128);
            nptr = ((buf[4]<<8)|buf[5])+ht.Name.length+1;

            bptr = 16;

            // Subsongs
            for( i=0; i<ht.SubsongNr; i++ ){
                ht.Subsongs[i] = (buf[bptr+0]<<8)|buf[bptr+1];
                bptr += 2;
            }

            // Position list
            for( i=0; i<ht.PositionNr; i++ ){
                for( j=0; j<ht.Channels; j++ ){
                    ht.Positions[i].Track[j]     = buf[bptr++];
                    ht.Positions[i].Transpose[j] = tools.ui2i8(buf[bptr++]);
                }
            }

            // Tracks
            var htTrack:Vector.<step> = ht.Tracks;
            for( i=0; i<=ht.TrackNr; i++ ){
                if( ( ( buf[6]&0x80 ) == 0x80 ) && ( i == 0 ) ){
                    for( j=0; j<ht.TrackLength; j++ ){
                        htTrack[i*stepW+j].Note       = 0;
                        htTrack[i*stepW+j].Instrument = 0;
                        htTrack[i*stepW+j].FX         = 0;
                        htTrack[i*stepW+j].FXParam    = 0;
                        htTrack[i*stepW+j].FXb        = 0;
                        htTrack[i*stepW+j].FXbParam   = 0;
                    }
                    continue;
                }

                for( j=0; j<ht.TrackLength; j++ ){
                    if( buf[bptr+0] == 0x3f ){
                        htTrack[i*stepW+j].Note       = 0;
                        htTrack[i*stepW+j].Instrument = 0;
                        htTrack[i*stepW+j].FX         = 0;
                        htTrack[i*stepW+j].FXParam    = 0;
                        htTrack[i*stepW+j].FXb        = 0;
                        htTrack[i*stepW+j].FXbParam   = 0;
                        bptr++;
                        continue;
                    }
                  
                    htTrack[i*stepW+j].Note       = buf[bptr+0];
                    htTrack[i*stepW+j].Instrument = buf[bptr+1];
                    htTrack[i*stepW+j].FX         = buf[bptr+2]>>4;
                    htTrack[i*stepW+j].FXParam    = buf[bptr+3];
                    htTrack[i*stepW+j].FXb        = buf[bptr+2]&0xf;
                    htTrack[i*stepW+j].FXbParam   = buf[bptr+4];
                    bptr += 5;
                }
            }


            // Instruments
            for( i=1; i<=ht.InstrumentNr; i++ ){
                var htInstr:instrument = ht.Instruments[i];
                
                if( nptr < buflen ){
                    htInstr.Name = tools.strncpy(buf, nptr, 128);
                    nptr += tools.strlen( buf, nptr )+1;
                } else {
                    htInstr.Name = "";
                }

                htInstr.Volume      = buf[bptr+0];
                htInstr.FilterSpeed = ((buf[bptr+1]>>3)&0x1f)|((buf[bptr+12]>>2)&0x20);
                htInstr.WaveLength  = buf[bptr+1]&0x07;

                htInstr.Envelope.aFrames = buf[bptr+2];
                htInstr.Envelope.aVolume = buf[bptr+3];
                htInstr.Envelope.dFrames = buf[bptr+4];
                htInstr.Envelope.dVolume = buf[bptr+5];
                htInstr.Envelope.sFrames = buf[bptr+6];
                htInstr.Envelope.rFrames = buf[bptr+7];
                htInstr.Envelope.rVolume = buf[bptr+8];

                htInstr.FilterLowerLimit     = buf[bptr+12]&0x7f;
                htInstr.VibratoDelay         = buf[bptr+13];
                htInstr.HardCutReleaseFrames = (buf[bptr+14]>>4)&0x07;
                htInstr.HardCutRelease       = buf[bptr+14]&0x80?1:0;
                htInstr.VibratoDepth         = buf[bptr+14]&0x0f;
                htInstr.VibratoSpeed         = buf[bptr+15];
                htInstr.SquareLowerLimit     = buf[bptr+16];
                htInstr.SquareUpperLimit     = buf[bptr+17];
                htInstr.SquareSpeed          = buf[bptr+18];
                htInstr.FilterUpperLimit     = buf[bptr+19]&0x3f;
                htInstr.PList.Speed      = buf[bptr+20];
                htInstr.PList.Length     = buf[bptr+21];

                htInstr.PList.ple_malloc( buf[bptr+21] );

                bptr += 22;
                for( j=0; j<htInstr.PList.Length; j++ ){
                    var htPlsentry:plsentry = htInstr.PList.Entries[j];
                    
                    htPlsentry.FX[0] = buf[bptr+0]&0xf;
                    htPlsentry.FX[1] = (buf[bptr+1]>>3)&0xf;
                    htPlsentry.Waveform = buf[bptr+1]&7;
                    htPlsentry.Fixed = (buf[bptr+2]>>6)&1;
                    htPlsentry.Note  = buf[bptr+2]&0x3f;
                    htPlsentry.FXParam[0] = buf[bptr+3];
                    htPlsentry.FXParam[1] = buf[bptr+4];
                    bptr += 5;
                }
            }

            InitSubsong( ht, 0 );
            buf.clear();
            ht.init_VUMeters();
            return ht;
            
}   

        private function process_stepfx_1( ht:tune, vc:voice, FX:int, FXParam:int ):void{
            switch( FX ){
                case 0x0:  // Position Jump HI
                    if( ((FXParam&0x0f) > 0) && ((FXParam&0x0f) <= 9) ){
                        ht.PosJump = FXParam & 0xf;
                    }
                    break;

                case 0x5:  // Volume Slide + Tone Portamento
                case 0xa:  // Volume Slide
                    vc.VolumeSlideDown = FXParam & 0x0f;
                    vc.VolumeSlideUp   = FXParam >> 4;
                    break;

                case 0x7:  // Panning
                    if( FXParam > 127 ){
                        FXParam -= 256;
                    }
                    vc.Pan          = (FXParam+128);
                    vc.SetPan       = (FXParam+128); // 1.4
                    vc.PanMultLeft  = tables.panning_left[vc.Pan];
                    vc.PanMultRight = tables.panning_right[vc.Pan];
                    break;

                case 0xb: // Position jump
                    ht.PosJump      = ht.PosJump*100 + (FXParam & 0x0f) + (FXParam >> 4)*10;
                    ht.PatternBreak = 1;
                    if( ht.PosJump <= ht.PosNr ){
                        ht.SongEndReached = 1;
                    }
                    break;

                case 0xd: // Pattern break
                    ht.PosJump      = ht.PosNr+1;
                    ht.PosJumpNote  = (FXParam & 0x0f) + (FXParam>>4)*10;
                    ht.PatternBreak = 1;
                    if( ht.PosJumpNote >  ht.TrackLength ){
                        ht.PosJumpNote = 0;
                    }
                    break;

                case 0xe: // Extended commands
                    switch( FXParam >> 4 ){
                        case 0xc: // Note cut
                            if( (FXParam & 0x0f) < ht.Tempo ){
                                vc.NoteCutWait = FXParam & 0x0f;
                                if( vc.NoteCutWait ){
                                    vc.NoteCutOn      = 1;
                                    vc.HardCutRelease = 0;
                                }
                            }
                            break;
                      
                            // 1.6: 0xd case removed
                    }
                    break;

                case 0xf: // Speed
                    ht.Tempo = FXParam;
                    if( FXParam == 0 ){
                        ht.SongEndReached = 1;
                    }
                    break;
            }  
        }

        private function process_stepfx_2( ht:tune, vc:voice, FX:int, FXParam:int, Note:int ):int{
            switch( FX ){
                case 0x9: // Set squarewave offset
                    vc.SquarePos    = FXParam >> (5 - vc.WaveLength);
                    vc.PlantSquare  = 1;
                    vc.IgnoreSquare = 1;
                    break;

                case 0x3: // Tone portamento + volume slide
                    if( FXParam != 0 ){
                        vc.PeriodSlideSpeed = FXParam;
                    }
                case 0x5: // Tone portamento
                    if( Note ){
                        var mew:int, diff:int;

                        mew   = tables.period_tab[Note];
                        diff  = tables.period_tab[vc.TrackPeriod];
                        diff -= mew;
                        mew   = diff + vc.PeriodSlidePeriod;
            
                        if( mew ){
                            vc.PeriodSlideLimit = -diff;
                        }
                    }
                    vc.PeriodSlideOn        = 1;
                    vc.PeriodSlideWithLimit = 1;
                    Note = 0;
                    break;      
            }
            return Note;
        }

        private function process_stepfx_3( ht:tune, vc:voice, FX:int, FXParam:int ):void{
            var i:int;
          
            switch( FX ){
                case 0x01: // Portamento up (period slide down)
                    vc.PeriodSlideSpeed     = -FXParam;
                    vc.PeriodSlideOn        = 1;
                    vc.PeriodSlideWithLimit = 0;
                    break;
                case 0x02: // Portamento down
                    vc.PeriodSlideSpeed     = FXParam;
                    vc.PeriodSlideOn        = 1;
                    vc.PeriodSlideWithLimit = 0;
                    break;
                case 0x04: // Filter override
                    if( ( FXParam == 0 ) || ( FXParam == 0x40 ) ){
                        break;
                    }
                    if( FXParam < 0x40 ){
                        vc.IgnoreFilter = FXParam;
                        break;
                    }
                    if( FXParam > 0x7f ){
                        break;
                    }
                    vc.FilterPos = FXParam - 0x40;
                    break;
                case 0x0c: // Volume
                    FXParam &= 0xff;
                    if( FXParam <= 0x40 ){
                        vc.NoteMaxVolume = FXParam;
                        break;
                    }
              
                    if( (FXParam -= 0x50) < 0 ){
                        break;  // 1.6
                    }

                    if( FXParam <= 0x40 ){
                        for( i=0; i<ht.Channels; i++ ){
                            ht.Voices[i].TrackMasterVolume = FXParam;
                        }
                        break;
                    }
              
                    if( (FXParam -= 0xa0-0x50) < 0 ){
                        break; // 1.6
                    }

                    if( FXParam <= 0x40 ){
                        vc.TrackMasterVolume = FXParam;
                    }
                    break;

                case 0xe: // Extended commands;
                    switch( FXParam >> 4 ){
                        case 0x1: // Fineslide up
                            vc.PeriodSlidePeriod -= (FXParam & 0x0f); // 1.8
                            vc.PlantPeriod = 1;
                            break;
                
                        case 0x2: // Fineslide down
                            vc.PeriodSlidePeriod += (FXParam & 0x0f); // 1.8
                            vc.PlantPeriod = 1;
                            break;
                
                        case 0x4: // Vibrato control
                            vc.VibratoDepth = FXParam & 0x0f;
                            break;
                
                        case 0x0a: // Fine volume up
                            vc.NoteMaxVolume += FXParam & 0x0f;
                  
                            if( vc.NoteMaxVolume > 0x40 ){
                                vc.NoteMaxVolume = 0x40;
                            }
                            break;
                
                        case 0x0b: // Fine volume down
                            vc.NoteMaxVolume -= FXParam & 0x0f;
                  
                            if( vc.NoteMaxVolume < 0 ){
                                vc.NoteMaxVolume = 0;
                            }
                            break;
                
                            case 0x0f: // Misc flags (1.5)
                                if( ht.Version < 1 ){
                                    break;
                                }
                                switch( FXParam & 0xf ){
                                    case 1:
                                        vc.OverrideTranspose = vc.Transpose;
                                        break;
                                }
                                break;
                    } 
                    break;
            }
        }

        private function process_step( ht:tune, vc:voice ):void{
            var Note:int, Instr:int, donenotedel:int; //int32
            var Step:step;                        //struct hvl_step *Step;
            var t:int;
          
            if( vc.TrackOn == 0 ){
                return;
            }
          
            vc.VolumeSlideUp = vc.VolumeSlideDown = 0;
          
            Step = ht.Tracks[ ht.Positions[ ht.PosNr ].Track[ vc.VoiceNum ]*stepW + ht.NoteNr ];
          
            Note    = Step.Note;
            Instr   = Step.Instrument;
          
            // --------- 1.6: from here --------------

            donenotedel = 0;

            // Do notedelay here
            if( ((Step.FX&0xf)==0xe) && ((Step.FXParam&0xf0)==0xd0) ){
                if( vc.NoteDelayOn ){
                    vc.NoteDelayOn = 0;
                    donenotedel = 1;
                } else {
                    if( (Step.FXParam&0x0f) < ht.Tempo ){
                        vc.NoteDelayWait = Step.FXParam & 0x0f;
                        if( vc.NoteDelayWait ){
                            vc.NoteDelayOn = 1;
                            return;
                        }
                    }
                }
            }

            if( (donenotedel==0) && ((Step.FXb&0xf)==0xe) && ((Step.FXbParam&0xf0)==0xd0) ){
                if( vc.NoteDelayOn ){
                    vc.NoteDelayOn = 0;
                } else {
                    if( (Step.FXbParam&0x0f) < ht.Tempo ){
                        vc.NoteDelayWait = Step.FXbParam & 0x0f;
                        if( vc.NoteDelayWait ){
                            vc.NoteDelayOn = 1;
                            return;
                        }
                    }
                }
            }

            // --------- 1.6: to here --------------

            if( Note ){
                vc.OverrideTranspose = 1000; // 1.5
            }

            process_stepfx_1( ht, vc, Step.FX&0xf,  Step.FXParam );  
            process_stepfx_1( ht, vc, Step.FXb&0xf, Step.FXbParam );
          
            if( ( Instr ) && ( Instr <=  ht.InstrumentNr ) ){
                var Ins:instrument;
                var SquareLower:int, SquareUpper:int, d6:int, d3:int, d4:int; //int16
            
                /* 1.4: Reset panning to last set position */
                vc.Pan          = vc.SetPan;
                vc.PanMultLeft  = tables.panning_left[vc.Pan];
                vc.PanMultRight = tables.panning_right[vc.Pan];

                vc.PeriodSlideSpeed =     0;
                vc.PeriodSlidePeriod =    0;
                vc.PeriodSlideLimit =     0;

                vc.PerfSubVolume    = 0x40;
                vc.ADSRVolume       = 0;
                vc.Instrument       = Ins = ht.Instruments[Instr];
                vc.SamplePos        = 0;
                
                var vcEnv:envelope  = vc.ADSR;
                var insEnv:envelope = Ins.Envelope;
                vcEnv.aFrames     = insEnv.aFrames;
                vcEnv.aVolume     = vcEnv.aFrames ? insEnv.aVolume*256/vcEnv.aFrames : insEnv.aVolume * 256; // XXX
                vcEnv.dFrames     = insEnv.dFrames;
                vcEnv.dVolume     = vcEnv.dFrames ? (insEnv.dVolume-insEnv.aVolume)*256/vcEnv.dFrames : insEnv.dVolume * 256; // XXX
                vcEnv.sFrames     = insEnv.sFrames;
                vcEnv.rFrames     = insEnv.rFrames;
                vcEnv.rVolume     = vcEnv.rFrames ? (insEnv.rVolume-insEnv.dVolume)*256/vcEnv.rFrames : insEnv.rVolume * 256; // XXX
    
                
                vc.WaveLength       = Ins.WaveLength;
                vc.NoteMaxVolume    = Ins.Volume;
            
                vc.VibratoCurrent   = 0;
                vc.VibratoDelay     = Ins.VibratoDelay;
                vc.VibratoDepth     = Ins.VibratoDepth;
                vc.VibratoSpeed     = Ins.VibratoSpeed;
                vc.VibratoPeriod    = 0;
            
                vc.HardCutRelease   = Ins.HardCutRelease;
                vc.HardCut          = Ins.HardCutReleaseFrames;
            
                vc.IgnoreSquare = vc.SquareSlidingIn = 0;
                vc.SquareWait   = vc.SquareOn        = 0;
            
                SquareLower = Ins.SquareLowerLimit >> (5 - vc.WaveLength);
                SquareUpper = Ins.SquareUpperLimit >> (5 - vc.WaveLength);
            
                if( SquareUpper < SquareLower ){
                    t = SquareUpper;            //int16
                    SquareUpper = SquareLower;
                    SquareLower = t;
                }
            
                vc.SquareUpperLimit = SquareUpper;
                vc.SquareLowerLimit = SquareLower;
            
                vc.IgnoreFilter     = 0;
                vc.FilterWait       = 0;
                vc.FilterOn         = 0;
                vc.FilterSlidingIn  = 0;

                d6 = Ins.FilterSpeed;
                d3 = Ins.FilterLowerLimit;
                d4 = Ins.FilterUpperLimit;
            
                if( d3 & 0x80 ) d6 |= 0x20;
                if( d4 & 0x80 ) d6 |= 0x40;
            
                vc.FilterSpeed = d6;
                d3 &= ~0x80;
                d4 &= ~0x80;
            
                if( d3 > d4 ){
                    t = d3;                     //int16
                    d3 = d4;
                    d4 = t;
                }
            
                vc.FilterUpperLimit = d4;
                vc.FilterLowerLimit = d3;
                vc.FilterPos        = 32;
            
                vc.PerfWait    = 0;
                vc.PerfCurrent = 0;
                vc.PerfSpeed = Ins.PList.Speed;
                vc.PerfList  = vc.Instrument.PList;
                
                //WARNING: "unreachable" value
                //vc.vc_RingMixSource   = null;   // No ring modulation
                vc.RingMixSource   = null;   // No ring modulation
                vc.RingSamplePos   = 0;
                vc.RingPlantPeriod = 0;
                vc.RingNewWaveform = 0;
            }
          
            vc.PeriodSlideOn = 0;
          
            Note = process_stepfx_2( ht, vc, Step.FX&0xf,  Step.FXParam,  Note );  
            Note = process_stepfx_2( ht, vc, Step.FXb&0xf, Step.FXbParam, Note );

            if( Note ){
                vc.TrackPeriod = Note;
                vc.PlantPeriod = 1;
            }
          
            process_stepfx_3( ht, vc, Step.FX&0xf,  Step.FXParam );  
            process_stepfx_3( ht, vc, Step.FXb&0xf, Step.FXbParam );  
        }

        private function plist_command_parse( ht:tune, vc:voice, FX:int, FXParam:int ):void{
            switch( FX ){
                case 0:
                    if( ( FXParam > 0 ) && ( FXParam < 0x40 ) ){
                        if( vc.IgnoreFilter ){
                            vc.FilterPos    = vc.IgnoreFilter;
                            vc.IgnoreFilter = 0;
                        } else {
                            vc.FilterPos    = FXParam;
                        }
                        vc.NewWaveform = 1;
                    }
                    break;

                case 1:
                    vc.PeriodPerfSlideSpeed = FXParam;
                    vc.PeriodPerfSlideOn    = 1;
                    break;

                case 2:
                    vc.PeriodPerfSlideSpeed = -FXParam;
                    vc.PeriodPerfSlideOn    = 1;
                    break;
            
                case 3:
                    if( vc.IgnoreSquare == 0 ){
                        vc.SquarePos = FXParam >> (5-vc.WaveLength);
                    } else {
                        vc.IgnoreSquare = 0;
                    }
                    break;
            
                case 4:
                    if( FXParam == 0 ){
                        vc.SquareInit = (vc.SquareOn ^= 1);
                        vc.SquareSign = 1;
                    } else {

                        if( FXParam & 0x0f ){
                            vc.SquareInit = (vc.SquareOn ^= 1);
                            vc.SquareSign = 1;
                            if(( FXParam & 0x0f ) == 0x0f ){
                                vc.SquareSign = -1;
                            }
                        }
                
                        if( FXParam & 0xf0 ){
                            vc.FilterInit = (vc.FilterOn ^= 1);
                            vc.FilterSign = 1;
                            if(( FXParam & 0xf0 ) == 0xf0 ){
                                vc.FilterSign = -1;
                            }
                        }
                    }
                    break;
            
                case 5:
                    vc.PerfCurrent = FXParam;
                    break;
            
                case 7:
                    // Ring modulate with triangle
                    if(( FXParam >= 1 ) && ( FXParam <= 0x3C )){
                        vc.RingBasePeriod = FXParam;
                        vc.RingFixedPeriod = 1;
                    } else if(( FXParam >= 0x81 ) && ( FXParam <= 0xBC )) {
                        vc.RingBasePeriod = FXParam-0x80;
                        vc.RingFixedPeriod = 0;
                    } else {
                        vc.RingBasePeriod = 0;
                        vc.RingFixedPeriod = 0;
                        vc.RingNewWaveform = 0;
                        //WARNING: "unreachable" value
                        vc.RingAudioSource = uint.MAX_VALUE; // turn it off
                        vc.RingMixSource   = null;
                        break;
                    }    
                    vc.RingWaveform    = 0;
                    vc.RingNewWaveform = 1;
                    vc.RingPlantPeriod = 1;
                    break;
            
                case 8:  // Ring modulate with sawtooth
                    if(( FXParam >= 1 ) && ( FXParam <= 0x3C )){
                        vc.RingBasePeriod = FXParam;
                        vc.RingFixedPeriod = 1;
                    } else if(( FXParam >= 0x81 ) && ( FXParam <= 0xBC )) {
                        vc.RingBasePeriod = FXParam-0x80;
                        vc.RingFixedPeriod = 0;
                    } else {
                        vc.RingBasePeriod = 0;
                        vc.RingFixedPeriod = 0;
                        vc.RingNewWaveform = 0;
                        //WARNING: "unreachable" value
                        vc.RingAudioSource = uint.MAX_VALUE; // turn it off
                        vc.RingMixSource   = null;
                        break;
                    }

                    vc.RingWaveform    = 1;
                    vc.RingNewWaveform = 1;
                    vc.RingPlantPeriod = 1;
                    break;

                /* New in HivelyTracker 1.4 */    
                case 9:    
                    if( FXParam > 127 ){
                        FXParam -= 256;
                    }
                    vc.Pan          = (FXParam+128);
                    vc.PanMultLeft  = tables.panning_left[vc.Pan];
                    vc.PanMultRight = tables.panning_right[vc.Pan];
                    break;

                case 12:
                    if( FXParam <= 0x40 ){
                        vc.NoteMaxVolume = FXParam;
                        break;
                    }
              
                    if( (FXParam -= 0x50) < 0 ) break;

                    if( FXParam <= 0x40 ){
                        vc.PerfSubVolume = FXParam;
                        break;
                    }
              
                    if( (FXParam -= 0xa0-0x50) < 0 ) break;
              
                    if( FXParam <= 0x40 ){
                        vc.TrackMasterVolume = FXParam;
                    }
                    break;
            
                case 15:
                    vc.PerfSpeed = vc.PerfWait = FXParam;
                    break;
            } 
        }

        private function process_frame( ht:tune, vc:voice ):void {
            var d0:int, d1:int, d2:int, d3:int;     //int32
            var waves:Vector.<int> = tables.waves;
            
            const Offsets:Vector.<uint> = Vector.<uint>([0x00, 0x04, 0x04+0x08, 0x04+0x08+0x10, 0x04+0x08+0x10+0x20, 0x04+0x08+0x10+0x20+0x40]);

            if( vc.TrackOn == 0 ){
                return;
            }

            if( vc.NoteDelayOn ){
                if( vc.NoteDelayWait <= 0 ){
                    process_step( ht, vc );
                } else {
                    vc.NoteDelayWait--;
                }
            }
          
            if( vc.HardCut ){
                var nextinst:int;     //int32
            
                if( ht.NoteNr+1 < ht.TrackLength ){
                    nextinst = ht.Tracks[vc.Track*stepW + ht.NoteNr+1].Instrument;
                } else {
                    nextinst = ht.Tracks[vc.NextTrack*stepW + 0].Instrument;
                }
            
                if( nextinst ){
                  
                    d1 = ht.Tempo - vc.HardCut;
                  
                    if( d1 < 0 ) d1 = 0;
                
                    if( !vc.NoteCutOn ){
                        vc.NoteCutOn       = 1;
                        vc.NoteCutWait     = d1;
                        vc.HardCutReleaseF = -(d1-ht.Tempo);
                    } else {
                        vc.HardCut = 0;
                    }
                }
            }
            
            if( vc.NoteCutOn ){
                if( vc.NoteCutWait <= 0 ){
                    vc.NoteCutOn = 0;
                
                    if( vc.HardCutRelease ){
                        vc.ADSR.rVolume = -(vc.ADSRVolume - (vc.Instrument.Envelope.rVolume << 8)) / vc.HardCutReleaseF;
                        vc.ADSR.rFrames = vc.HardCutReleaseF;
                        vc.ADSR.aFrames = vc.ADSR.dFrames = vc.ADSR.sFrames = 0;
                    } else {
                        vc.NoteMaxVolume = 0;
                    }
                } else {
                    vc.NoteCutWait--;
                }
            }
            
            // ADSR envelope
            if( vc.ADSR.aFrames ){
                vc.ADSRVolume += vc.ADSR.aVolume;
              
                if( --vc.ADSR.aFrames <= 0 ){
                    vc.ADSRVolume = vc.Instrument.Envelope.aVolume << 8;
                }

            } else if( vc.ADSR.dFrames ) {
            
                vc.ADSRVolume += vc.ADSR.dVolume;
              
                if( --vc.ADSR.dFrames <= 0 ){
                    vc.ADSRVolume = vc.Instrument.Envelope.dVolume << 8;
                }
            
            } else if( vc.ADSR.sFrames ) {
            
                vc.ADSR.sFrames--;
            
            } else if( vc.ADSR.rFrames ) {
            
                vc.ADSRVolume += vc.ADSR.rVolume;
            
                if( --vc.ADSR.rFrames <= 0 ){
                    vc.ADSRVolume = vc.Instrument.Envelope.rVolume << 8;
                }
            }

            // VolumeSlide
            vc.NoteMaxVolume = vc.NoteMaxVolume + vc.VolumeSlideUp - vc.VolumeSlideDown;

            if( vc.NoteMaxVolume < 0 ){
                vc.NoteMaxVolume = 0;
            } else if ( vc.NoteMaxVolume > 0x40 ){
                vc.NoteMaxVolume = 0x40;
            }

            // Portamento
            if( vc.PeriodSlideOn ){
                if( vc.PeriodSlideWithLimit ){
                  
                    d0 = vc.PeriodSlidePeriod - vc.PeriodSlideLimit;
                    d2 = vc.PeriodSlideSpeed;
              
                    if( d0 > 0 ) d2 = -d2;
              
                    if( d0 ){
                 
                        d3 = (d0 + d2) ^ d0;
                
                        if( d3 >= 0 ){
                            d0 = vc.PeriodSlidePeriod + d2;
                        } else {
                            d0 = vc.PeriodSlideLimit;
                        }
                
                        vc.PeriodSlidePeriod = d0;
                        vc.PlantPeriod = 1;
                    }
                } else {
                    vc.PeriodSlidePeriod += vc.PeriodSlideSpeed;
                    vc.PlantPeriod = 1;
                }
            }
          
            // Vibrato
            if( vc.VibratoDepth ){
                if( vc.VibratoDelay <= 0 ){
                    vc.VibratoPeriod = (tables.vib_tab[vc.VibratoCurrent] * vc.VibratoDepth) >> 7;
                    vc.PlantPeriod = 1;
                    vc.VibratoCurrent = (vc.VibratoCurrent + vc.VibratoSpeed) & 0x3f;
                } else {
                    vc.VibratoDelay--;
                }
            }
          
            // PList
            if( vc.PerfList ){
                if( vc.Instrument && vc.PerfCurrent < vc.Instrument.PList.Length ){
                    if( --vc.PerfWait <= 0 ){
                        var i:uint;       //uint32
                        var cur:int;      //int32
                
                        cur = vc.PerfCurrent++;
                        vc.PerfWait = vc.PerfSpeed;
                
                        if( vc.PerfList.Entries[cur].Waveform ){
                            vc.Waveform             = vc.PerfList.Entries[cur].Waveform-1;
                            vc.NewWaveform          = 1;
                            vc.PeriodPerfSlideSpeed = vc.PeriodPerfSlidePeriod = 0;
                        }
                
                        // Holdwave
                        vc.PeriodPerfSlideOn = 0;
                
                        for( i=0; i<2; i++ ){
                            plist_command_parse( ht, vc, vc.PerfList.Entries[cur].FX[i]&0xff, vc.PerfList.Entries[cur].FXParam[i]&0xff );
                        }
                
                        // GetNote
                        if( vc.PerfList.Entries[cur].Note ){
                            vc.InstrPeriod = vc.PerfList.Entries[cur].Note;
                            vc.PlantPeriod = 1;
                            vc.FixedNote   = vc.PerfList.Entries[cur].Fixed;
                        }
                    }
                } else {
                    if( vc.PerfWait ){
                        vc.PerfWait--;
                    } else {
                        vc.PeriodPerfSlideSpeed = 0;
                    }
                }
            }
          
            // PerfPortamento
            if( vc.PeriodPerfSlideOn ){
                vc.PeriodPerfSlidePeriod -= vc.PeriodPerfSlideSpeed;
            
                if( vc.PeriodPerfSlidePeriod ){
                    vc.PlantPeriod = 1;
                }
            }
          
            if( vc.Waveform == 3-1 && vc.SquareOn ){
                if( --vc.SquareWait <= 0 ){
              
                    d1 = vc.SquareLowerLimit;
                    d2 = vc.SquareUpperLimit;
                    d3 = vc.SquarePos;
              
                    if( vc.SquareInit ){
                        vc.SquareInit = 0;
                
                        if( d3 <= d1 ){
                            vc.SquareSlidingIn = 1;
                            vc.SquareSign = 1;
                        } else if( d3 >= d2 ) {
                            vc.SquareSlidingIn = 1;
                            vc.SquareSign = -1;
                        }
                    }
              
                    // NoSquareInit
                    if( d1 == d3 || d2 == d3 ){
                        if( vc.SquareSlidingIn ){
                            vc.SquareSlidingIn = 0;
                        } else {
                            vc.SquareSign = -vc.SquareSign;
                        }
                    }
              
                    d3 += vc.SquareSign;
                    vc.SquarePos   = d3;
                    vc.PlantSquare = 1;
                    vc.SquareWait  = vc.Instrument.SquareSpeed;
                }
            }
          
            if( vc.FilterOn && --vc.FilterWait <= 0 ){ 
                var FMax:uint;            //uint32
            
                d1 = vc.FilterLowerLimit;
                d2 = vc.FilterUpperLimit;
                d3 = vc.FilterPos;
            
                if( vc.FilterInit ){
                    vc.FilterInit = 0;
                    if( d3 <= d1 ){
                        vc.FilterSlidingIn = 1;
                        vc.FilterSign      = 1;
                    } else if( d3 >= d2 ) {
                        vc.FilterSlidingIn = 1;
                        vc.FilterSign      = -1;
                    }
                }
            
                // NoFilterInit
                FMax = (vc.FilterSpeed < 3) ? (5-vc.FilterSpeed) : 1;

                for( i=0; i<FMax; i++ ){
                    if( ( d1 == d3 ) || ( d2 == d3 ) ){
                        if( vc.FilterSlidingIn ){
                            vc.FilterSlidingIn = 0;
                        } else {
                            vc.FilterSign = -vc.FilterSign;
                        }
                    }
                    d3 += vc.FilterSign;
                }
            
                if( d3 < 1 )  d3 = 1;
                if( d3 > 63 ) d3 = 63;
                vc.FilterPos   = d3;
                vc.NewWaveform = 1;
                vc.FilterWait  = vc.FilterSpeed - 3;
            
                if( vc.FilterWait < 1 ){
                    vc.FilterWait = 1;
                }
            }

            if( vc.Waveform == 3-1 || vc.PlantSquare ){
                // CalcSquare
                var Delta:int;           //int32
                var SquarePtr:uint;      //*int8
                var X:int;               //int32
            
                SquarePtr = tables.WO_SQUARES+(vc.FilterPos-0x20)*(0xfc+0xfc+0x80*0x1f+0x80+0x280*3);
                X = vc.SquarePos << (5 - vc.WaveLength);
            
                if( X > 0x20 ){
                    X = 0x40 - X;
                    vc.SquareReverse = 1;
                }
            
                // OkDownSquare
                if( X > 0 ){
                    SquarePtr += (X-1) << 7;
                }
            
                Delta = 32 >> vc.WaveLength;
                
                ht.WaveformTab_i2 = vc.SquareTempBuffer;
                ht.WaveformTab[2] = 0;
                
                for( i=0; i<(1<<vc.WaveLength)*4; i++ ){
                    vc.SquareTempBuffer[i] = waves[SquarePtr];
                    SquarePtr += Delta;
                }
                
                vc.NewWaveform = 1;
                vc.Waveform    = 3-1;
                vc.PlantSquare = 0;
            }
          
            if( vc.Waveform == 4-1 ){
                vc.NewWaveform = 1;
            }
          
            if( vc.RingNewWaveform ){
                var rasrc:uint;        //*int8
            
                if( vc.RingWaveform > 1 ){
                    vc.RingWaveform = 1;
                }
                rasrc = ht.WaveformTab[vc.RingWaveform];
                rasrc += Offsets[vc.WaveLength];
            
                vc.RingAudioSource = rasrc;
            }    
                
          
            if( vc.NewWaveform ){
                var AudioSource:uint;       //*int8

                AudioSource = ht.WaveformTab[vc.Waveform];
                
                if( vc.Waveform != 3-1 ){
                    AudioSource += (vc.FilterPos-0x20)*(0xfc+0xfc+0x80*0x1f+0x80+0x280*3);
                }

                if( vc.Waveform < 3-1){
                    // GetWLWaveformlor2
                    AudioSource += Offsets[vc.WaveLength];
                }

                if( vc.Waveform == 4-1 ){
                    // AddRandomMoving
                    AudioSource += ( vc.WNRandom & (2*0x280-1) ) & ~1;
                    // GoOnRandom
                    vc.WNRandom += 2239384;
                    vc.WNRandom  = ((((vc.WNRandom >> 8) | (vc.WNRandom << 24)) + 782323) ^ 75) - 6735;
                    //vc.WNRandom  = ((tools.bitRotate(8, vc.WNRandom, 32) + 782323) ^ 75) - 6735;
                    //White noise seems fixed by the above.
                    //I thought bit rotation was broken, damnit.
                }

                vc.AudioSource = AudioSource;
            }
          
            // Ring modulation period calculation
            if( vc.RingAudioSource != uint.MAX_VALUE ){
                vc.RingAudioPeriod = vc.RingBasePeriod;
          
                if( !(vc.RingFixedPeriod) ){
                    if( vc.OverrideTranspose != 1000 ){  // 1.5
                        vc.RingAudioPeriod += vc.OverrideTranspose + vc.TrackPeriod - 1;
                    } else {
                        vc.RingAudioPeriod += vc.Transpose + vc.TrackPeriod - 1;
                    }
                }
          
                if( vc.RingAudioPeriod > 5*12 ){
                    vc.RingAudioPeriod = 5*12;
                }
          
                if( vc.RingAudioPeriod < 0 ){
                    vc.RingAudioPeriod = 0;
                }
          
                vc.RingAudioPeriod = tables.period_tab[vc.RingAudioPeriod];

                if( !(vc.RingFixedPeriod) ){
                    vc.RingAudioPeriod += vc.PeriodSlidePeriod;
                }

                vc.RingAudioPeriod += vc.PeriodPerfSlidePeriod + vc.VibratoPeriod;

                if( vc.RingAudioPeriod > 0x0d60 ){
                    vc.RingAudioPeriod = 0x0d60;
                }

                if( vc.RingAudioPeriod < 0x0071 ){
                    vc.RingAudioPeriod = 0x0071;
                }
            }
          
            // Normal period calculation
            vc.AudioPeriod = vc.InstrPeriod;
          
            if( !(vc.FixedNote) ){
                if( vc.OverrideTranspose != 1000 ){ // 1.5
                    vc.AudioPeriod += vc.OverrideTranspose + vc.TrackPeriod - 1;
                } else {
                    vc.AudioPeriod += vc.Transpose + vc.TrackPeriod - 1;
                }
            }
            
            if( vc.AudioPeriod > 5*12 ){
                vc.AudioPeriod = 5*12;
            }
          
            if( vc.AudioPeriod < 0 ){
                vc.AudioPeriod = 0;
            }
          
            vc.AudioPeriod = tables.period_tab[vc.AudioPeriod];
          
            if( !(vc.FixedNote) ){
                vc.AudioPeriod += vc.PeriodSlidePeriod;
            }

            vc.AudioPeriod += vc.PeriodPerfSlidePeriod + vc.VibratoPeriod;    

            if( vc.AudioPeriod > 0x0d60 ){
                vc.AudioPeriod = 0x0d60;
            }

            if( vc.AudioPeriod < 0x0071 ){
                vc.AudioPeriod = 0x0071;
            }
          
            vc.AudioVolume = (((((((vc.ADSRVolume >> 8) * vc.NoteMaxVolume) >> 6) * vc.PerfSubVolume) >> 6) * vc.TrackMasterVolume) >> 6);
        }

        private function set_audio( vc:voice, freqf:Number ):void{
            if( vc.TrackOn == 0 ){
                vc.VoiceVolume = 0;
                return;
            }
  
            vc.VoiceVolume = vc.AudioVolume;
  
            if( vc.PlantPeriod ){
                var freq2:Number;   //float64
                var delta:uint;     //uint32
    
                vc.PlantPeriod = 0;
                vc.VoicePeriod = vc.AudioPeriod;
    
                freq2 = cons.AMIGA_PAULA_PAL_CLK * 65536.0 / vc.AudioPeriod; //Period2Freq inline
                delta = uint(freq2 / freqf);

                if( delta > (0x280<<16) ) delta -= (0x280<<16);
                if( delta == 0 ) delta = 1;
                vc.Delta = delta;
            }
  
            if( vc.NewWaveform ){
                var src:uint;        //*int8
                var ref:Vector.<int>;
                if (vc.Waveform == 2) {
                    ref = vc.SquareTempBuffer;
                }else {
                    ref = tables.waves;
                }
                src = vc.AudioSource;
                
                var voiceBuf:Vector.<int> = vc.VoiceBuffer;
                if( vc.Waveform == 4-1 ){
                    //memcpy( &voice->vc_VoiceBuffer[0], src, 0x280 );
                    for ( var ii:uint = 0; ii < 0x280; ii++ ) {
                         voiceBuf[ii] = ref[src + ii];
                    }
                } else {
                    var i:uint, WaveLoops:uint;        //uint32

                    WaveLoops = (1 << (5 - vc.WaveLength)) * 5;

                    for( i=0; i<WaveLoops; i++ ){
                        //memcpy( &voice->vc_VoiceBuffer[i*4*(1<<voice->vc_WaveLength)], src, 4*(1<<voice->vc_WaveLength) );
                        for( var j:uint=0; j<4*(1<<vc.WaveLength); j++ ){
                            voiceBuf[i*4*(1<<vc.WaveLength)+j] = ref[src+j];
                        }
                    }
                }

                voiceBuf[0x280] = voiceBuf[0];
                vc.MixSource    = voiceBuf;
            }

            /* Ring Modulation */
            if( vc.RingPlantPeriod ){
    
                vc.RingPlantPeriod = 0;
                freq2 = cons.AMIGA_PAULA_PAL_CLK * 65536.0 / vc.RingAudioPeriod; //Period2Freq inline
                delta = uint(freq2 / freqf);
    
                if( delta > (0x280<<16) ) delta -= (0x280<<16);
                if( delta == 0 ) delta = 1;
                vc.RingDelta = delta;
            }
  
            if( vc.RingNewWaveform ){
                if (vc.Waveform == 2) {
                    ref = vc.SquareTempBuffer;
                }else {
                    ref = tables.waves;
                }
                
                src = vc.RingAudioSource;

                WaveLoops = (1 << (5 - vc.WaveLength)) * 5;
                
                var ringBuf:Vector.<int> = vc.RingVoiceBuffer;
                for( i=0; i<WaveLoops; i++ ){
                    //memcpy( &voice->vc_RingVoiceBuffer[i*4*(1<<voice->vc_WaveLength)], src, 4*(1<<voice->vc_WaveLength) );
                    
                    for( j=0; j<4*(1<<vc.WaveLength);j++ ){
                        ringBuf[i*4*(1<<vc.WaveLength)+j] = ref[src+j];
                    }
                }

                ringBuf[0x280]   = ringBuf[0];
                vc.RingMixSource = ringBuf;
            }
        }

        internal function play_irq( ht:tune, for_real:Boolean ):void{
            var i:uint;         //uint32
            var htVoice:voice;
            var htVoices:Vector.<voice> = ht.Voices;
            
            if( ht.Tempo > 0 && ht.StepWaitFrames <= 0 ){
                if( ht.GetNewPosition ){
                    var nextpos:int = (ht.PosNr+1==ht.PositionNr)?0:(ht.PosNr+1);     //int32
                    var htPos:position = ht.Positions[ht.PosNr];
                    var htNPos:position = ht.Positions[nextpos]
                    
                    for( i=0; i<ht.Channels; i++ ){
                        htVoice = ht.Voices[i];
                        
                        htVoice.Track         = htPos.Track[i];
                        htVoice.Transpose     = htPos.Transpose[i];
                        htVoice.NextTrack     = htNPos.Track[i];
                        htVoice.NextTranspose = htNPos.Transpose[i];
                    }
                    ht.GetNewPosition = 0;
                }
    
                for( i=0; i<ht.Channels; i++ ){
                    process_step( ht, htVoices[i] );
                }
    
                ht.StepWaitFrames = ht.Tempo;
            }
            //we skip this for performance resons when actual playback is not needed
            if (for_real) {
                for( i=0; i<ht.Channels; i++ ){
                    process_frame( ht, htVoices[i] );
                }
            }
            
            ht.PlayingTime++;
            if( ht.Tempo > 0 && --ht.StepWaitFrames <= 0 ){
                if( !ht.PatternBreak ){
                    ht.NoteNr++;
                    if( ht.NoteNr >= ht.TrackLength ){
                        ht.PosJump      = ht.PosNr+1;
                        ht.PosJumpNote  = 0;
                        ht.PatternBreak = 1;
                    }
                }
    
                if( ht.PatternBreak ){
                    ht.PatternBreak = 0;
                    ht.PosNr        = ht.PosJump;
                    ht.NoteNr       = ht.PosJumpNote;
                    if( ht.PosNr == ht.PositionNr ){
                        ht.SongEndReached = 1;
                        ht.PosNr          = ht.Restart;
                    }
                    ht.PosJumpNote  = 0;
                    ht.PosJump      = 0;

                    ht.GetNewPosition = 1;
                }
            }

            for( i=0; i<ht.Channels; i++ ){
                set_audio( htVoices[i], ht.Frequency );
            }
        }

	

    private function mixchunk(ht:tune, samples:uint, buf12:ByteArray):void{
        var cnt:uint, absj:int;
        var a:int, b:int, j:int;
        var i:uint, chans:uint, loops:uint;
        var htVoice:voice;
     
        chans = ht.Channels;
     
        do{
            loops = samples;
            for (i = 0; i < chans; ++i){
                htVoice = ht.Voices[i];
                
                if (htVoice.SamplePos >= (0x280 << 16))
                    htVoice.SamplePos -= (0x280 << 16);
                   
                cnt = (((0x280 << 16) - (htVoice.SamplePos - 1))
                      / htVoice.Delta) + 1;            
                if (cnt < loops) loops = cnt;
     
                if (htVoice.RingMixSource){
                    if (htVoice.RingSamplePos >= (0x280 << 16))
                        htVoice.RingSamplePos -= (0x280 << 16);
                       
                    cnt = (((0x280 << 16) - (htVoice.RingSamplePos - 1))
                          / htVoice.RingDelta) + 1;                    
                    if (cnt < loops) loops = cnt;
                }
            }
     
            samples -= loops;
           
            do{
                a=0;
                b=0;
               
                for (i = 0; i < chans; ++i){
                    htVoice = ht.Voices[i];
                    
                    if (htVoice.RingMixSource){
                        j = ((htVoice.MixSource[htVoice.SamplePos >> 16]
                            * htVoice.RingMixSource[htVoice.RingSamplePos >> 16]) >> 7)
                            * htVoice.VoiceVolume;
                           
                        htVoice.RingSamplePos += htVoice.RingDelta;
                    }else{
                        j = htVoice.MixSource[htVoice.SamplePos >> 16]
                            * htVoice.VoiceVolume;
                    }
                    
                    //absj=Math.abs(j);
                    absj=((j^(j>>31))-(j>>31))/190;
                    //htVoice.VUMeter = absj;
                    if (absj > ht.VUMeters[i]){
                        ht.VUMeters[i] = absj;
                    }
                    
                    a += ((j * htVoice.PanMultLeft)  >> 7);
                    b += ((j * htVoice.PanMultRight) >> 7);
                   
                    htVoice.SamplePos += htVoice.Delta;
                }
     
                a = (a * ht.mixgain) >> 8;
                b = (b * ht.mixgain) >> 8;
                
                buf12.writeFloat( a&0x80000000 ? a/32768 : a/32767 );
                buf12.writeFloat( b&0x80000000 ? b/32768 : b/32767 );
     
                loops--;
            }while (loops > 0);
        }while (samples > 0);
    }


        
        
        internal function DecodeFrame( ht:tune, buf12:ByteArray ):void{
            var samples:uint, loops:uint;       //uint32
  
            samples = ht.Frequency/50/ht.SpeedMultiplier;
            loops   = ht.SpeedMultiplier;
  
            do{
                play_irq( ht, true );
                mixchunk( ht, samples, buf12 );
                loops--;
            } while( loops );
        }
    }
}
        
        
