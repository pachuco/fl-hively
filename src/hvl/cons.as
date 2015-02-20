package hvl {
    public class cons {
        public static const
        
        // Woohoo!
        MAX_CHANNELS:uint = 16,
        
        //might come in handy later, thanks bubsy
        AMIGA_PAL_XTAL:uint            =  28375160,
        AMIGA_NTSC_XTAL:uint           =  28636360,
        AMIGA_CPU_PAL_CLK:uint         =  (AMIGA_PAL_XTAL / 4),
        AMIGA_CPU_NTSC_CLK:uint        =  (AMIGA_NTSC_XTAL / 4),
        AMIGA_CIA_PAL_CLK:uint         =  (AMIGA_CPU_PAL_CLK / 10),
        AMIGA_CIA_NTSC_CLK:uint        =  (AMIGA_CPU_NTSC_CLK / 10),
        AMIGA_PAULA_PAL_CLK:uint       =  (AMIGA_CPU_PAL_CLK / 2),
        AMIGA_PAULA_NTSC_CLK:uint      =  (AMIGA_CPU_NTSC_CLK / 2),
        
        sample_rate:uint = 44100;
    }
}