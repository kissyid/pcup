package com.pcup.display
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    
    /**
     * @author pihao
     * @createTime Sep 16, 2014 10:15:23 PM
     */
    public class SimpleMovieClip extends Bitmap
    {
        public var loop:Boolean = true;
        
        private var _currentFrame:int = -1;
        private var frames:Vector.<BitmapData> = null;
        
        public function SimpleMovieClip(frames:Vector.<BitmapData> = null, loop:Boolean = true)
        {
            super();
            this.frames = frames ? frames : new Vector.<BitmapData>;
            this.loop = loop;
            
            currentFrame = 0;
        }
        
        public function addFrame(frame:BitmapData):void
        {
            frames.push(frame);
            if (currentFrame == -1) currentFrame = 0;
        }
        
        public function prevFrame():void
        {
            if (currentFrame - 1 >= 0) currentFrame--;
            else if (loop) currentFrame = totalFrame - 1;
        }
        public function nextFrame():void
        {
            if (currentFrame + 1 <= totalFrame - 1) currentFrame++;
            else if (loop) currentFrame = 0;
        }

        public function get currentFrame():int
        {
            return _currentFrame;
        }
        public function set currentFrame(value:int):void
        {
            if (value < 0 || value > totalFrame - 1 || value == currentFrame) return;
            _currentFrame = value;
            
            bitmapData = frames[currentFrame];
        }

        public function get totalFrame():int
        {
            return frames.length;
        }
        
        public function dispose():void
        {
            while (frames.length > 0) frames.pop().dispose();
            frames = null;
        }
        
    }
}