package com.pcup.framework.hack
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    
    /**
     * 
     * @author phx
     * @createTime Oct 19, 2014 3:24:56 AM
     */
    public class Sprite extends flash.display.Sprite
    {
        public function Sprite()
        {
            super();
        }
        
        
        public function removeFromParent(dispose:Boolean = false):void
        {
            if (parent) parent.removeChild(this);
            if (dispose) this.dispose();
        }
        
        
        // AUTO REOMVE LISTENER --------------------------------------------- begin
        
        override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
        {
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
            
            if (!listeners) listeners = [];
            for each (var o:Object in listeners)
            if (o.type == type && o.listener == listener && o.useCapture == useCapture)
                return;
            listeners.push({type:type, listener:listener, useCapture:useCapture});
        }
        override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
            super.removeEventListener(type, listener, useCapture);
            
            for each (var o:Object in listeners)
            if (o.type == type && o.listener == listener && o.useCapture == useCapture)
            {
                listeners.splice(listeners.indexOf(o), 1);
                break;
            }
        }
        public function removeEventListeners():void
        {
            if (listeners)
            {
                while (listeners.length > 0)
                {
                    var o:Object = listeners.pop();
                    this.removeEventListener(o.type, o.listener, o.useCapture);
                }
                listeners = null;
            }
        }
        private var listeners:Array = null;
        
        public function dispose():void
        {
            removeEventListeners();
        }
        
        // AUTO REOMVE LISTENER --------------------------------------------- end
        
        
        // OVERRIDE CHILDREN ADD/REMOVE --------------------------------------------- start
        
        protected function beforeChildrenUpdated():void
        {
        }
        protected function afterChildrenUpdated():void
        {
        }
        override public function addChild(child:DisplayObject):DisplayObject {
            beforeChildrenUpdated();
            var obj:DisplayObject = super.addChild(child);
            afterChildrenUpdated();
            return obj;
        }
        override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
            beforeChildrenUpdated();
            var obj:DisplayObject = super.addChildAt(child, index);
            afterChildrenUpdated();
            return obj;
        }
        override public function getChildAt(index:int):DisplayObject {
            beforeChildrenUpdated();
            var obj:DisplayObject = super.getChildAt(index);
            afterChildrenUpdated();
            return obj;
        }
        override public function getChildByName(name:String):DisplayObject {
            beforeChildrenUpdated();
            var obj:DisplayObject = super.getChildByName(name);
            afterChildrenUpdated();
            return obj;
        }
        override public function getChildIndex(child:DisplayObject):int {
            beforeChildrenUpdated();
            var obj:int = super.getChildIndex(child);
            afterChildrenUpdated();
            return obj;
        }
        override public function removeChild(child:DisplayObject):DisplayObject {
            beforeChildrenUpdated();
            var obj:DisplayObject = super.removeChild(child);
            afterChildrenUpdated();
            return obj;
        }
        override public function removeChildAt(index:int):DisplayObject {
            beforeChildrenUpdated();
            var obj:DisplayObject = super.removeChildAt(index);
            afterChildrenUpdated();
            return obj;
        }
        override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
            beforeChildrenUpdated();
            super.removeChildren(beginIndex, endIndex);
            afterChildrenUpdated();
        }
        
        // OVERRIDE CHILDREN ADD/REMOVE --------------------------------------------- end
        
    }
}