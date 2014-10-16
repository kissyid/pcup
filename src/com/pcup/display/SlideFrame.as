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
    [Event(name="complete" type="flash.events.Event")]
    /** play over */
    [Event(name="over" type="flash.events.Event")]
    
    /**
     * @author pihao
     * @createTime Sep 16, 2014 10:36:07 PM
     */
    public class SlideFrame extends Sprite
    {
        public var ppf:int = 1;
        public var fpf:int = 1;
        private var _slideEnable:Boolean = true;
        public var progressBarEnable:Boolean = true;
        public var loop:Boolean = true;
        public var reversePlay:Boolean = false;
        
        protected var mc:SimpleMovieClip;
        private var frames:Vector.<Bitmap>;
        private var progressBar:ProgressBar;
        private var playAfterInitComplete:Boolean;
        
        private var startF:int;
        private var startX:Number;
        private var totalFrame:int;
        private var counter:int;

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
                this.dispatchEvent(new DataEvent(Event.COMPLETE));
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
            
            if (!frames)
            {
                frames = new Vector.<Bitmap>;
                
                if (progressBarEnable)
                {
                    progressBar = new ProgressBar();
                    progressBar.setCenterByObject(frame);
                    addChild(progressBar);
                }
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
            
            if (progressBar) removeChild(progressBar);
            mc = new SimpleMovieClip(frames);
            addChildAt(mc, 0);
            totalFrame = mc.totalFrame;
            
            if (playAfterInitComplete) play();
            if (slideEnable) mc.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            
            this.dispatchEvent(new DataEvent(Event.COMPLETE));
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
            mc.currentFrame = target;
            dispatchEvent(new DataEvent(Event.CHANGE));
            
            if (mc.currentFrame == totalFrame - 1)
            {
                if (!loop && hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, onFrame);
                dispatchEvent(new DataEvent(DataEvent.OVER));
            }
        }
        
        private function formatFrame(frame:int):int
        {
            return loop ? (frame % totalFrame + totalFrame) % totalFrame : NumberUtil.almost(frame, 0, totalFrame - 1);
        }
        
        public function dispose():void
        {
            mc.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
            removeEventListener(Event.ENTER_FRAME, onFrame);
            if (mc)
            {
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

        
    }
}