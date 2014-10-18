package com.pcup.fw.events
{
    import flash.events.Event;
    
    /**
     * 
     * @author pihao
     * @createTime May 3, 2014 6:39:28 PM
     */
    public class DataEvent extends Event 
    {
        public static const COMPLETE:String = "complete";
        public static const COMPLETE_ONE:String = "complete_one";
        public static const INIT_COMPLETE:String = "init_complete";
        public static const CHANGE:String = "change";
        public static const OVER:String = "over";
        public static const LOOP:String = "loop";
        
        
        public var data:Object;
        
        public function DataEvent(type:String, data:Object = null, bubbles:Boolean = false) 
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