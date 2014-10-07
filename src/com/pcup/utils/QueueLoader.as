package com.pcup.utils
{
    import com.pcup.fw.events.DataEvent;
    
    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    
    [Event(name="complete_one" type="utils.DataEvent")]
    [Event(name="completea" type="flash.events.Event")]
    
    /**
     * save `e.target.content` in `Res`(Dictionary).
     * in dictionary, key is file name, value is `e.target.content`.
     * 
     * @author phx
     * @createTime May 3, 2014 7:17:26 PM
     */
    public class QueueLoader extends EventDispatcher
    {
        private var loader:Loader;
        private var currentIndex:int;
        
        private var res:Res;
        private var urls:Array;
        
        
        public function QueueLoader()
        {
            loader = new Loader();
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
            
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
            loadOne(urls[currentIndex]);
        }
        
        private function loadOne(url:String):void
        {
            loader.load(new URLRequest(url), new LoaderContext(false, ApplicationDomain.currentDomain)); 
        }
        
        private function onComplete(e:Event):void
        {
            saveAndNext(e.target.content);
        }
        private function onError(e:ErrorEvent):void
        {
            trace("Resource lost: " + urls[currentIndex]);
            saveAndNext(null);
        }
        
        private function saveAndNext(data:Object):void
        {
            var matchs:Array = urls[currentIndex].match(/(?<=\b)[\w]+(?=\.)/);
            if (matchs)
            {
                var fileName:String = matchs[0];
                res.add(fileName, data);
            }
            currentIndex++;
            this.dispatchEvent(new DataEvent(DataEvent.COMPLETE_ONE, {ratio:currentIndex / urls.length, content:data}));
            
            if (currentIndex >= urls.length)
            {
                loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
                loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
                this.dispatchEvent(new DataEvent(Event.COMPLETE, res));
            }
            else
            {
                loadOne(urls[currentIndex]);
            }
        }
        
        public function dispose():void
        {
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
            loader.close();
            loader = null;
            
            res.dispose();
            res = null;
        }
        
    }
}