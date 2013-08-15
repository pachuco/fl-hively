package hvl {
    import flash.utils.ByteArray;
    internal class tools{
        internal static function bitRotate(x:int, n:int, bits:uint):int{
            //Thanks go to Raymond Basque.
            var tmp:int =0;
            var msk:int = 0xffffffff >>> (32-bits); 
            var result:int=0;
            n %= bits;
            tmp = x & msk;
            result = n < 0 ? (x << -n) : (x  >>> n);
            if (n < 0){
                tmp >>>= (bits + n);
            }else {
                tmp <<= (bits - n);
            }
            result |= tmp;
            return result & msk;
        }
        
        internal static function strncpy(ba:ByteArray, off:uint, range:uint):String{
            var i:uint;
            var s:String="";
            for(i=0; ba[off+i]!=0x00 && i<range && (off+i)<ba.length; i++){
                s+=String.fromCharCode(ba[off+i]);
            }
            return s;//+0x00;
        }

        internal static function strlen(ba:ByteArray, off:uint):uint{
            var i:uint;

            for(i=0; ba[off+i]!=0x00 && (off+i)<ba.length; i++){
            }
            return i;
        }
        
        internal static function memcpy(dest:Vector.<int>, source:Vector.<int>, off:uint, size:uint):void {
            dest = new Vector.<int>( size, true );
            for (var i:uint = 0; i < size; i++ ) {
                dest[i] = source[off+i];
            }
        }
        
        internal static function ui2i8(x:uint):int{
            if(x>=128){
                x-=256;
            }
            return x;
        }
        
        internal static function ui2i16(x:uint):int{
            if(x>=32768){
                x-=65536;
            }
            return x;
        }
        internal static function ui2i32(x:uint):int{
            if(x>=2147483646){
                x-=4294967295;
                x++
            }
            return x;
        }
        
        internal static function ui2i8v2(x:int):int{
            if (x >= 128){
                x -= 256;
                return ((x & 0x80000000) >> 24) | (x & 0x0000007F);
            }else{
                return (x & 0x0000007F);
            }
        }
        
        internal static function ui2i8v3(x:uint):int{
            if (x >= 128){
                return int((1 << 7) | (x & 0x0000007F));
            }else{
                return int(x);
            }
        
        }
    }
}