package com.pcup.display
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.DisplayObject;
    
    
    /**
     * @author phx
     * @createTime Oct 12, 2014 3:57:35 AM
     */
    public class FaceOff extends Sprite
    {
        private var obj0:DisplayObject;
        private var obj1:DisplayObject;

        public function FaceOff(displayObj0:DisplayObject, displayObj1:DisplayObject, name:String = null)
        {
            super();
            if (!displayObj0 || !displayObj1)
            {
                throw new Error("Parameters can't be null.");
            }
            
            obj0 = displayObj0;
            obj1 = displayObj1;
            if (name) this.name = name;
            
            mouseChildren = false;
            
            obj1.visible = false;
            addChild(obj0);
            addChild(obj1);
        }
        
        private var _status:Boolean;
        public function get active():Boolean
        {
            return _status;
        }
        public function set active(value:Boolean):void
        {
            _status = value;
            obj0.visible = !value;
            obj1.visible = value;
            
            if (parent is DarkButton) (parent as DarkButton).updateDark();
        }

    }
}