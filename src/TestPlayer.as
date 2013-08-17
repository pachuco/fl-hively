package {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.SpreadMethod;
    import flash.display.Stage;
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.media.Sound;
    import flash.net.FileReference;
    import flash.net.FileFilter;
    import flash.text.AntiAliasType;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    import hvl.front_panel;
    
    public class TestPlayer extends Sprite{
        
        private var replayer:front_panel;
        private var fr:FileReference;
        private var ff:FileFilter;
        private var taipan:uint = 2;
        private var subnr:uint;
        private var total_time:Number;
        private var VU_shown:Boolean = true;
        
        private var frames_elapsed:uint;
        
        
        private const
        VU_min:uint = 250,
        //stolen from Yotsuba imageboard theme
        color_link_text:uint = 0x0000EE,
        color_ttit_text:uint = 0xCC1105,
        color_name_text:uint = 0x117743,
        color_post_bckg:uint = 0xF0E0D6,
        color_post_text:uint = 0x800000,
        color_butt_bckg:uint = 0xC0C0C0,
        color_butt_text:uint = 0x000000,
        color_tfld_bckg:uint = 0xFFFFFF,
        color_tfld_text:uint = 0x000000,
        color_grad_top :uint = 0xFED6AF,
        color_grad_bot :uint = 0xFFFFEE,
        color_head_0001:uint = 0xFFCCAA,
        color_head_0002:uint = 0xE04000;
        
        private var style_link_text:TextFormat = new TextFormat();
        private var style_ttit_text:TextFormat = new TextFormat();
        private var style_name_text:TextFormat = new TextFormat();
        private var style_post_text:TextFormat = new TextFormat();
        private var style_butt_text:TextFormat = new TextFormat();
        private var style_tfld_text:TextFormat = new TextFormat();
        private var style_asci_text:TextFormat = new TextFormat();
        
        
        private var song_title:TextField;
        private var gen_info:TextField;
        private var play_info:TextField;
        private var song_info:TextField;
        private var sample_names:Vector.<TextField>;
        private var VU_meters:Vector.<Sprite>;
        
        public function TestPlayer() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            [Embed(source = "ahx.blondie", mimeType = "application/octet-stream")] const choon:Class;
            
            
            
            style_me();
            
            draw_bckg_gradient();
            draw_header(10, 2);
            draw_all_buttans(10, 85);
            //spit_text( 50, 400, "Press PLAY without LOADing to play embedded tune.")
            
            
            
            //fr.save(replayer.getwaves, "fl_hively.waves");
            
            replayer = new front_panel();
            load( new choon() as ByteArray);
            
            fr = new FileReference();
            fr.addEventListener(Event.SELECT, onFileSelected);
            ff = new FileFilter("AHX/HVL tunes", "*.ahx;ahx.*;*.hvl;hvl.*");
        }
        
        private function style_me():void {

            style_ttit_text.font = "Arial";
            style_ttit_text.color = color_ttit_text;
            style_ttit_text.kerning = true;
            style_ttit_text.bold = true;
            style_ttit_text.size = 13.3333;
            
            style_link_text.font = "Arial";
            style_link_text.color = color_link_text;
            style_link_text.kerning = true;
            style_link_text.size = 13.3333;
            
            style_name_text.font = "Arial";
            style_name_text.color = color_name_text;
            style_name_text.kerning = true;
            style_name_text.bold = true;
            style_name_text.size = 13.3333;
            
            style_post_text.font = "Arial";
            style_post_text.color = color_post_text;
            style_post_text.kerning = true;
            style_post_text.size = 13.3333;
            
            style_butt_text.font = "Microsoft Sans Serif";
            style_butt_text.color = color_butt_text;
            style_butt_text.kerning = true;
            style_butt_text.size = 13.3333;
            
            style_tfld_text.font = "Microsoft Sans Serif";
            style_tfld_text.color = color_tfld_text;
            style_tfld_text.kerning = true;
            style_tfld_text.size = 13.3333;
            
            style_asci_text.font = "Courier";
            style_asci_text.color = color_post_text;
            style_asci_text.kerning = true;
            style_asci_text.size = 5;
        }
        
        
        
        private function update_all():void {
            update_songtitle();
            draw_sample_names();
            update_subsong();
            update_totaltime();
            update_play();
            update_songinfo();
        }
        
        
        private function update_totaltime():void {
            total_time = Math.floor(replayer.total_time);
            update_play();
        }
        private function update_songtitle():void {
            song_title.text = "Title: " + replayer.song_title;
        }
        private function update_subsong():void {
            gen_info.text = "Subsong: " + replayer.subsong_current+" / "+replayer.subsong_number;
        }
        
        private function update_play():void {
            play_info.text = "Time: " + (Math.floor(replayer.current_time)).toString() + " / " + (total_time).toString() + " s";
        }
        
        private function update_songinfo():void {
            song_info.text = replayer.format + " / " + (replayer.voice_number).toString() + " channel";
        }
        
        private function update_VUmeters():void {
            var i:uint;
            for (i = 0; i < replayer.voice_number; i++ ) {
                if(VU_min<replayer.get_VUmeter(i)){
                    VU_meters[i].scaleX = replayer.get_VUmeter(i) / 190;
                }
            }
        }
        
        private function clear_VUmeters():void {
            var i:uint;
            for (i = 0; i < replayer.voice_number; i++ ) {
                VU_meters[i].scaleX = 1;
            }
        }
        
        
        
        
        
        private function draw_bckg_gradient():void {
            var matr:Matrix = new Matrix();
            matr.createGradientBox( 1, 125, 1.57079633, 0, -25 );
            var sprite:Sprite = new Sprite();
            var g:Graphics = sprite.graphics;
            g.beginGradientFill( GradientType.LINEAR, [ color_grad_top, color_grad_bot ], [ 1, 1 ], [ 0, 255 ], matr, SpreadMethod.PAD );
            g.drawRect( 0, 0, stage.stageWidth , stage.stageHeight );
            
            this.addChild( sprite );
        }
        
        private function draw_VUmeters(x:int, y:int):void {
            var i:uint, j:uint;
            if (VU_meters) {
                for (j = 0; j < VU_meters.length; j++ ) {
                    this.removeChild(VU_meters[j]);
                }
            }
            VU_meters = new Vector.<Sprite>();
            for (i = 0;i<replayer.voice_number; i++ ) {
                var VU:Sprite = new Sprite();
                VU.graphics.beginFill(color_head_0001);
                VU.graphics.drawRect(x, y+20*i, 5, 15);
                VU.graphics.endFill();
                VU_meters.push(VU);
                this.addChild(VU);
                
            }
        }
        
        private function draw_sample_names():void {
            var temp:Vector.<String> = replayer.sample_names;
            var i:uint, j:uint;
            if (sample_names) {
                for (j = 0; j < sample_names.length; j++ ) {
                    this.removeChild(sample_names[j]);
                }
            }
            sample_names = new Vector.<TextField>();
            for (i = 0;i<temp.length;i++ ) {
                sample_names.push(blank_textfield(220, 2 + i * 14, style_asci_text));
                sample_names[i].text = "* " + temp[i];
            }
        }
        
        private function draw_header(x:int, y:int):void {
            var sp:uint = 18;
            song_title = blank_textfield(x, y         , style_ttit_text);
            gen_info   = blank_textfield(x, y + sp    , style_post_text);
            play_info  = blank_textfield(x, y + sp * 2, style_post_text);
            song_info  = blank_textfield(x, y + sp * 3, style_post_text);
        }
        
        private function draw_all_buttans(x:int, y:int):void {
            draw_buttan( x      , y    , "LOAD"  , browse );
            draw_buttan( x+70   , y    , "SNG++" , subsong );
            draw_buttan( x+70*2 , y    , "VU"    , toggle_VUmeters );
            
            draw_buttan( x      , y+30 , "PLAY"  , play );
            draw_buttan( x+70   , y+30 , "PAUSE" , pause );
            draw_buttan( x+70*2 , y+30 , "SOTP"  , stop );
        }
        
        private function draw_buttan( x:int, y:int, label:String, func:Function ):void{
            var button:Sprite = new Sprite();
            button.graphics.beginFill(color_butt_bckg);
            button.graphics.drawRect(x, y, 50, 20);
            button.graphics.endFill();
            this.addChild(button);
            
            var text:TextField = new TextField();
            text.selectable = false;
            
            text.text = label;
            text.defaultTextFormat = style_butt_text;
            text.x = x + 4;
            text.y = y + 1;
            //text.border = true;
            text.width  = 45;
            text.height = 20;
            button.addChild(text);
            
            button.buttonMode = true;
            button.useHandCursor = true;
            button.mouseChildren = false;
            
            button.addEventListener(MouseEvent.CLICK, func);
            
        }

        private function blank_textfield( x:int, y:int, format:TextFormat):TextField {
            var text:TextField = new TextField();
            text.selectable = true;
            text.autoSize = TextFieldAutoSize.LEFT;
            
            text.defaultTextFormat = format;
            text.text = "";
            text.x = x;
            text.y = y;
            this.addChild(text);
            return text;
        }
        
        
        
        
        
        
        
        
        
        
        
        

        
        private function onFileSelected(evt:Event):void{ 
            fr.addEventListener(Event.COMPLETE, onComplete); 
            fr.load(); 
        } 
        
        private function onComplete(event:Event):void {
            load( fr.data );
        }
        
        private function onEnterFrame(event:Event):void {
            var temp:uint, i:uint;
            update_play();
            update_VUmeters();
            frames_elapsed++;
            //if (frames_elapsed%2 == 0) {
                replayer.decrement_VUmeters(1.5);
            //}
            if(VU_shown){
                for (i = 0; i < replayer.voice_number; i++ ) {
                    temp += replayer.get_VUmeter(i);
                }
            }
            if (temp < VU_min) {
                clear_VUmeters();
            }
        }
        
        private function toggle_VUmeters(event:Event):void {
            VU_shown = !VU_shown;
        }
        
        
        
        
        
        private function browse( event:MouseEvent ):void {
            fr.browse([ff]);
        }
        
        private function play( event:MouseEvent ):void {
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            replayer.play();
        }
        
        private function stop( event:MouseEvent ):void {
            replayer.stop();
        }
        
        private function pause( event:MouseEvent ):void {
            replayer.pause();
        }
        
        private function subsong( event:MouseEvent ):void {
            if(replayer.subsong_number){
                replayer.init_subsong(++subnr % (replayer.subsong_number + 1));
                update_subsong();
                update_totaltime();
            }
        }
        
        private function load( data:ByteArray ):void {
            subnr = 0;
            replayer.load( data, taipan );
            draw_VUmeters(0, 150);
            update_all();
        }
    }
}