package com.pcup.framework.events
{
    import flash.events.Event;
    
    
    /**
     * @author ph
     * @createTime Nov 19, 2014 1:39:20 AM
     */
    public class TouchEvent extends Event
    {
        public static const TOUCH_BEGIN:String = "touch_begin";
        public static const TOUCH_MOVE:String = "touch_move";
        public static const TOUCH_END:String = "touch_end";
        public static const TOUCH_TAP:String = "touch_tap";
        
        
        public var data:Object;
        
        public function TouchEvent(type:String, data:Object = null, bubbles:Boolean = false) 
        { 
            super(type, bubbles);
            this.data = data;
        } 
        
        public override function clone():Event 
        { 
            return new DataEvent(type, data);
        } 
        
        public override function toString():String 
        { 
            return formatToString("DataEvent", "type", "bubbles", "cancelable", "eventPhase", "data"); 
        }
    }
}