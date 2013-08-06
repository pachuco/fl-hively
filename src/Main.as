package 
{
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
    import flash.net.FileReference;
    import flash.utils.ByteArray;
    import replay_hively.front_panel;
    
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
            [Embed(source="ahx.blondie", mimeType="application/octet-stream")] const choon:Class;
            
            var replayer:front_panel = new front_panel();
            replayer.load( new choon() as ByteArray );
            replayer.play();
            
            //wavegen
            //var fr:FileReference = new FileReference();
            //fr.save(replayer.getdemwaves(), "fl_hively.waves");
            
            //
            
        }
        
    }
    
}