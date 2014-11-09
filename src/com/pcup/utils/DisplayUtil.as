package com.pcup.utils
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;

    public class DisplayUtil
    {
        /**
         * @param color RGB
         */
        static public function createShape(x:int = 0, y:int = 0, w:uint = 10, h:uint = 10, color:uint = 0xFFFFFF, alpha:Number = 1.0):Shape
        {
            var s:Shape = new Shape();
            s.graphics.beginFill(color);
            s.graphics.drawRect(0, 0, w, h);
            s.graphics.endFill();
            s.alpha = alpha;
            s.x = x;
            s.y = y;
            return s;
        }
        
        /**
         * @param color RGB
         */
        static public function createSprite(x:int = 0, y:int = 0, w:uint = 10, h:uint = 10, color:uint = 0xFFFFFF, alpha:Number = 1.0):Sprite
        {
            var s:Sprite = new Sprite();
            s.graphics.beginFill(color);
            s.graphics.drawRect(0, 0, w, h);
            s.graphics.endFill();
            s.alpha = alpha;
            s.x = x;
            s.y = y;
            return s;
        }
        
        /**
         * @param color ARGB
         */
        static public function createBitmap(x:int = 0, y:int = 0, color:uint = 0xFFFFFFFF, w:uint = 1, h:uint = 1):Bitmap
        {
            var b:Bitmap = new Bitmap(new BitmapData(w, h, false, color));
            b.x = x;
            b.y = y;
            return b;
        }
        
    }
}