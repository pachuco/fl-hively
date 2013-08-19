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
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.net.FileReference;
    import flash.net.FileFilter;
    import flash.text.AntiAliasType;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    import hvl.cons;
    import hvl.front_panel;
    
    //This thing is a bloody mess!
    //TODO: stick it in its own package and split it into classes.
    //If this is suppose to be made readable.
    
    public class TestPlayer extends Sprite{
        
        private var replayer:front_panel;
        private var fr:FileReference;
        private var ff:FileFilter;
        private var subnr:uint;
        private var total_time:Number;
        private var VU_shown:Boolean = true;
        private var VU_ringbuffers:Vector.<Vector.<int>>;
        private var VU_instant:Vector.<int>;
        private var VU_index:uint;
        private var VU_delay:uint;
        private var isDragged_trackBar:Boolean;
        private var bar_length:uint;
        
        
        private static const
        def_framerate:uint    = 60,
        sleep_framerate:uint  = 1,
        taipan:uint = 2,
        VU_rolloff:Number = 1.04,
        //stolen from Yotsuba imageboard theme
        col_blueLink                    :uint = 0x0000EE,
        col_redPostTitle                :uint = 0xCC1105,
        col_greenName                   :uint = 0x117743,
        col_pinkishBackground           :uint = 0xF0E0D6,
        col_redBrownText                :uint = 0x800000,
        col_grayButton                  :uint = 0xC0C0C0,
        col_blackText                   :uint = 0x000000,
        col_whiteBackground             :uint = 0xFFFFFF,
        col_peachGradientTop            :uint = 0xFED6AF,
        col_lightLimeGradientBottom     :uint = 0xFFFFEE,
        col_peachHeader                 :uint = 0xFFCCAA,
        col_bloodHeader                 :uint = 0xE04000;
        
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
        private var VU_rectangles:Vector.<Sprite>;
        private var _trackBar:Sprite;
        
        public function TestPlayer() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            stage.frameRate = sleep_framerate;
            [Embed(source = "ahx.blondie", mimeType = "application/octet-stream")] const choon:Class;
            
            
            
            style_me();
            
            draw_bckg_gradient();
            draw_header(10, 2);
            draw_trackbar(10,85,185);
            draw_all_buttans(10, 125);
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
            style_ttit_text.color = col_redPostTitle;
            style_ttit_text.kerning = true;
            style_ttit_text.bold = true;
            style_ttit_text.size = 13.3333;
            
            style_link_text.font = "Arial";
            style_link_text.color = col_blueLink;
            style_link_text.kerning = true;
            style_link_text.size = 13.3333;
            
            style_name_text.font = "Arial";
            style_name_text.color = col_greenName;
            style_name_text.kerning = true;
            style_name_text.bold = true;
            style_name_text.size = 13.3333;
            
            style_post_text.font = "Arial";
            style_post_text.color = col_redBrownText;
            style_post_text.kerning = true;
            style_post_text.size = 13.3333;
            
            style_butt_text.font = "Microsoft Sans Serif";
            style_butt_text.color = col_blackText;
            style_butt_text.kerning = true;
            style_butt_text.size = 13.3333;
            
            style_asci_text.font = "Courier";
            style_asci_text.color = col_redBrownText;
            style_asci_text.kerning = true;
            style_asci_text.size = 5;
        }
        
        
        
        private function update_all():void {
            update_songtitle();
            update_sample_names();
            update_subsong();
            update_totaltime();
            update_play();
            update_songinfo();
            update_VUBuffers();
            update_trackbar();
        }
        
        
        private function update_sample_names():void {
            var temp:Vector.<String> = replayer.info_sampleNames;
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
        
        private function update_totaltime():void {
            total_time = Math.floor(replayer.info_tuneLength);
            update_play();
        }
        private function update_songtitle():void {
            song_title.text = "Title: " + replayer.info_title;
        }
        private function update_subsong():void {
            gen_info.text = "Subsong: " + replayer.cur_subsong+" / "+replayer.info_subsongNr;
        }
        
        private function update_play():void {
            play_info.text = "Time: " + (Math.floor(replayer.cur_playTime)).toString() + " / " + (total_time).toString() + " s";
        }
        
        private function update_songinfo():void {
            song_info.text = replayer.info_format + " / " + (replayer.info_channels).toString() + " channel";
        }
        
        private function update_VUBuffers():void {
            VU_instant = replayer.get_VUmeters();
            VU_delay = (cons.sample_rate / replayer.cur_bufLength) / 30 * def_framerate;
            VU_index = 0;
            var chans:uint=replayer.info_channels;
            var i:uint;
            VU_ringbuffers = new Vector.<Vector.<int>>(chans, true);
            for (i = 0; i< chans; i++) {
                VU_ringbuffers[i] = new Vector.<int>(VU_delay, true);
            }
        }
        
        private function update_trackbar():void{
            if(!isDragged_trackBar && (replayer.info_tuneLength > replayer.cur_playTime)){
                _trackBar.x = bar_length * (replayer.cur_playTime / replayer.info_tuneLength);
            }
        }
        
        private function update_VUmeters():void {
            var i:uint;
            var activity:Boolean = false;
            if (VU_shown) {
                for (i = 0; i < replayer.info_channels; i++ ) {
                    if (1 < VU_buffered(i)) {
                        activity = true;
                        VU_rectangles[i].scaleX = VU_buffered(i);
                    }else {
                        clear_VUmeter(i);
                    }
                    VU_instant[i]<1 ? VU_instant[i]=1 : VU_instant[i]-=1;
                }                
            }else{
                for (i = 0; i < replayer.info_channels; i++ ) {
                    clear_VUmeter(i);
                }
            }
            if (!replayer.cur_isPlaying && !activity) {
                for (i = 0; i < replayer.info_channels; i++ ) {
                    clear_VUmeter(i);
                    stage.frameRate = sleep_framerate;
                }
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            }
            if (replayer.cur_isPlaying) {
                VU_index++;
                if (VU_index>=VU_delay) {
                    VU_index = 0;
                }
            }
        }
        
        private function clear_VUmeter(index:uint):void {
                VU_rectangles[index].scaleX = 1;
        }
        
        private function reset_trackbar():void{
            _trackBar.x = 0;
        }
        
        
        
        
        
        public function VU_buffered(index:uint):uint {
            VU_ringbuffers[index][(VU_index + VU_delay - 1) % VU_delay] = VU_instant[index];
            if (replayer.cur_isPlaying) {
                return VU_ringbuffers[index][(VU_index + VU_delay) % VU_delay];
            }else{
                return VU_instant[index];
            }
        }


        
        
        
        
        
        
        
        private function draw_bckg_gradient():void {
            var matr:Matrix = new Matrix();
            matr.createGradientBox( 1, 125, 1.57079633, 0, -25 );
            var sprite:Sprite = new Sprite();
            var g:Graphics = sprite.graphics;
            g.beginGradientFill( GradientType.LINEAR, [ col_peachGradientTop, col_lightLimeGradientBottom ], [ 1, 1 ], [ 0, 255 ], matr, SpreadMethod.PAD );
            g.drawRect( 0, 0, stage.stageWidth , stage.stageHeight );
            
            this.addChild( sprite );
        }
        
        private function draw_trackbar(x:int, y:int, seek_length:uint):void {
            bar_length = seek_length;
            _trackBar = new Sprite();
            _trackBar.graphics.beginFill(col_redPostTitle);
            _trackBar.graphics.drawRect(x, y, 10, 20);
            _trackBar.graphics.endFill();

            var backline:Sprite = new Sprite();
            backline.graphics.lineStyle(2, col_redBrownText);
            backline.graphics.moveTo(x,  y + 10);
            backline.graphics.lineTo(x + bar_length, y + 10);
            
            this.addChild(backline);
            this.addChild(_trackBar);
            _trackBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            _trackBar.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        
        private function draw_VUmeters(x:int, y:int):void {
            var i:uint, j:uint;
            if (VU_rectangles) {
                for (j = 0; j < VU_rectangles.length; j++ ) {
                    this.removeChild(VU_rectangles[j]);
                }
            }
            VU_rectangles = new Vector.<Sprite>();
            for (i = 0;i<replayer.info_channels; i++ ) {
                var VU:Sprite = new Sprite();
                VU.graphics.beginFill(col_peachHeader);
                VU.graphics.drawRect(x, y+20*i, 5, 15);
                VU.graphics.endFill();
                VU_rectangles.push(VU);
                this.addChild(VU);
                
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
            //draw_buttan( x+70*2 , y    , "TEST"  , test );
            
            draw_buttan( x      , y+30 , "PLAY"  , play );
            draw_buttan( x+70   , y+30 , "PAUSE" , pause );
            draw_buttan( x+70*2 , y+30 , "SOTP"  , stop );
        }
        private function test( event:MouseEvent ):void {
            replayer.com_seek(50);
        }
        
        private function draw_buttan( x:int, y:int, label:String, func:Function ):void{
            var button:Sprite = new Sprite();
            button.graphics.beginFill(col_grayButton);
            button.graphics.drawRect(x, y, 50, 20);
            button.graphics.endFill();
            button.useHandCursor = true;
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
        
        
        
        
        
        
        
        
        private function onMouseUp(e:MouseEvent):void {
            isDragged_trackBar = false;
            _trackBar.stopDrag();
            replayer.com_seek(replayer.info_tuneLength * (_trackBar.x  / bar_length));
        }

        private function onMouseDown(e:MouseEvent):void {
            isDragged_trackBar = true;
            _trackBar.startDrag(false, new Rectangle(0, 0, bar_length, 0));
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
            update_trackbar();
        }
        
        
        
        
        
        
        private function browse( event:MouseEvent ):void {
            fr.browse([ff]);
        }
        
        private function play( event:MouseEvent ):void {
            stage.frameRate = def_framerate;
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            replayer.com_play();
        }
        
        private function stop( event:MouseEvent ):void {
            reset_trackbar();
            replayer.com_stop();
        }
        
        private function pause( event:MouseEvent ):void {
            replayer.com_pause();
        }
        
        private function subsong( event:MouseEvent ):void {
            if(replayer.info_subsongNr){
                replayer.com_initSubsong(++subnr % (replayer.info_subsongNr + 1));
                update_subsong();
                update_totaltime();
            }
        }
        
        private function toggle_VUmeters( event:MouseEvent ):void {
            VU_shown = !VU_shown;
        }
        
        
        
        private function load( data:ByteArray ):void {
            reset_trackbar();
            subnr = 0;
            replayer.com_loadTune( data, taipan );
            VU_ringbuffers = null;
            draw_VUmeters(0, 200);
            update_all();
        }
    }
}