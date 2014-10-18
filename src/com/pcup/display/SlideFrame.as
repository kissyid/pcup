package com.pcup.display
{
    import com.pcup.fw.events.DataEvent;
    import com.pcup.utils.FileUtil;
    import com.pcup.utils.NumberUtil;
    import com.pcup.utils.QueueLoader;
    
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    /** initialize complete (loaded frames) */
    [Event(name="init_complete" type="com.pcup.fw.events.DataEvent")]
    /** frame change */
    [Event(name="change" type="com.pcup.fw.events.DataEvent")]
    /** play over */
    [Event(name="over" type="com.pcup.fw.events.DataEvent")]
    /** A-B loop start */
    [Event(name="loop" type="com.pcup.fw.events.DataEvent")]
    
    /**
     * @author pihao
     * @createTime Sep 16, 2014 10:36:07 PM
     */
    public class SlideFrame extends Sprite
    {
        public var ppf:int = 1;
        public var fpf:int = 1;
        public var progressBarEnable:Boolean = true;
        public var loop:Boolean = true;
        private var _slideEnable:Boolean = true;
        private var _reversePlay:Boolean = false;
        private var _abLoop:Array = null;
        private var _totalFrame:int = 0;
        
        protected var mc:SimpleMovieClip;
        private var frames:Vector.<Bitmap>;
        private var progressBar:ProgressBar;
        private var playAfterInitComplete:Boolean;
        
        private var startF:int;
        private var startX:Number;
        private var counter:int;
        private var a:int;
        private var b:int;

        /**
         * ppf & fpf, the smaller the faster.
         * @param ppf pixels per frame
         * @param fpf enter-frame per frame
         */
        public function SlideFrame(ppf:int = 2, fpf:int = 1)
        {
            super();
            this.ppf = Math.max(ppf, this.ppf);
            this.fpf = Math.max(fpf, this.fpf);
        }
        
        /**
         * init(load images)
         * @param dirURL
         */
        public function init(dirURL:String, playAfterInitComplete:Boolean = false):void
        {
            if (mc) return;
            
            this.playAfterInitComplete = playAfterInitComplete;
            
            var urls:Array = FileUtil.getImageURLsInDirectorys([dirURL]);
            if (urls.length == 0)
            {
                this.dispatchEvent(new DataEvent(DataEvent.INIT_COMPLETE));
                return;
            }
            
            var l:QueueLoader = new QueueLoader();
            l.addEventListener(DataEvent.COMPLETE_ONE, onOneFramesLoaded);
            l.addEventListener(Event.COMPLETE, onAllFramesLoaded);
            l.load(urls);
        }
        
        private function onOneFramesLoaded(e:DataEvent):void
        {
            var frame:Bitmap = e.data.content as Bitmap;
            
            if (!frames) // first frame
            {
                frames = new Vector.<Bitmap>;
                
                if (progressBarEnable)
                {
                    progressBar = new ProgressBar();
                    progressBar.setCenterByObject(frame);
                    addChild(progressBar);
                }
            }
            else
            {
                frame.x = -frame.width;
                frame.y = -frame.height;
            }
            
            addChildAt(frame, 0);
            frames.push(frame);
            if (progressBar) progressBar.ratio = e.data.ratio;
        }
        
        protected function onAllFramesLoaded(e:DataEvent):void
        {
            var l:QueueLoader = e.target as QueueLoader;
            l.removeEventListener(DataEvent.COMPLETE_ONE, onOneFramesLoaded);
            l.removeEventListener(Event.COMPLETE, onAllFramesLoaded);
            l.removeEventListener(Event.COMPLETE, onAllFramesLoaded);
            
            if (progressBar) removeChild(progressBar);
            mc = new SimpleMovieClip(frames);
            addChildAt(mc, 0);
            
            _totalFrame = mc.totalFrame;
            formatABLoop();
            
            if (playAfterInitComplete) play();
            if (slideEnable) mc.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            
            this.dispatchEvent(new DataEvent(DataEvent.INIT_COMPLETE));
        }
        
        
        private function onDown(e:MouseEvent):void
        {
            this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            this.addEventListener(MouseEvent.MOUSE_UP, onUp);
            this.addEventListener(MouseEvent.MOUSE_OUT, onUp);
            
            startF = mc.currentFrame;
            startX = e.stageX;
        }
        
        protected function onMouseMove(e:MouseEvent):void
        {
            gotoFrame(Math.floor(startF + (e.stageX - startX) / ppf));
        }
        
        private function onUp(e:MouseEvent):void
        {
            this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            this.removeEventListener(MouseEvent.MOUSE_UP, onUp);
            this.removeEventListener(MouseEvent.MOUSE_OUT, onUp);
        }
        
        
        public function play():void
        {
            counter = 0;
            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        public function stop():void
        {
            removeEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        private function onFrame(e:Event):void
        {
            if (counter % fpf == 0)
            {
                gotoFrame(mc.currentFrame + (reversePlay ? -1 : 1));
            }
            counter++;
        }
        
        
        public function reset():void
        {
            gotoFrame(1);
        }
        
        private function gotoFrame(frame:int):void
        {
            var target:int = formatFrame(frame);
            
            if (target == mc.currentFrame) return;
            
            if (abLoop && hasEventListener(Event.ENTER_FRAME))
            {
                if (target == b) target = a;
                if (target == a) dispatchEvent(new DataEvent(DataEvent.LOOP));
            }
            
            mc.currentFrame = target;
            dispatchEvent(new DataEvent(DataEvent.CHANGE, mc.currentFrame));
            
            if (mc.currentFrame == totalFrame - 1)
            {
                if (!loop && hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, onFrame);
                dispatchEvent(new DataEvent(DataEvent.OVER));
            }
        }
        
        private function formatABLoop():void
        {
            if (abLoop)
            {
                if (Number(abLoop[0]) == abLoop[0] &&
                    Number(abLoop[1]) == abLoop[1] &&
                    NumberUtil.isBetween(abLoop[0], 0, totalFrame - 1) &&
                    NumberUtil.isBetween(abLoop[1], 0, totalFrame - 1))
                {
                    a = reversePlay ? abLoop[1] : abLoop[0];
                    b = reversePlay ? abLoop[0] : abLoop[1];
                }
                else
                {
                    abLoop = null;
                    trace("SlideFrame::abLoop::argument invalid.");
                }
            }
        }
        
        private function formatFrame(frame:int):int
        {
            return loop ? (frame % totalFrame + totalFrame) % totalFrame : NumberUtil.closest(frame, 0, totalFrame - 1);
        }
        
        public function dispose():void
        {
            removeEventListener(Event.ENTER_FRAME, onFrame);
            if (mc)
            {
                mc.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
                mc.dispose();
                mc = null;
            }
        }
        
        
        public function get isReset():Boolean
        {
            return mc.currentFrame == 1;
        }

        public function get slideEnable():Boolean
        {
            return _slideEnable;
        }
        public function set slideEnable(value:Boolean):void
        {
            _slideEnable = value;
            if (slideEnable) mc.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            else          mc.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }

        /** loop between A and B (Only available for play) */
        public function get abLoop():Array
        {
            return _abLoop;
        }
        public function set abLoop(value:Array):void
        {
            if (value) _abLoop = value;
            else trace("SlideFrame::abLoop::argument is null.");
        }

        public function get totalFrame():int
        {
            return _totalFrame;
        }
        
        public function get currentFrame():int
        {
            return mc.currentFrame;
        }
        public function set currentFrame(value:int):void
        {
            return gotoFrame(value);
        }

        public function get reversePlay():Boolean
        {
            return _reversePlay;
        }
        public function set reversePlay(value:Boolean):void
        {
            if (reversePlay == value) return;
            _reversePlay = value;
            formatABLoop();
        }

        
    }
}