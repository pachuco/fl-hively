package replay_hively {    import flash.utils.ByteArray;	import flash.utils.Endian;    public class ButtArray extends ByteArray{        public function ButtArray():void{            endian=Endian.LITTLE_ENDIAN;        }    //TODO: add lazy, indexed read/write methods    }}