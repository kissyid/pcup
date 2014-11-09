package com.pcup.fw.history
{
    /**
     * @author phx
     * @createTime Sep 28, 2014 3:20:32 AM
     */
    public class Path
    {
        private var list:Vector.<Node>;
        
        public function Path()
        {
            list = new Vector.<Node>();
        }
        
        public function forward(node:Node):void
        {
            list.push(node);
            openLast();
        }
        
        public function back():Node
        {
            var re:Node = null;
            if (list.length > 0)
            {
                re = list.pop();
                openLast();
            }
            return re;
        }
        
        public function backUntilModule(module:Class):void
        {
            while (list.length > 0)
            {
                if (last.module == module)
                {
                    openLast();
                    return;
                }
                list.pop();
            }
        }
        
        private function openLast():void
        {
            _lastModuleInstance = last.module.ins ? last.module.ins : (new last.module);
            lastModuleInstance.open();
        }
        
        public function clear():void
        {
            while (list.length > 0) list.pop();
        }
        
        public function get last():Node
        {
            if (list.length > 0)
                return list[list.length - 1];
            else
                return null;
        }
        
        private var _lastModuleInstance:Object = null;
        public function get lastModuleInstance():Object
        {
            return _lastModuleInstance;
        }
        
    }
}