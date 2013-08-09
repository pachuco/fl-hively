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
            
            fr = new FileReference();
			fr.addEventListener(Event.SELECT, onFileSelected);
			ff = new FileFilter("AHX tunes", "*.ahx;ahx.*");;
            
            draw_buttan( 50, 300, "PLAY", play );
            draw_buttan( 300, 300, "PAUSE", pause );
			draw_buttan( 500, 300, "SOTP", stop );
            draw_buttan( 50, 50, "LOAD", load );
			//spit_text( 50, 400, "Press PLAY without LOADing to play embedded tune.")
            
            
            //wavegen
            
            //fr.save(replayer.getdemwaves(), "fl_hively.waves");
            
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
            text.x = x+10;
            text.y = y + 2;
			//text.border = true;
			text.length;
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
			replayer.load( fr.data );; 
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