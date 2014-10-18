package com.pcup.fw.hack
{
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
        
        
        public function removeFromParent(dispose:Boolean = false):void
        {
            if (parent) parent.removeChild(this);
            if (dispose) this.dispose();
        }
        
    }
}