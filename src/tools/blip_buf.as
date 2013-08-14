package tools {
    public class blip_buf{

        /* blip_buf 1.1.0. http://www.slack.net/~ant/ */
        /* Library Copyright (C) 2003-2009 Shay Green. This library is free software;
           you can redistribute it and/or modify it under the terms of the GNU Lesser
           General Public License as published by the Free Software Foundation; either
           version 2.1 of the License, or (at your option) any later version. This
           library is distributed in the hope that it will be useful, but WITHOUT ANY
           WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
           A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
           details. You should have received a copy of the GNU Lesser General Public
           License along with this module; if not, write to the Free Software Foundation,
           Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA */
        
        
        //Sample buffer that resamples from input clock rate to output sample rate
        
        
        //private static const pre_shift:uint       = 32;
        private static const pre_shift:uint       = 0;
        private static const time_bits:uint       = pre_shift + 20;
        
        private static const time_unit:uint       = 1 << time_bits;
        
        private static const bass_shift:uint      = 9 /* affects high-pass filter breakpoint frequency */
        private static const end_frame_extra:uint = 2 /* allows deltas slightly after frame length */
        
        private static const half_width:uint  = 8;
        private static const buf_extra:uint   = half_width*2 + end_frame_extra;
        private static const phase_bits:uint  = 5;
        private static const phase_count:uint = 1 << phase_bits;
        private static const delta_bits:uint  = 15;
        private static const delta_unit:uint  = 1 << delta_bits;
        private static const frac_bits:uint   = time_bits - pre_shift;
        
        /* We could eliminate avail and encode whole samples in offset, but that would
        limit the total buffered samples to blip_max_frame. That could only be
        increased by decreasing time_bits, which would reduce resample ratio accuracy.
        */

        /** Sample buffer that resamples to output rate and accumulates samples
        until they're read out */
        
        
        /** First parameter of most functions is blip_t*, or const blip_t* if nothing
        is changed. */
        typedef struct hvl_blip_t hvl_blip_t;

        /** Returns the size of a blip_t object of the given sample count. */
        public function hvl_blip_size( int sample_count ):uint;

        /** Creates new buffer that can hold at most sample_count samples. Sets rates
        so that there are blip_max_ratio clocks per sample. */
        public function hvl_blip_new_inplace( hvl_blip_t*, int sample_count ):void;

        /** Sets approximate input clock rate and output sample rate. For every
        clock_rate input clocks, approximately sample_rate samples are generated. */
        public function hvl_blip_set_rates( hvl_blip_t*, double clock_rate, double sample_rate ):void;

        /** Maximum clock_rate/sample_rate ratio. For a given sample_rate,
        clock_rate must not be greater than sample_rate*blip_max_ratio. */
        public static const hvl_blip_max_ratio:uint = 1 << 20;

        /** Clears entire buffer. Afterwards, blip_samples_avail() == 0. */
        public function hvl_blip_clear( hvl_blip_t* ):void;

        /** Adds positive/negative delta into buffer at specified clock time. */
        public function hvl_blip_add_delta( hvl_blip_t*, unsigned int clock_time, int delta ):void;

        /** Same as blip_add_delta(), but uses faster, lower-quality synthesis. */
        public function hvl_blip_add_delta_fast( hvl_blip_t*, unsigned int clock_time, int delta ):void;

        /** Length of time frame, in clocks, needed to make sample_count additional
        samples available. */
        public function hvl_blip_clocks_needed( const hvl_blip_t*, int sample_count ):int;

        /** Maximum number of samples that can be generated from one time frame. */
        public static const hvl_blip_max_frame:uint = 4000 ;

        /** Makes input clocks before clock_duration available for reading as output
        samples. Also begins new time frame at clock_duration, so that clock time 0 in
        the new time frame specifies the same clock as clock_duration in the old time
        frame specified. Deltas can have been added slightly past clock_duration (up to
        however many clocks there are in two output samples). */
        public function hvl_blip_end_frame( hvl_blip_t*, unsigned int clock_duration ):void;

        /** Number of buffered samples available for reading. */
        public function hvl_blip_samples_avail( const hvl_blip_t* ):int;

        /** Reads and removes at most 'count' samples and writes them to 'out'. If
        'stereo' is true, writes output to every other element of 'out', allowing easy
        interleaving of two buffers into a stereo sample stream. Outputs 16-bit signed
        samples. Returns number of samples actually read.  */
        public function hvl_blip_read_samples( hvl_blip_t*, int out [], int count, int gain ):int;
    }
}