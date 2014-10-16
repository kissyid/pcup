package com.pcup.fw
{
    import com.pcup.fw.events.DataEvent;
    import com.pcup.fw.history.Path;
    import com.pcup.utils.QueueLoader;
    import com.pcup.utils.Res;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    /**
     * 
     * @author pihao
     * @createTime May 3, 2014 10:18:10 PM
     */
    public class View extends Sprite
    {
        public static var stageW:int = 600;
        public static var stageH:int = 400;
        public static var path:Path = new Path();
        
        protected var res:Res = null;
        
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
        
        protected function onAddToStage(e:Event):void
        {
            addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
        }
        protected function onRemoveFromStage(e:Event):void
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
        }
        
        protected function onClick(e:MouseEvent):void
        {
        }
        
        public function open():void
        {
            if (baseView) baseView.addChild(this);
            else throw new Error("No baseView!");
        }
        
        override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
        {
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
            
            if (!listeners) listeners = [];
            for each (var o:Object in listeners)
            if (o.type == type && o.listener == listener && o.useCapture == useCapture)
                return;
            listeners.push({type:type, listener:listener, useCapture:useCapture});
        }
        override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
            super.removeEventListener(type, listener, useCapture);
            
            for each (var o:Object in listeners)
            if (o.type == type && o.listener == listener && o.useCapture == useCapture)
            {
                listeners.splice(listeners.indexOf(o), 1);
                break;
            }
        }
        public function removeEventListeners():void
        {
            while (listeners.length > 0)
            {
                var o:Object = listeners.pop();
                this.removeEventListener(o.type, o.listener, o.useCapture);
            }
            listeners = null;
        }
        private var listeners:Array;
        
        public function removeFromParent(dispose:Boolean = false):void
        {
            if (parent) parent.removeChild(this);
            if (dispose) this.dispose();
        }
        
        public function dispose():void
        {
            removeEventListeners();
            if (res) res.dispose();
        }
        
        
        protected function loadRes(urls:Array):void
        {
            mouseBase = false;
            var l:QueueLoader = new QueueLoader();
            l.addEventListener(DataEvent.COMPLETE_ONE, onResLoadedOne);
            l.addEventListener(Event.COMPLETE, onResLoaded);
            l.load(urls);
        }
        protected function onResLoadedOne(e:DataEvent):void
        {
        }
        protected function onResLoaded(e:DataEvent):void
        {
            var l:QueueLoader = e.target as QueueLoader;
            l.removeEventListener(DataEvent.COMPLETE_ONE, onResLoadedOne);
            l.removeEventListener(Event.COMPLETE, onResLoaded);
            l = null;
            res = e.data as Res;
            mouseBase = true;
        }
        
        
        public function set mouseBase(value:Boolean):void
        {
            baseView.mouseEnabled = baseView.mouseChildren = value;
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
            s.graphics.drawRect(0, 0, stageW, stageH);
            s.graphics.endFill();
            baseView.addChild(s);
            baseView.mask = s;
        }
        private static var _baseView:DisplayObjectContainer;
        
        
    }
}