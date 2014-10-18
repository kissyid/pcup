package com.pcup.display
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.DisplayObject;
    import flash.display.Shape;
    
    
    /**
     * @author phx
     * @createTime Sep 27, 2014 5:01:05 PM
     */
    public class ProgressBar extends Sprite
    {
        private var m:Shape;

        public function ProgressBar()
        {
            super();
            
            mouseEnabled = mouseChildren = false;
            
            var s:Shape = new Shape();
            s.graphics.beginFill(0xa0a0a0);
            s.graphics.drawRoundRect(0, 0, 200, 19, 19);
            s.graphics.endFill();
            addChild(s);
            
            s = new Shape();
            s.graphics.beginFill(0xffffff);
            s.graphics.drawRoundRect(0, 0, 192, 11, 11);
            s.graphics.endFill();
            s.x = s.y = 4;
            addChild(s);
            var bar:Shape = s;
            
            s = new Shape();
            s.graphics.beginFill(0);
            s.graphics.drawRect(0, 0, width, height);
            s.graphics.endFill();
            addChild(s);
            m = s;
            
            bar.mask = m;
            
            ratio = 0;
        }
        
        public function setCenterBySize(w:int, h:int):void
        {
            x = w - width >> 1;
            y = h - height >> 1;
        }
        
        public function setCenterByObject(refObj:DisplayObject):void
        {
            setCenterBySize(refObj.width, refObj.height);
        }
        
        private var _ratio:Number
        public function get ratio():Number
        {
            return _ratio;
        }
        public function set ratio(value:Number):void
        {
            if (value < 0) value = 0;
            else if (value > 1) value = 1;
            _ratio = value;
            
            m.scaleX = ratio;
        }

    }
}