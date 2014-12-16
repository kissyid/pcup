package com.pcup.display
{
    import com.pcup.framework.events.DataEvent;
    import com.pcup.framework.hack.Sprite;
    import com.pcup.utils.FileUtil;
    import com.pcup.utils.NumberUtil;
    import com.pcup.utils.QueueLoader;
    
    import flash.display.Bitmap;
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
        private var _abLoop:Array = null;
        private var _slideEnable:Boolean = true;
        private var _reversePlay:Boolean = false;
        private var _totalFrame:int = -1;
        
        private var loader:QueueLoader;
        protected var mc:SimpleMovieClip;
        private var progressBar:ProgressBar;
        private var autoPlay:Boolean;
        
        private var startF:int;
        private var startX:Number;
        private var counter:int;
        private var a:int = -1;
        private var b:int = -1;

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
         */
        public function init(dirURL:String, autoPlay:Boolean = false):void
        {
            if (mc) return;
            
            this.autoPlay = autoPlay;
            
            var urls:Array = FileUtil.getImageURLsInDirectorys([dirURL]);
            if (urls.length == 0)
            {
                this.dispatchEvent(new DataEvent(DataEvent.INIT_COMPLETE));
                return;
            }
            
            loader = new QueueLoader();
            addLoaderListener(loader);
            loader.load(urls);
        }
        private function onOneFramesLoaded(e:DataEvent):void
        {
            var frame:Bitmap = e.data.content as Bitmap;
            
            // loaded first frame
            if (!mc)
            {
                mc = new SimpleMovieClip();
                addChild(mc);
                slideEnable = slideEnable; // check
                if (autoPlay) play();
                
                if (progressBarEnable)
                {
                    progressBar = new ProgressBar();
                    progressBar.setCenterByObject(frame);
                    addChild(progressBar);
                }
                
                mc.addFrame(frame.bitmapData);
                dispatchChangeEvent();
            }
            else mc.addFrame(frame.bitmapData);
            
            if (progressBar) progressBar.ratio = e.data.ratio;
        }
        protected function onAllFramesLoaded(e:DataEvent):void
        {
            removeLoaderListener(loader);
            if (progressBar) removeChild(progressBar);
            _totalFrame = totalFrame;
            
            this.dispatchEvent(new DataEvent(DataEvent.INIT_COMPLETE));
        }
        
        
        protected function onDown(e:MouseEvent):void
        {
            this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            this.addEventListener(MouseEvent.MOUSE_UP, onUp);
            this.addEventListener(MouseEvent.MOUSE_OUT, onUp);
            
            startF = currentFrame;
            startX = e.stageX;
        }
        protected function onMouseMove(e:MouseEvent):void
        {
            gotoFrame(Math.floor(startF + (e.stageX - startX) / ppf));
        }
        protected function onUp(e:MouseEvent):void
        {
            this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            this.removeEventListener(MouseEvent.MOUSE_UP, onUp);
            this.removeEventListener(MouseEvent.MOUSE_OUT, onUp);
        }
        
        
        public function play(reversePlay:Boolean = false):void
        {
            this.reversePlay = reversePlay;
            if (!hasEventListener(Event.ENTER_FRAME))
            {
                counter = 0;
                addEventListener(Event.ENTER_FRAME, onFrame);
            }
        }
        public function stop():void
        {
            removeEventListener(Event.ENTER_FRAME, onFrame);
        }
        private function onFrame(e:Event):void
        {
            if (counter % fpf == 0)
            {
                gotoFrame(currentFrame + (reversePlay ? -1 : 1));
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
            
            if (target == currentFrame) return;
            
            if (abLoop && hasEventListener(Event.ENTER_FRAME))
            {
                if (target == b) { gotoFrame(a); return }
                if (target == a) dispatchEvent(new DataEvent(DataEvent.LOOP));
            }
            
            mc.currentFrame = target;
            dispatchChangeEvent();
            
            if (currentFrame == totalFrame - 1 && initComplete)
            {
                if (!loop && hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, onFrame);
                dispatchEvent(new DataEvent(DataEvent.OVER));
            }
        }
        
        private function dispatchChangeEvent():void
        {
            dispatchEvent(new DataEvent(DataEvent.CHANGE, currentFrame));
        }
        
        private function formatABLoop():void
        {
            if (abLoop)
            {
                if (Number(abLoop[0]) == abLoop[0] &&
                    Number(abLoop[1]) == abLoop[1])
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
            if (initComplete && loop)
                return (frame % totalFrame + totalFrame) % totalFrame;
            else
                return NumberUtil.closest(frame, 0, totalFrame - 1);
        }
        
        private function addLoaderListener(l:QueueLoader):void
        {
            l.addEventListener(DataEvent.COMPLETE_ONE, onOneFramesLoaded);
            l.addEventListener(DataEvent.COMPLETE, onAllFramesLoaded);
        }
        private function removeLoaderListener(l:QueueLoader):void
        {
            l.removeEventListener(DataEvent.COMPLETE_ONE, onOneFramesLoaded);
            l.removeEventListener(DataEvent.COMPLETE, onAllFramesLoaded);
        }
        
        override public function dispose():void
        {
            super.dispose();
            removeEventListener(Event.ENTER_FRAME, onFrame);
            if (loader)
            {
                removeLoaderListener(loader);
                loader.dispose();
                loader = null;
            }
            if (mc)
            {
                removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
                mc.dispose();
                mc = null;
            }
        }
        
        
        private function get initComplete():Boolean
        {
            return _totalFrame != -1;
        }
        
        public function get isReset():Boolean
        {
            return currentFrame == 1;
        }

        public function get totalFrame():int
        {
            return _totalFrame == -1 ? mc.totalFrame : _totalFrame;
        }
        
        public function get currentFrame():int
        {
            return mc.currentFrame;
        }
        public function set currentFrame(value:int):void
        {
            return gotoFrame(value);
        }

        public function get slideEnable():Boolean
        {
            return _slideEnable;
        }
        public function set slideEnable(value:Boolean):void
        {
            _slideEnable = value;
            if (mc)
            {
                if (slideEnable) addEventListener(MouseEvent.MOUSE_DOWN, onDown);
                else          removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
            }
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

        /** loop between A and B (Only available for play) */
        public function get abLoop():Array
        {
            return _abLoop;
        }
        public function set abLoop(value:Array):void
        {
            _abLoop = value;
            formatABLoop();
        }

        
    }
}