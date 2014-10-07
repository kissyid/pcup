package com.pcup.utils
{
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import com.pcup.fw.events.DataEvent;
    
    [Event(name="complete_one" type="utils.DataEvent")]
    [Event(name="completea" type="flash.events.Event")]
    
    /**
     * Save `e.target.data` in `Res` 
     * @author phx
     * @createTime May 3, 2014 7:17:26 PM
     */
    public class QueueURLLoader extends EventDispatcher
    {
        private var loader:URLLoader;
        private var currentIndex:int;
        
        private var res:Res;
        private var urls:Array;
        
        
        public function QueueURLLoader()
        {
            loader = new URLLoader();
        }
        
        public function load(urls:Array):void
        {
            if (!urls || urls.length == 0)
            {
                trace("URLs is null!");
                return;
            }
            
            this.urls = urls;
            res = new Res();
            currentIndex = 0;
            
            loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            loader.addEventListener(Event.COMPLETE, onComplete);
            loadOne(urls[currentIndex]);
        }
        
        private function loadOne(url:String):void
        {
            loader.load(new URLRequest(url));
        }
        
        private function onComplete(e:Event):void
        {
            saveAndNext(e.target.data);
        }
        private function onError(e:ErrorEvent):void
        {
            trace("Resource lost: " + urls[currentIndex]);
            saveAndNext(null);
        }
        
        private function saveAndNext(data:Object):void
        {
            res.add(urls[currentIndex], data);
            currentIndex++;
            this.dispatchEvent(new DataEvent(DataEvent.COMPLETE_ONE, {ratio:currentIndex / urls.length, content:data}));
            
            if (currentIndex >= urls.length)
            {
                loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
                loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
                loader.removeEventListener(Event.COMPLETE, onComplete);
                this.dispatchEvent(new DataEvent(Event.COMPLETE, res));
            }
            else
            {
                loadOne(urls[currentIndex]);
            }
        }
        
        public function dispose():void
        {
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            loader.removeEventListener(Event.COMPLETE, onComplete);
            loader.close();
            loader = null;
            
            res.dispose();
            res = null;
        }
        
    }
}