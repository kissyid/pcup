package com.pcup.display
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    
    /**
     * 
     * @author phx
     * @createTime Sep 27, 2014 9:39:19 PM
     */
    public class Button extends Sprite
    {
        private var cover:Shape;
        private var lightMode:Boolean;

        public function Button(w:int = 0, h:int = 0)
        {
            super();
            
            lightMode = w <= 0 || h <= 0;
            
            cover = new Shape();
            cover.graphics.beginFill(0xff0000, .3);
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
        
        public function removeFromParent(dispose:Boolean = false):void
        {
            if (parent) parent.removeChild(this);
            if (dispose) this.dispose();
        }
        
        public function dispose():void
        {
            removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
    }
}