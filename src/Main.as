package 
{
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
    import flash.net.FileReference;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import replay_hively.front_panel;
    
    import flash.display.Graphics;
    
    /**
     * ...
     * @author me!
     */
    
    public class Main extends Sprite 
    {
        private var button:Sprite;
        private var replayer:front_panel;
		
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
            replayer = new front_panel();
            replayer.load( new choon() as ByteArray );
            
            draw_buttan( 50, 50, "Play", play );
            draw_buttan( 300, 50, "Stop", stop );
            
            
            //wavegen
            //var fr:FileReference = new FileReference();
            //fr.save(replayer.getdemwaves(), "fl_hively.waves");
            
            //
            
        }
        
        private function draw_buttan( x:int, y:int, label:String, func:Function ):void{
            button = new Sprite();
            button.graphics.beginFill(0xFFCC00);
            button.graphics.drawRect(x, y, 50, 20);
            button.graphics.endFill();
            this.addChild(button);
            
            var text:TextField = new TextField();
            text.selectable = false;
            
            text.text = label;
            text.x = x+10;
            text.y = y+2;
            button.addChild(text);
            
            button.buttonMode = true;
            button.useHandCursor = true;
            button.mouseChildren = false;
            
            button.addEventListener(MouseEvent.CLICK, func);
            
        }
        
        private function play( event:MouseEvent ):void{
            replayer.play();
        }
        
        private function stop( event:MouseEvent ):void{
            replayer.stop();
        }
        
    }
    
}