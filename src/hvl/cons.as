package hvl {
    public class cons{
        internal static const stereopan_left:Vector.<int> = Vector.<int>([ 128,  96,  64,  32,   0 ]);
        internal static const stereopan_right:Vector.<int> = Vector.<int>([ 128, 160, 193, 225, 255 ]);
        
        /*
        ** Waves
        */
        internal static const WHITENOISELEN:uint  =(0x280*3);
        internal static const WO_LOWPASSES:uint   =0;
        internal static const WO_TRIANGLE_04:uint =(WO_LOWPASSES+((0xfc+0xfc+0x80*0x1f+0x80+3*0x280)*31));
        internal static const WO_TRIANGLE_08:uint =(WO_TRIANGLE_04+0x04);
        internal static const WO_TRIANGLE_10:uint =(WO_TRIANGLE_08+0x08);
        internal static const WO_TRIANGLE_20:uint =(WO_TRIANGLE_10+0x10);
        internal static const WO_TRIANGLE_40:uint =(WO_TRIANGLE_20+0x20);
        internal static const WO_TRIANGLE_80:uint =(WO_TRIANGLE_40+0x40);
        internal static const WO_SAWTOOTH_04:uint =(WO_TRIANGLE_80+0x80);
        internal static const WO_SAWTOOTH_08:uint =(WO_SAWTOOTH_04+0x04);
        internal static const WO_SAWTOOTH_10:uint =(WO_SAWTOOTH_08+0x08);
        internal static const WO_SAWTOOTH_20:uint =(WO_SAWTOOTH_10+0x10);
        internal static const WO_SAWTOOTH_40:uint =(WO_SAWTOOTH_20+0x20);
        internal static const WO_SAWTOOTH_80:uint =(WO_SAWTOOTH_40+0x40);
        internal static const WO_SQUARES:uint     =(WO_SAWTOOTH_80+0x80);
        internal static const WO_WHITENOISE:uint  =(WO_SQUARES+(0x80*0x20));
        internal static const WO_HIGHPASSES:uint  =(WO_WHITENOISE+WHITENOISELEN);
        internal static const WAVES_SIZE:uint     =(WO_HIGHPASSES+((0xfc+0xfc+0x80*0x1f+0x80+3*0x280)*31));
        
        internal static const vib_tab:Vector.<int> = Vector.<int>([ 
            0,24,49,74,97,120,141,161,180,197,212,224,235,244,250,253,255,
            253,250,244,235,224,212,197,180,161,141,120,97,74,49,24,
            0,-24,-49,-74,-97,-120,-141,-161,-180,-197,-212,-224,-235,-244,-250,-253,-255,
            -253,-250,-244,-235,-224,-212,-197,-180,-161,-141,-120,-97,-74,-49,-24
        ]);

        internal static const period_tab:Vector.<uint> = Vector.<uint>([
            0x0000, 0x0D60, 0x0CA0, 0x0BE8, 0x0B40, 0x0A98, 0x0A00, 0x0970,
            0x08E8, 0x0868, 0x07F0, 0x0780, 0x0714, 0x06B0, 0x0650, 0x05F4,
            0x05A0, 0x054C, 0x0500, 0x04B8, 0x0474, 0x0434, 0x03F8, 0x03C0,
            0x038A, 0x0358, 0x0328, 0x02FA, 0x02D0, 0x02A6, 0x0280, 0x025C,
            0x023A, 0x021A, 0x01FC, 0x01E0, 0x01C5, 0x01AC, 0x0194, 0x017D,
            0x0168, 0x0153, 0x0140, 0x012E, 0x011D, 0x010D, 0x00FE, 0x00F0,
            0x00E2, 0x00D6, 0x00CA, 0x00BE, 0x00B4, 0x00AA, 0x00A0, 0x0097,
            0x008F, 0x0087, 0x007F, 0x0078, 0x0071
        ]);
        // Woohoo!
        internal static const MAX_CHANNELS:uint = 16;
        
        
        
        
        //might come in handy later, thanks bubsy
        internal static const AMIGA_PAL_XTAL:uint            =  28375160;
        internal static const AMIGA_NTSC_XTAL:uint           =  28636360;
        internal static const AMIGA_CPU_PAL_CLK:uint         =  (AMIGA_PAL_XTAL / 4);
        internal static const AMIGA_CPU_NTSC_CLK:uint        =  (AMIGA_NTSC_XTAL / 4);
        internal static const AMIGA_CIA_PAL_CLK:uint         =  (AMIGA_CPU_PAL_CLK / 10);
        internal static const AMIGA_CIA_NTSC_CLK:uint        =  (AMIGA_CPU_NTSC_CLK / 10);
        internal static const AMIGA_PAULA_PAL_CLK:uint       =  (AMIGA_CPU_PAL_CLK / 2);
        internal static const AMIGA_PAULA_NTSC_CLK:uint      =  (AMIGA_CPU_NTSC_CLK / 2);
        
        public static const sample_rate:uint = 44100;
    }
}