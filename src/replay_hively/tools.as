package replay_hively{
    public class tools{
        public static function bitRotate(n:int, x:int, bits:uint):int{
            //Thanks go to Raymond Basque.
            var tmp:int =0;
            var msk:int = 0xffffffff >>> (32-bits); 
            var result:int=0;
            x %= bits;
            tmp = n & msk;
            result = x < 0 ? (n << -x) : (n  >>> x);
            if (x < 0){
                tmp >>>= (bits + x);
            }else {
                tmp <<= (bits - x);
            }
            result |= tmp;
            return result & msk;
        }
        
        public static function strnget(ba:ByteArray, off:uint, range:uint):String{
            var i:uint;
            var s:String="";
            for(i=0; ba[off+i]!=0x00 && i<range && (off+i)<ba.length; i++){
                s+=ba[off+i];
            }
            return s;//+0x00;
        }
        
        public static function ui2i8(x:int):int{
            if(x>=128){
                x-=256;
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