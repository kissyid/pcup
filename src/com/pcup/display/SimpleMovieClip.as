package com.pcup.display
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.Bitmap;
    
    /**
     * @author pihao
     * @createTime Sep 16, 2014 10:15:23 PM
     */
    public class SimpleMovieClip extends Sprite
    {
        public var loop:Boolean = true;
        
        private var _currentFrame:int = -1;
        private var frames:Vector.<Bitmap> = null;
        
        public function SimpleMovieClip(frames:Vector.<Bitmap> = null, loop:Boolean = true)
        {
            super();
            this.frames = frames ? frames : new Vector.<Bitmap>;
            this.loop = loop;
            
            for each (var frame:Bitmap in frames) formatFrame(frame);
            currentFrame = 0;
        }
        
        private function formatFrame(frame:Bitmap):Bitmap
        {
            frame.visible = false;
            frame.x = frame.y = 0;
            addChild(frame);
            return frame;
        }
        
        public function addFrame(frame:Bitmap):void
        {
            frames.push(formatFrame(frame));
            if (currentFrame == -1) currentFrame = 0;
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
            if (value < 0 || value > totalFrame - 1 || value == currentFrame) return;
            _currentFrame = value;
            for (var i:int in frames) 
                frames[i].visible = i == currentFrame;
        }

        public function get totalFrame():int
        {
            return frames.length;
        }
        
        override public function dispose():void
        {
            super.dispose();
            while (frames.length > 0) frames.pop().bitmapData.dispose();
            frames = null;
        }
        
        
    }
}