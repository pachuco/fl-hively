package 
{
    import flash.display.Sprite;
    import flash.events.*;
    import flash.media.Sound;
    import flash.net.FileReference;
    import flash.net.FileFilter;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import replay_hively.front_panel;
    
    import flash.display.Graphics;
    
    //import com.demonsters.debugger.MonsterDebugger;
    //import com.sociodox.theminer.*;
    
    /**
     * ...
     * @author me!
     */
    
    public class Main extends Sprite 
    {
        private var button:Sprite;
        private var replayer:front_panel;
        private var fr:FileReference;
        private var ff:FileFilter;
        private var taipan:uint = 2;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            //MonsterDebugger.initialize(this);
            //this.addChild(new TheMiner());
            
            
            
            
            [Embed(source="ahx.blondie", mimeType="application/octet-stream")] const choon:Class;
            replayer = new front_panel();
            replayer.load( new choon() as ByteArray, taipan );
            
            fr = new FileReference();
            fr.addEventListener(Event.SELECT, onFileSelected);
            ff = new FileFilter("AHX/HVL tunes", "*.ahx;ahx.*;*.hvl;hvl.*");
            
            draw_buttan( 50, 50, "LOAD", load );
            
            draw_buttan( 50, 100, "PLAY", play );
            draw_buttan( 110, 100, "PAUSE", pause );
            draw_buttan( 170, 100, "SOTP", stop );
            //spit_text( 50, 400, "Press PLAY without LOADing to play embedded tune.")
            
            
            //wavegen
            
            //fr.save(replayer.getwaves(), "fl_hively.waves");
            
            //
            
        }
        
        private function spit_text( x:int, y:int, data:String):void {
            var text:TextField = new TextField();
            text.selectable = false;
            
            text.text = data;
            text.x = x;
            text.y = y;
            //text.border = true;
            this.addChild(text);
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
            text.x = x + 5;
            text.y = y + 2;
            //text.border = true;
            text.width  = 45;
            text.height = 20;
            button.addChild(text);
            
            button.buttonMode = true;
            button.useHandCursor = true;
            button.mouseChildren = false;
            
            button.addEventListener(MouseEvent.CLICK, func);
            
        }
        
        private function onFileSelected(evt:Event):void{ 
            fr.addEventListener(Event.COMPLETE, onComplete); 
            fr.load(); 
        } 
        
        private function onComplete(event:Event):void { 
            replayer.load( fr.data, taipan ); 
        }
        
        
        
        
        
        
        private function load( event:MouseEvent ):void {
            fr.browse([ff]);
        }
        
        private function play( event:MouseEvent ):void{
            replayer.play();
        }
        
        private function stop( event:MouseEvent ):void{
            replayer.stop();
        }
        
        private function pause( event:MouseEvent ):void{
            replayer.pause();
        }
    }
    
}