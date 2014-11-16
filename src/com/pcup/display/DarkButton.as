package com.pcup.display
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    
    
    /**
     * @author pihao
     * @createTime Nov 3, 2014 11:29:54 AM
     */
    public class DarkButton extends Sprite
    {
        private var dark:Bitmap;
        public function DarkButton()
        {
            super();
            
            dark = new Bitmap(new BitmapData(1, 1));
            super.addChild(dark);
            
            mouseChildren = false;
            addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
        
        override protected function afterChildrenUpdated():void
        {
            super.afterChildrenUpdated();
            updateDark();
        }
        
        public function updateDark():void
        {
            disposeDark();
            var bmd:BitmapData = new BitmapData(this.width, this.height, true, 0);
            bmd.draw(this, null, new ColorTransform(0, 0, 0, .3));
            dark.bitmapData = bmd;
            dark.smoothing = true;
            dark.width = this.width / this.scaleX;
            dark.height = this.height / this.scaleY;
            dark.visible = false;
            this.setChildIndex(dark, numChildren - 1);
        }
        
        private function onDown(e:MouseEvent):void
        {
            addEventListener(MouseEvent.MOUSE_UP, onUp);
            addEventListener(MouseEvent.ROLL_OUT, onUp);
            dark.visible = true;
        }
        
        private function onUp(e:MouseEvent):void
        {
            removeEventListener(MouseEvent.MOUSE_UP, onUp);
            removeEventListener(MouseEvent.ROLL_OUT, onUp);
            dark.visible = false;
        }
        
        
        private function disposeDark():void
        {
            if (dark) dark.bitmapData.dispose();
        }
        override public function dispose():void
        {
            super.dispose();
            removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
            removeEventListener(MouseEvent.MOUSE_UP, onUp);
            removeEventListener(MouseEvent.ROLL_OUT, onUp);
            disposeDark();
        }
        
    }
}
