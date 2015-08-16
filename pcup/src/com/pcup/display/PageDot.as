package com.pcup.display 
{
    import com.pcup.framework.hack.Sprite;
    
    import flash.display.Shape;
    
    /**
     * Apple 翻页点
     * @author pihao
     */
    public class PageDot extends Sprite 
    {
        private var r:uint;
        private var g:Number;
        private var c:uint;
        private var dots:Vector.<Shape>;

        public function PageDot(radius:uint = 3, gap:Number = 1.0, color:uint = 0xFFFFFF) 
        {
            this.r = radius;
            this.g = gap + 1;
            this.c = color;
        }
        
        public function setNum(num:uint):void
        {
            while (numChildren > 0) removeChildAt(0);
            dots = new Vector.<Shape>;
            for (var i:int = 0; i < num; i++) 
            {
                var s:Shape = new Shape();
                s.graphics.beginFill(c);
                s.graphics.drawCircle(r, r, r);
                s.graphics.endFill();
                s.x = i * (s.width * g);
                addChild(s);
                dots.push(s);
            }
        }
        
        public function active(index:uint):void
        {
            for (var i:int in dots) 
            {
                dots[i].alpha = (i == index ? .9 : .3);
            }
        }
        
    }
}