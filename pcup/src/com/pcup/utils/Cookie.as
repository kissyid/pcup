package com.pcup.utils 
{
    import flash.net.SharedObject;
    import flash.net.SharedObjectFlushStatus;
    
    /**
     * @author pihao
     */
    public class Cookie 
    {
        static private var _name:String;
        
        /**
         * @param name the name of this cookie
         */
        static public function init(name:String):void
        {
            _name = name;
            SharedObject.getLocal(_name, "/");
        }
        
        static public function getData(key:String):*
        {
            if (!hasInit) return;
            var s:SharedObject = SharedObject.getLocal(_name, "/");
            return s.data[key];
        }
        
        static public function setData(key:String, value:*):void
        {
            if (!hasInit) return;
            var s:SharedObject = SharedObject.getLocal(_name, "/");
            s.data[key] = value;
            flush(s);
        }
        
        static public function removeData(key:String, value:*):void
        {
            if (!hasInit) return;
            var s:SharedObject = SharedObject.getLocal(_name, "/");
            if (s.data[key]) s.data[key] = null;
            flush(s);
        }
        
        static public function getAll():Object 
        {
            if (!hasInit) return null;
            var s:SharedObject = SharedObject.getLocal(_name, "/");
            return s.data;
        }
        
        static public function clear():void
        {
            if (!hasInit) return;
            var sharedOjbect:SharedObject = SharedObject.getLocal(_name, "/");
            sharedOjbect.clear();
        }
        
        static private function get hasInit():Boolean
        {
            if (!_name) 
            {
                trace("[Cookie]本模块还未初始化。使用 init() 方法初始化。");
                return false;
            }
            return true;
        }
        
        static private function flush(sharedObject:SharedObject):void
        {
            var flushStatus:String = null;
            try 
            {
                flushStatus = sharedObject.flush();
            } 
            catch (e:Error) 
            {
                trace("[Cookie][错]写入失败。\n", e);
            }
            
            if (flushStatus == SharedObjectFlushStatus.PENDING) 
            {
                trace("[Cookie][错]写入失败。分配的空间量不足以存储该对象。");
            }
            else if (flushStatus == SharedObjectFlushStatus.FLUSHED) 
            {
                //trace("[Cookie]写入成功。");
            }
        }
        
    }

}