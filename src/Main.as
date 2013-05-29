package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.FileReference;
    import flash.utils.ByteArray;
    import replay_hively.hvl_replay;
    
    /**
     * ...
     * @author me!
     */
    public class Main extends Sprite 
    {
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            var replayer:hvl_replay = new hvl_replay();
            var fr:FileReference = new FileReference();
            fr.save(replayer.getdemwaves(), "fl_hively.waves");
            
        }
        
    }
    
}