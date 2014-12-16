package com.pcup.framework.singleNotice
{
    import com.pcup.framework.events.DataEvent;
    
    import flash.events.EventDispatcher;
    
    
    /**
     * @author pihao
     */
    public class Notifier
    {
        private var _dispatcher:EventDispatcher = new EventDispatcher();
        private static var _ins:Notifier;
        
        public function Notifier()
        {
            if (_ins) throw(new Error("Singleton"));
            _ins = this;
        }
        public static function get ins():Notifier
        {
            if (!_ins) new Notifier();
            return _ins;
        }
        
        public function addListener(type:String, listener:Function):void
        {
            _dispatcher.addEventListener(type, listener);
        }
        
        public function removeListener(type:String, listener:Function):void
        {
            _dispatcher.removeEventListener(type, listener);
        }
        
        public function sendEvent(type:String, data:Object = null, bubbles:Boolean = false):void
        {
            _dispatcher.dispatchEvent(new DataEvent(type, data));
        }
    }
}