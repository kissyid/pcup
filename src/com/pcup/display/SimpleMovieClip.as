package com.pcup.display
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    
    /**
     * 
     * @author pihao
     * @createTime Sep 16, 2014 10:15:23 PM
     */
    public class SimpleMovieClip extends Sprite
    {
        public var loop:Boolean = true;
        
        private var _currentFrame:int = -1;
        private var frames:Vector.<Bitmap> = null;
        
        public function SimpleMovieClip(frames:Vector.<Bitmap>, loop:Boolean = true)
        {
            super();
            this.frames = frames;
            this.loop = loop;
            
            for each (var bmp:Bitmap in frames) 
            {
                bmp.visible = false;
                bmp.x = bmp.y = 0;
                addChild(bmp);
            }
            currentFrame = 0;
        }
        
        public function prevFrame():void
        {
            if (currentFrame - 1 >= 0) currentFrame--;
            else if (currentFrame - 1 < 0 && loop) currentFrame = totalFrame - 1;
        }
        
        public function nextFrame():void
        {
            if (currentFrame + 1 <= totalFrame - 1) currentFrame++;
            else if (currentFrame + 1 > totalFrame - 1 && loop) currentFrame = 0;
        }

        public function get currentFrame():int
        {
            return _currentFrame;
        }
        public function set currentFrame(value:int):void
        {
            if (value < 0 || value > totalFrame - 1 || value == _currentFrame) return;
            _currentFrame = value;
            for (var i:int in frames) 
                frames[i].visible = i == _currentFrame;
        }

        public function get totalFrame():int
        {
            return frames.length;
        }
        
        public function dispose():void
        {
            while (frames.length > 0) frames.pop().bitmapData.dispose();
            frames = null;
        }
        
        
    }
}