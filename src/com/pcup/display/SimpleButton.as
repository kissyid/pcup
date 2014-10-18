package com.pcup.display
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.Shape;
    import flash.events.MouseEvent;
    
    
    /**
     * @author phx
     * @createTime Sep 27, 2014 9:39:19 PM
     */
    public class SimpleButton extends Sprite
    {
        public static var debug:Boolean
        private var cover:Shape;
        private var lightMode:Boolean;

        public function SimpleButton(w:int = 0, h:int = 0, color:uint = 0xFFFFFF)
        {
            super();
            
            mouseChildren = false;
            
            lightMode = w <= 0 || h <= 0;
            
            cover = new Shape();
            cover.graphics.beginFill(color, lightMode ? .2 : (debug ? .6 : 0));
            cover.graphics.drawRect(0, 0, Math.max(w, 1), Math.max(h, 1));
            cover.graphics.endFill();
            addChild(cover);
            if (lightMode)
            {
                cover.visible = false;
                addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            }
        }
        
        private function onDown(e:MouseEvent):void
        {
            addEventListener(MouseEvent.MOUSE_UP, onUp);
            addEventListener(MouseEvent.ROLL_OUT, onUp);
            cover.width = width;
            cover.height = height;
            cover.visible = true;
            addChild(cover);
        }
        
        private function onUp(e:MouseEvent):void
        {
            removeEventListener(MouseEvent.MOUSE_UP, onUp);
            removeEventListener(MouseEvent.ROLL_OUT, onUp);
            cover.visible = false;
        }
        
        override public function dispose():void
        {
            super.dispose();
            removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
        
    }
}