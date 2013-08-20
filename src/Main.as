package 
{
    import flash.display.Sprite;
    import flash.events.*;
    
    import com.demonsters.debugger.MonsterDebugger;
    import com.sociodox.theminer.*;
    
    /**
     * ...
     * @author me!
     */
    [SWF(width='800',height='800',backgroundColor='#FFFFEE',frameRate='60')]
    public class Main extends Sprite {
        
        public function Main():void{
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            //MonsterDebugger.initialize(this);
            //this.addChild(new TheMiner());
            
            var TP:TestPlayer = new TestPlayer();
            this.addChild(TP);
            

        }
    }
    
}