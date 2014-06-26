package hvl {
    public class cons{
        public static const
        
        stereopan_left :Vector.<uint> = Vector.<uint>([ 128,  96,  64,  32,   0 ]),
        stereopan_right:Vector.<uint> = Vector.<uint>([ 128, 160, 193, 225, 255 ]),
        
        /*
        ** Waves
        */
        WHITENOISELEN:uint  =(0x280*3),
        WO_LOWPASSES:uint   =0,
        WO_TRIANGLE_04:uint =(WO_LOWPASSES+((0xfc+0xfc+0x80*0x1f+0x80+3*0x280)*31)),
        WO_TRIANGLE_08:uint =(WO_TRIANGLE_04+0x04),
        WO_TRIANGLE_10:uint =(WO_TRIANGLE_08+0x08),
        WO_TRIANGLE_20:uint =(WO_TRIANGLE_10+0x10),
        WO_TRIANGLE_40:uint =(WO_TRIANGLE_20+0x20),
        WO_TRIANGLE_80:uint =(WO_TRIANGLE_40+0x40),
        WO_SAWTOOTH_04:uint =(WO_TRIANGLE_80+0x80),
        WO_SAWTOOTH_08:uint =(WO_SAWTOOTH_04+0x04),
        WO_SAWTOOTH_10:uint =(WO_SAWTOOTH_08+0x08),
        WO_SAWTOOTH_20:uint =(WO_SAWTOOTH_10+0x10),
        WO_SAWTOOTH_40:uint =(WO_SAWTOOTH_20+0x20),
        WO_SAWTOOTH_80:uint =(WO_SAWTOOTH_40+0x40),
        WO_SQUARES:uint     =(WO_SAWTOOTH_80+0x80),
        WO_WHITENOISE:uint  =(WO_SQUARES+(0x80*0x20)),
        WO_HIGHPASSES:uint  =(WO_WHITENOISE+WHITENOISELEN),
        WAVES_SIZE:uint     =(WO_HIGHPASSES+((0xfc+0xfc+0x80*0x1f+0x80+3*0x280)*31)),
        
        lentab:Vector.<uint> = Vector.<uint>([
            3, 7, 0xf, 0x1f, 0x3f, 0x7f, 3, 7, 0xf, 0x1f, 0x3f, 0x7f,
            0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,
            0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,
            (0x280*3)-1
        ]),
        
        vib_tab:Vector.<int> = Vector.<int>([ 
            0,24,49,74,97,120,141,161,180,197,212,224,235,244,250,253,255,
            253,250,244,235,224,212,197,180,161,141,120,97,74,49,24,
            0,-24,-49,-74,-97,-120,-141,-161,-180,-197,-212,-224,-235,-244,-250,-253,-255,
            -253,-250,-244,-235,-224,-212,-197,-180,-161,-141,-120,-97,-74,-49,-24
        ]),

        period_tab:Vector.<uint> = Vector.<uint>([
            0x0000, 0x0D60, 0x0CA0, 0x0BE8, 0x0B40, 0x0A98, 0x0A00, 0x0970,
            0x08E8, 0x0868, 0x07F0, 0x0780, 0x0714, 0x06B0, 0x0650, 0x05F4,
            0x05A0, 0x054C, 0x0500, 0x04B8, 0x0474, 0x0434, 0x03F8, 0x03C0,
            0x038A, 0x0358, 0x0328, 0x02FA, 0x02D0, 0x02A6, 0x0280, 0x025C,
            0x023A, 0x021A, 0x01FC, 0x01E0, 0x01C5, 0x01AC, 0x0194, 0x017D,
            0x0168, 0x0153, 0x0140, 0x012E, 0x011D, 0x010D, 0x00FE, 0x00F0,
            0x00E2, 0x00D6, 0x00CA, 0x00BE, 0x00B4, 0x00AA, 0x00A0, 0x0097,
            0x008F, 0x0087, 0x007F, 0x0078, 0x0071
        ]),
        
        defgain:Vector.<int> = Vector.<int>([ 71, 72, 76, 85, 100 ]),
        
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
        
        sample_rate:uint = 44100,
        
        filter_thing:Vector.<int> = Vector.<int>([
            -1161, -4413, -7161, -13094, 635, 13255, 2189, 6401,
            9041, 16130, 13460, 5360, 6349, 12699, 19049, 25398,
            30464, 32512, 32512, 32515, 31625, 29756, 27158, 24060,
            20667, 17156, 13970, 11375, 9263, 7543, 6142, 5002,
            4074, 3318, 2702, 2178, 1755, 1415, 1141, 909,
            716, 563, 444, 331, -665, -2082, -6170, -9235,
            -13622, 12545, 9617, 3951, 8345, 11246, 18486, 6917,
            3848, 8635, 17271, 25907, 32163, 32512, 32455, 30734,
            27424, 23137, 18397, 13869, 10429, 7843, 5897, 4435,
            3335, 2507, 1885, 1389, 1023, 720, 530, 353,
            260, 173, 96, 32, -18, -55, -79, -92,
            -95, -838, -3229, -7298, -12386, -7107, 13946, 6501,
            5970, 9133, 14947, 16881, 6081, 3048, 10921, 21843,
            31371, 32512, 32068, 28864, 23686, 17672, 12233, 8469,
            5862, 4058, 2809, 1944, 1346, 900, 601, 371,
            223, 137, 64, 7, -34, -58, -69, -70,
            -63, -52, -39, -26, -14, -5, 4984, -4476,
            -8102, -14892, 2894, 12723, 4883, 8010, 9750, 17887,
            11790, 5099, 2520, 13207, 26415, 32512, 32457, 28690,
            22093, 14665, 9312, 5913, 3754, 2384, 1513, 911,
            548, 330, 143, 3, -86, -130, -139, -125,
            -97, -65, -35, -11, 6, 15, 19, 19,
            16, 12, 8, 6877, -5755, -9129, -15709, 9705,
            10893, 4157, 9882, 10897, 19236, 8153, 4285, 2149,
            15493, 30618, 32512, 30220, 22942, 14203, 8241, 4781,
            2774, 1609, 933, 501, 220, 81, 35, 2,
            -18, -26, -25, -20, -13, -7, -1, 2,
            4, 4, 3, 2, 1, 0, 0, -1,
            2431, -6956, -10698, -14594, 12720, 8980, 3714, 10892,
            12622, 19554, 6915, 3745, 1872, 17779, 32512, 32622,
            26286, 16302, 8605, 4542, 2397, 1265, 599, 283,
            45, -92, -141, -131, -93, -49, -14, 8,
            18, 18, 14, 8, 3, 0, -2, -3,
            -2, -2, -1, 0, 0, -3654, -8008, -12743,
            -11088, 13625, 7342, 3330, 11330, 14859, 18769, 6484,
            3319, 1660, 20065, 32512, 30699, 21108, 10616, 5075,
            2425, 1159, 477, 196, 1, -93, -109, -82,
            -44, -12, 7, 14, 13, 9, 4, 0,
            -2, -2, -1, -1, 0, 0, 0, 0,
            0, 0, -7765, -8867, -14957, -5862, 13550, 6139,
            2988, 11284, 17054, 16602, 6017, 2979, 1489, 22351,
            32512, 28083, 15576, 6708, 2888, 1243, 535, 188,
            32, -47, -64, -47, -22, -3, 7, 8,
            5, 3, 0, -1, -1, -1, 0, 0,
            0, 0, 0, 0, 0, 0, 0, -9079,
            -9532, -16960, -335, 13001, 5333, 2704, 11192, 18742,
            13697, 5457, 2703, 1351, 24637, 32512, 24556, 10851,
            4185, 1614, 622, 184, 15, -57, -59, -34,
            -9, 5, 8, 6, 2, 0, -1, -1,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, -8576, -10043, -18551, 4372,
            12190, 4809, 2472, 11230, 19803, 11170, 4953, 2473,
            1236, 26923, 32512, 20567, 7430, 2550, 875, 212,
            51, -30, -43, -25, -6, 3, 5, 3,
            1, 0, -1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, -6960, -10485, -19740, 7864, 11223, 4449, 2279,
            11623, 20380, 9488, 4553, 2280, 1140, 29209, 31829,
            16235, 4924, 1493, 452, 86, -7, -32, -20,
            -5, 2, 3, 2, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, -4739, -10974,
            -19831, 10240, 10190, 4169, 2114, 12524, 20649, 8531,
            4226, 2114, 1057, 31495, 29672, 11916, 3168, 841,
            121, 17, -22, -18, -5, 2, 2, 1,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, -2333, -11641, -19288, 11765, 9175,
            3923, 1971, 13889, 20646, 8007, 3942, 1971, 985,
            32512, 27426, 8446, 1949, 449, 45, -11, -16,
            -5, 1, 1, 1, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            29, -12616, -17971, 12690, 8247, 3693, 1846, 15662,
            20271, 7658, 3692, 1846, 923, 32512, 25132, 6284,
            1245, 246, -71, -78, -17, 8, 7, 1,
            -1, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 2232, -14001, -15234,
            13198, 7447, 3478, 1736, 17409, 19411, 7332, 3472,
            1736, 868, 32512, 22545, 4352, 731, 18, -117,
            -40, 8, 9, 2, -1, -1, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 4197, -15836, -11480, 13408, 6791, 3281,
            1639, 19224, 18074, 6978, 3276, 1639, 819, 32512,
            19657, 2706, 380, -148, -86, 2, 13, 3,
            -2, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 5863,
            -17878, -9460, 13389, 6270, 3104, 1551, 20996, 16431,
            6616, 3102, 1551, 776, 32512, 16633, 1921, 221,
            -95, -39, 5, 5, 0, -1, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 7180, -20270, -6194, 13181,
            5866, 2946, 1473, 22548, 14746, 6273, 2946, 1473,
            737, 32512, 13621, 1263, 116, -53, -15, 4,
            2, -1, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 8117, -21129, -2795, 12809, 5550, 2804, 1402,
            23717, 13326, 5962, 2804, 1402, 701, 32512, 10687,
            776, -56, -56, 4, 4, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 8560, -19953,
            508, 12299, 5295, 2675, 1337, 25109, 12263, 5684,
            2675, 1338, 669, 32512, 7905, 433, -36, -22,
            3, 1, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 8488, -18731, 3672, 11679, 5080,
            2558, 1279, 26855, 11480, 5434, 2557, 1279, 639,
            32512, 5357, 212, -95, 0, 4, -1, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            7977, -24055, 6537, 10986, 4883, 2450, 1225, 28611,
            10918, 5206, 2450, 1225, 612, 32512, 3131, 83,
            -35, 2, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 7088, -30584, 9054,
            10265, 4696, 2351, 1176, 28707, 10494, 4996, 2351,
            1175, 588, 32512, 1920, -155, -13, 4, -1,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 5952, -32627, 11249, 9564, 4519, 2260,
            1130, 28678, 10113, 4803, 2260, 1130, 565, 32512,
            1059, -73, -1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 4629,
            -32753, 13199, 8934, 4351, 2175, 1088, 28446, 9775,
            4623, 2175, 1087, 544, 32512, 434, -22, 1,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 3132, -32768, 15225, 8430,
            4194, 2097, 1049, 30732, 9439, 4456, 2097, 1049,
            524, 32512, 75, -6, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 1345, -32768, 16765, 8107, 4048, 2025, 1012,
            32512, 9112, 4302, 2025, 1012, 506, 32385, 392,
            5, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, -706, -32768,
            17879, 8005, 3913, 1956, 978, 32512, 8843, 4157,
            1957, 978, 489, 31184, 1671, 122, 10, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, -3050, -32768, 18923, 8163, 3799,
            1893, 946, 32512, 8613, 4022, 1893, 945, 473,
            29903, 3074, 316, 52, 11, 3, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            -5812, -32768, 19851, 8626, 3739, 1833, 917, 32512,
            7982, 3889, 1833, 916, 459, 28541, 4567, 731,
            206, 66, 23, 8, 1, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, -9235, -32768, 20587,
            9408, 3841, 1784, 889, 32512, 6486, 3688, 1776,
            889, 447, 27099, 6112, 1379, 313, 135, 65,
            33, 17, 7, 4, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, -12713, 1188, 1318, -1178, -4304, -26320,
            -14931, -1716, -1486, 2494, 3611, 22275, 27450, -31839,
            -29668, -26258, -21608, -15880, -9560, -3211, 3138, 9369,
            15281, 20717, 25571, 29774, 32512, 32512, 32512, 32512,
            32512, 32512, 32512, 32512, 32512, 32512, 32512, 32512,
            32512, 32748, 32600, 32750, 32566, 32659, 32730, 8886,
            1762, 506, -1665, -12112, -24641, -8513, -2224, 247,
            3288, 9926, 25787, 28909, -31048, -27034, -20726, -12532,
            -3896, 4733, 13043, 20568, 27010, 32215, 32512, 32512,
            32512, 32512, 32512, 32512, 32512, 32762, 32696, 32647,
            32512, 32665, 32512, 32587, 32638, 32669, 32681, 32679,
            32667, 32648, 32624, 32598, 6183, 2141, -630, -2674,
            -21856, -18306, -5711, -2161, 2207, 4247, 17616, 26475,
            29719, -30017, -23596, -13741, -2819, 8029, 18049, 26470,
            32512, 32512, 32512, 32512, 32512, 32512, 32512, 32738,
            32663, 32612, 32756, 32549, 32602, 32629, 32636, 32628,
            32610, 32588, 32564, 32542, 32524, 32510, 32500, 32494,
            32492, 3604, 2248, -1495, -5612, -26800, -13545, -4745,
            -1390, 3443, 6973, 23495, 27724, 30246, -28745, -19355,
            -6335, 6861, 19001, 28690, 32512, 32512, 32512, 32512,
            32512, 32512, 32512, 32512, 32667, 32743, 32757, 32730,
            32681, 32624, 32572, 32529, 32500, 32482, 32476, 32477,
            32482, 32489, 32497, 32504, 32509, 32513, 7977, 1975,
            -1861, -9752, -25893, -10150, -4241, 86, 4190, 10643,
            25235, 28481, 30618, -27231, -14398, 1096, 15982, 27872,
            32512, 32512, 32512, 32512, 32512, 32734, 32631, 32767,
            32531, 32553, 32557, 32551, 32539, 32527, 32516, 32509,
            32505, 32504, 32505, 32506, 32508, 32510, 32511, 32512,
            32512, 32512, 32511, 14529, 1389, -2028, -14813, -22765,
            -7845, -3774, 1986, 4706, 14562, 25541, 29019, 30894,
            -25476, -9294, 8516, 23979, 32512, 32512, 32512, 32512,
            32512, 32512, 32708, 32762, 32727, 32654, 32579, 32522,
            32490, 32478, 32480, 32488, 32498, 32507, 32512, 32515,
            32515, 32514, 32513, 32512, 32510, 32510, 32510, 32510,
            17663, 557, -2504, -19988, -19501, -6436, -3340, 4135,
            5461, 18788, 26016, 29448, 31107, -23481, -4160, 15347,
            30045, 32512, 32512, 32512, 32512, 32512, 32674, 32700,
            32654, 32586, 32531, 32498, 32486, 32488, 32496, 32504,
            32510, 32513, 32514, 32513, 32512, 32511, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 16286, -402, -3522,
            -23951, -16641, -5631, -2983, 6251, 6837, 22781, 26712,
            29788, 31277, -21244, 1108, 21806, 32512, 32512, 32512,
            32512, 32695, 32576, 32622, 32600, 32557, 32520, 32501,
            32496, 32500, 32505, 32509, 32512, 32512, 32512, 32511,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 13436, -1351, -4793, -25948, -14224, -5151,
            -2702, 7687, 8805, 25705, 27348, 30064, 31415, -18766,
            5872, 26652, 32512, 32512, 32512, 32747, 32581, 32620,
            32586, 32540, 32508, 32497, 32499, 32505, 32510, 32512,
            32512, 32512, 32511, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 10427,
            -2162, -7136, -26147, -12195, -4810, -2474, 8723, 11098,
            27251, 27832, 30293, 31530, -16047, 10877, 30990, 32512,
            32512, 32512, 32512, 32584, 32571, 32536, 32511, 32502,
            32503, 32507, 32510, 32512, 32512, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 7797, -2748, -10188, -25174,
            -10519, -4515, -2281, 9397, 13473, 27937, 28213, 30487,
            31627, -13087, 15816, 32512, 32512, 32512, 32715, 32550,
            32560, 32534, 32512, 32505, 32506, 32508, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 5840, -3084, -13327, -23617, -9177, -4231, -2116,
            9892, 15843, 28292, 28538, 30652, 31710, -9886, 20235,
            32512, 32512, 32512, 32512, 32550, 32534, 32514, 32507,
            32507, 32510, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 4592, -3215,
            -15898, -21856, -8141, -3958, -1972, 10401, 18229, 28612,
            28824, 30796, 31781, -7103, 24037, 32512, 32512, 32745,
            32535, 32534, 32517, 32508, 32508, 32509, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 3964, -3262, -18721, -20087, -7368,
            -3705, -1847, 11014, 20634, 28996, 29075, 30920, 31843,
            -4732, 27243, 32512, 32512, 32648, 32627, 32530, 32495,
            32500, 32510, 32512, 32512, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            3858, -3404, -21965, -18398, -6801, -3479, -1738, 12009,
            22960, 29429, 29294, 31030, 31898, -2281, 30194, 32512,
            32512, 32699, 32569, 32496, 32496, 32509, 32513, 32512,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 4177, -3869, -24180,
            -16820, -6380, -3280, -1640, 13235, 25035, 29863, 29490,
            31128, 31947, 251, 32758, 32512, 32749, 32652, 32508,
            32490, 32507, 32513, 32512, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 4837, -4913, -26436, -15364, -6056, -3103,
            -1553, 14759, 26704, 30256, 29664, 31215, 31991, 2863,
            32512, 32512, 32657, 32580, 32503, 32501, 32510, 32512,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 5755,
            -6290, -27702, -14036, -5788, -2947, -1474, 16549, 27912,
            30602, 29821, 31294, 32030, 5555, 32512, 32512, 32592,
            32541, 32505, 32507, 32511, 32511, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 6898, -8911, -27788, -12841,
            -5550, -2805, -1403, 18509, 28687, 30906, 29963, 31364,
            32066, 8328, 32512, 32512, 32623, 32511, 32502, 32510,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 8107, -11465, -27077, -11789, -5325, -2676, -1339,
            19833, 29213, 31179, 30092, 31429, 32098, 11181, 32512,
            32512, 32561, 32508, 32508, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 9247, -13203,
            -25808, -10886, -5109, -2559, -1280, 21060, 29636, 31428,
            30209, 31488, 32127, 14114, 32512, 32681, 32529, 32502,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 10252, -16863, -24251, -10137, -4902,
            -2451, -1226, 21937, 30022, 31656, 30317, 31542, 32154,
            17128, 32512, 32581, 32514, 32508, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            11032, -22427, -22598, -9535, -4705, -2353, -1177, 20999,
            30406, 31867, 30415, 31591, 32179, 20222, 32512, 32591,
            32501, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 11539, -19778, -20962,
            -9060, -4522, -2261, -1131, 19486, 30789, 32061, 30507,
            31637, 32201, 23396, 32512, 32535, 32508, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 11803, -12759, -19353, -8690, -4353, -2177,
            -1089, 18499, 31165, 32240, 30591, 31678, 32222, 26651,
            32512, 32514, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 11826,
            -7586, -17510, -8384, -4196, -2099, -1050, 26861, 31521,
            32406, 30669, 31718, 32241, 29986, 32585, 32510, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 32511, 32511, 32511, 32511,
            32511, 32511, 32511, 32511, 11599, -2848, -15807, -8097,
            -4051, -2025, -1014, 30693, 31850, 32561, 30743, 31755,
            32261, 32512, 32524, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 11037, -5302, -14051, -7770, -3913, -1958, -980,
            28033, 32165, 32705, 30810, 31789, 32278, 32512, 32729,
            32536, 32513, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 10114, -7837,
            -12293, -7348, -3782, -1894, -948, 24926, 32473, 32512,
            30873, 31819, 32294, 32512, 32512, 32580, 32527, 32515,
            32512, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 8759, -10456, -10591, -6766, -3638,
            -1835, -917, 24058, 32600, 32512, 30934, 31850, 32309,
            32512, 32512, 32729, 32591, 32537, 32520, 32514, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            32510, 32510, 32510, 32510, 32510, 32510, 32510, 32510,
            6811, -13156, -9045, -5965, -3421, -1776, -890, 31582,
            32246, 32512, 30988, 31878, 32324, 32512, 32512, 32512,
            32628, 32573, 32541, 32526, 32518, 32514, 32513, 32512,
            32512, 32512, 32512, 32512, 32512, 32512, 32512, 32512,
            32512, 32512, 32512, 32512, 32512, 32512, 32512, 32512,
            32512, 32512, 32512, 32512, 32512, 4835
        ]);
    }
}