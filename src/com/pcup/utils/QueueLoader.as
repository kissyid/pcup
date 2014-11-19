package com.pcup.utils
{
    import com.pcup.fw.events.DataEvent;
    import com.pcup.fw.hack.EventDispatcher;
    
    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    
    [Event(name="complete_one" type="com.pcup.fw.events.DataEvent")]
    [Event(name="complete" type="com.pcup.fw.events.DataEvent")]
    
    /**
     * save data in a Dictionary named res:
     * key => file name
     * value => e.target.content
     * 
     * @author phx
     * @createTime May 3, 2014 7:17:26 PM
     */
    public class QueueLoader extends EventDispatcher
    {
        private var urls:Array;
        private var currentIndex:int;
        private var loader:Loader;
        private var res:Table;
        
        public function QueueLoader()
        {
        }
        
        public function load(urls:Array):void
        {
            if (!urls || urls.length == 0)
            {
                trace("[WARNING] URLs is null!");
                this.dispatchEvent(new DataEvent(DataEvent.COMPLETE));
                return;
            }
            
            if (loader) disposeLoaderAndRes();
            
            this.urls = urls;
            currentIndex = 0;
            res = new Table();
            
            loader = new Loader();
            addLoaderListener(loader);
            loadOne(urls[currentIndex]);
        }
        
        private function loadOne(url:String):void
        {
            url = FileUtil.tryToRemoveAppDirPrefix(url);
            loader.load(new URLRequest(url), new LoaderContext(false, ApplicationDomain.currentDomain)); 
        }
        
        private function onComplete(e:Event):void
        {
            saveAndNext(e.target.content);
        }
        private function onError(e:ErrorEvent):void
        {
            trace("[WARNING] Resource lost: " + urls[currentIndex]);
            saveAndNext(null);
        }
        
        private function saveAndNext(data:Object):void
        {
            var matchs:Array = urls[currentIndex].match(/(?<=[\/\\])[\w\+\-\.]+(?=[\.\b])/); // match file name
            if (matchs) res.add(matchs[0], data);
            else res.add(urls[currentIndex], data);
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
        
        private function addLoaderListener(l:Loader):void
        {
            l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        }
        private function removeLoaderListener(l:Loader):void
        {
            l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            l.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
        }
        
        public function disposeLoaderAndRes():void
        {
            if (loader)
            {
                removeLoaderListener(loader);
                loader.unloadAndStop();
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