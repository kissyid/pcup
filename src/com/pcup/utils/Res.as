package com.pcup.utils
{
    import flash.display.Bitmap;
    import flash.utils.Dictionary;
    
    /**
     * 
     * @author phx
     * @createTime May 3, 2014 7:42:59 PM
     */
    public class Res
    {
        private var dic:Dictionary;
        
        public function Res()
        {
            dic = new Dictionary();
        }
        
        
        public function add(name:String, obj:*):void
        {
            dic[name] = obj;
        }
        
        public function remove(name:String):void
        {
            if (dic[name])
            {
                if (dic[name] is Bitmap) dic[name].bitmapData.dispose();
                if (dic[name].hasOwnProperty("dispose")) dic[name].dispose();
                delete dic[name];
            }
        }
        
        
        public function getByName(name:String):*
        {
            return dic[name];
        }
        
        public function getByNamePrefix(prefix:String):Array
        {
            var arr:Array = [];
            var list:Array = [];
            for (var n:String in dic)
                if (n.substr(0, prefix.length) == prefix)
                    list.push({name:n, data:dic[n]});
            list.sortOn("name");
            for each (var obj:Object in list)
                arr.push(obj.data);
            return arr;
        }
        
        public function getAll():Array
        {
            return getByNamePrefix("");
        }
        
        public function dispose():void
        {
            for (var name:* in dic) 
                remove(name);
        }
        
    }
}