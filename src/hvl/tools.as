package hvl {
    import flash.utils.ByteArray;
    public class tools{
        public static function bitRotate(x:int, n:int, bits:uint):int{
            //Thanks go to Raymond Basque.
            var temp:int =0;
            var msk:int = 0xffffffff >>> (32-bits); 
            var result:int=0;
            n %= bits;
            temp = x & msk;
            result = n < 0 ? (x << -n) : (x  >>> n);
            if (n < 0){
                temp >>>= (bits + n);
            }else {
                temp <<= (bits - n);
            }
            result |= temp;
            return result & msk;
        }
        
        public static function strncpy(ba:ByteArray, off:uint, range:uint):String{
            var i:uint;
            var s:String="";
            for(i=0; ba[off+i]!=0x00 && i<range && (off+i)<ba.length; i++){
                s+=String.fromCharCode(ba[off+i]);
            }
            return s;//+0x00;
        }

        public static function strlen(ba:ByteArray, off:uint):uint{
            var i:uint;

            for(i=0; ba[off+i]!=0x00 && (off+i)<ba.length; i++){
            }
            return i;
        }
        
        public static function memcpy(dest:Vector.<int>, source:Vector.<int>, off:uint, size:uint):void {
            dest = new Vector.<int>( size, true );
            for (var i:uint = 0; i < size; i++ ) {
                dest[i] = source[off+i];
            }
        }
        
        //Shamelessly stolen from foobar plugin SDK
        public static function time_to_samples(p_time:Number, p_sample_rate:uint):uint{
            return Math.floor(p_sample_rate * p_time + 0.5);
        }
        
        //Same
        public static function samples_to_time( p_samples:uint, p_sample_rate:uint):Number{
            return p_samples / p_sample_rate;
        }
        
        public static function ui2i8(x:uint):int{
            if(x>=128){
                x-=256;
            }
            return x;
        }
        
        public static function ui2i16(x:uint):int{
            if(x>=32768){
                x-=65536;
            }
            return x;
        }
        public static function ui2i32(x:uint):int{
            if(x>=2147483646){
                x-=4294967295;
                x++
            }
            return x;
        }
        
        public static function ui2i8v2(x:int):int{
            if (x >= 128){
                x -= 256;
                return ((x & 0x80000000) >> 24) | (x & 0x0000007F);
            }else{
                return (x & 0x0000007F);
            }
        }
        
        public static function ui2i8v3(x:uint):int{
            if (x >= 128){
                return int((1 << 7) | (x & 0x0000007F));
            }else{
                return int(x);
            }
        }
    }
}