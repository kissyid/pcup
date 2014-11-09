package com.pcup.fw
{
    import com.pcup.fw.events.DataEvent;
    import com.pcup.fw.hack.Sprite;
    import com.pcup.fw.history.Path;
    import com.pcup.utils.QueueLoader;
    import com.pcup.utils.Res;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    /**
     * @author pihao
     * @createTime May 3, 2014 10:18:10 PM
     */
    public class View extends Sprite
    {
        public static var stageW:int = 600;
        public static var stageH:int = 400;
        public static var viewW:int = 600;
        public static var viewH:int = 400;
        public static var path:Path = new Path();
        
        public function View()
        {
            super();
            init();
            addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
        }
        protected function init():void
        {
            addEventListener(MouseEvent.CLICK, onClick);
        }
        protected function onClick(e:MouseEvent):void
        {
        }
        protected function onAddToStage(e:Event):void
        {
            addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
        }
        protected function onRemoveFromStage(e:Event):void
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
        }
        
        
        public function open():void
        {
            if (baseView) baseView.addChild(this);
            else throw new Error("No baseView!");
        }
        override public function dispose():void
        {
            super.dispose();
            if (loader)
            {
                removeLoaderListener(loader);
                loader.dispose();
                loader = null;
            }
            if (res)
            {
                res.dispose();
                res = null;
            }
        }
        
        
        private static var loaderNum:int = 0;
        private var loader:QueueLoader;
        protected var res:Res = null;
        protected function loadRes(urls:Array):void
        {
            if (loaderNum == 0) mouseBase = false;
            loaderNum++;
            
            loader = new QueueLoader();
            addLoaderListener(loader);
            loader.load(urls);
        }
        protected function onResLoadedOne(e:DataEvent):void
        {
        }
        protected function onResLoaded(e:DataEvent):void
        {
            removeLoaderListener(loader);
            res = e.data as Res;
            
            loaderNum--;
            if (loaderNum == 0) mouseBase = true;
        }
        private function addLoaderListener(l:QueueLoader):void
        {
            l.addEventListener(DataEvent.COMPLETE_ONE, onResLoadedOne);
            l.addEventListener(DataEvent.COMPLETE, onResLoaded);
        }
        private function removeLoaderListener(l:QueueLoader):void
        {
            l.removeEventListener(DataEvent.COMPLETE_ONE, onResLoadedOne);
            l.removeEventListener(DataEvent.COMPLETE, onResLoaded);
        }
        
        
        public static function get baseView():DisplayObjectContainer
        {
            return _baseView;
        }
        public static function set baseView(value:DisplayObjectContainer):void
        {
            _baseView = value;
            stageW = _baseView.stage.stageWidth;
            stageH = _baseView.stage.stageHeight;
            
            var s:Shape = new Shape();
            s.graphics.beginFill(0);
            s.graphics.drawRect(0, 0, viewW, viewH);
            s.graphics.endFill();
            baseView.addChild(s);
            baseView.mask = s;
        }
        private static var _baseView:DisplayObjectContainer;
        
        public function set mouseBase(value:Boolean):void
        {
            baseView.mouseEnabled = baseView.mouseChildren = value;
        }
        
    }
}