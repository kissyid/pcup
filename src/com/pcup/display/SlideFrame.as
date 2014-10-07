package com.pcup.display
{
    import com.pcup.fw.events.DataEvent;
    import com.pcup.utils.FileUtil;
    import com.pcup.utils.QueueLoader;
    
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    /**
     * initialize complete (loaded frames)
     */
    [Event(name="completea" type="flash.events.Event")]
    
    /**
     * 
     * @author pihao
     * @createTime Sep 16, 2014 10:36:07 PM
     */
    public class SlideFrame extends Sprite
    {
        public var framesPerPixel:int;
        protected var mc:SimpleMovieClip;
        
        private var frames:Vector.<Bitmap>;
        
        private var processBar:ProgressBar;
        private var startX:Number;
        
        /**
         * @param dirURL
         * @param fpp frame per pixel
         */
        public function SlideFrame(dirURL:String, fpp:int = 2)
        {
            super();
            this.framesPerPixel = Math.max(fpp, 1);
            
            var urls:Array = FileUtil.getImageURLsInDirectorys([dirURL]);
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
                
                processBar = new ProgressBar();
                processBar.setCenterByObject(frame);
                addChild(processBar);
            }
            
            addChildAt(frame, 0);
            frames.push(frame);
            processBar.ratio = e.data.ratio;
        }
        
        protected function onAllFramesLoaded(e:DataEvent):void
        {
            var l:QueueLoader = e.target as QueueLoader;
            l.removeEventListener(DataEvent.COMPLETE_ONE, onOneFramesLoaded);
            l.removeEventListener(Event.COMPLETE, onAllFramesLoaded);
            
            removeChild(processBar);
            mc = new SimpleMovieClip(frames);
            addChildAt(mc, 0);
            mc.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            this.dispatchEvent(new DataEvent(Event.COMPLETE));
        }
        
        private function onDown(e:MouseEvent):void
        {
            this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            this.addEventListener(MouseEvent.MOUSE_UP, onUp);
            this.addEventListener(MouseEvent.MOUSE_OUT, onUp);
            
            startX = e.stageX;
        }
        
        protected function onMouseMove(e:MouseEvent):void
        {
            mc.currentFrame = ((int(startX - e.stageX) / framesPerPixel % mc.totalFrame) + mc.totalFrame) % mc.totalFrame;
            dispatchEvent(new DataEvent(Event.CHANGE));
        }
        
        private function onUp(e:MouseEvent):void
        {
            this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            this.removeEventListener(MouseEvent.MOUSE_UP, onUp);
            this.removeEventListener(MouseEvent.MOUSE_OUT, onUp);
        }
        
        public function dispose():void
        {
            if (mc)
            {
                mc.dispose();
                mc = null;
            }
        }
        
        public function reset():void
        {
            mc.currentFrame = 1;
            dispatchEvent(new DataEvent(Event.CHANGE));
        }
        
        public function get isReset():Boolean
        {
            return mc.currentFrame == 1;
        }
        
        
        
    }
}