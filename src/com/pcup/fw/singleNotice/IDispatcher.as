package com.pcup.fw.singleNotice
{
    public interface IDispatcher
    {
        function addListener(type:String, listener:Function):void
        
        function removeListener(type:String, listener:Function):void
        
        function sendEvent(type:String, data:Object = null):void
    }
}