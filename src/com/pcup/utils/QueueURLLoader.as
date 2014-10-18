package com.pcup.utils
{
    import com.pcup.fw.hack.EventDispatcher;
    import com.pcup.fw.events.DataEvent;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    [Event(name="complete_one" type="com.pcup.fw.events.DataEvent")]
    [Event(name="complete" type="com.pcup.fw.events.DataEvent")]
    
    /**
     * Save `e.target.data` in `Res` 
     * @author phx
     * @createTime May 3, 2014 7:17:26 PM
     */
    public class QueueURLLoader extends EventDispatcher
    {
        private var urls:Array;
        private var currentIndex:int;
        private var loader:URLLoader;
        private var res:Res;
        
        public function QueueURLLoader()
        {
        }
        
        public function load(urls:Array):void
        {
            if (!urls || urls.length == 0)
            {
                trace("URLs is null!");
                return;
            }
            
            if (loader) disposeLoaderAndRes();
            
            this.urls = urls;
            currentIndex = 0;
            res = new Res();
            
            loader = new URLLoader();
            addLoaderListener(loader);
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
                removeLoaderListener(loader);
                this.dispatchEvent(new DataEvent(DataEvent.COMPLETE, res));
            }
            else
            {
                loadOne(urls[currentIndex]);
            }
        }
        
        private function addLoaderListener(l:URLLoader):void
        {
            l.addEventListener(IOErrorEvent.IO_ERROR, onError);
            l.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            l.addEventListener(Event.COMPLETE, onComplete);
        }
        private function removeLoaderListener(l:URLLoader):void
        {
            l.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            l.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            l.removeEventListener(Event.COMPLETE, onComplete);
        }
        
        public function disposeLoaderAndRes():void
        {
            if (loader)
            {
                removeLoaderListener(loader);
                try {loader.close();} catch(er:Error){}
                loader = null;
                
                res.dispose();
                res = null;
            }
        }
        
        override public function dispose():void
        {
            super.dispose();
            disposeLoaderAndRes();
        }
        
    }
}