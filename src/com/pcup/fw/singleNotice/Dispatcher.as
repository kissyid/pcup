package com.pcup.fw.singleNotice
{
    
    /**
     * 
     * @author phx
     * @createTime Sep 25, 2014 1:50:17 AM
     */
    public class Dispatcher implements IDispatcher
    {
        public function addListener(type:String, listener:Function):void
        {
            Notifier.ins.addListener(type, listener);
        }
        
        public function removeListener(type:String, listener:Function):void
        {
            Notifier.ins.removeListener(type, listener);
        }
        
        public function sendEvent(type:String, data:Object = null):void
        {
            Notifier.ins.sendEvent(type, data);
        }
    }
}