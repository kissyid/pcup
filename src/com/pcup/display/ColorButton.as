package com.pcup.display
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.MouseEvent;
    
    
    /**
     * @author phx
     * @createTime Sep 27, 2014 9:39:19 PM
     */
    public class ColorButton extends Sprite
    {
        private var bitmap:Bitmap;

        /**
         * @param w
         * @param h
         * @param color 0xRGB
         */
        public function ColorButton(w:uint = 0, h:uint = 0, color:uint = 0xFFFFFF)
        {
            super();
            
            mouseChildren = false;
            
            bitmap = new Bitmap(new BitmapData(1, 1, true, color & 0xFFFFFF | 0xFF000000));
            bitmap.width = w;
            bitmap.height = h;
            bitmap.alpha = .7;
            addChild(bitmap);
            
            addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
        
        private function onDown(e:MouseEvent):void
        {
            addEventListener(MouseEvent.MOUSE_UP, onUp);
            addEventListener(MouseEvent.ROLL_OUT, onUp);
            bitmap.alpha = .9;
        }
        
        private function onUp(e:MouseEvent):void
        {
            removeEventListener(MouseEvent.MOUSE_UP, onUp);
            removeEventListener(MouseEvent.ROLL_OUT, onUp);
            bitmap.alpha = .7;
        }
        
        override public function dispose():void
        {
            super.dispose();
            removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
            bitmap.bitmapData.dispose();
        }
        
    }
}