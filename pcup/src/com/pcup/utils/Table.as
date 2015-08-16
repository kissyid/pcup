package com.pcup.utils
{
    import flash.display.Bitmap;
    import flash.utils.Dictionary;
    
    /**
     * @author pihao
     * @createTime May 3, 2014 7:42:59 PM
     */
    public class Table
    {
        private var dic:Dictionary;
        
        public function Table()
        {
            dic = new Dictionary();
        }
        
        public function add(key:String, value:*):void
        {
            dic[key] = value;
        }
        
        public function remove(key:String):void
        {
            if (dic[key])
            {
                if (dic[key] is Bitmap) dic[key].bitmapData.dispose();
                if (dic[key].hasOwnProperty("dispose")) dic[key].dispose();
                delete dic[key];
            }
        }
        
        public function getByName(key:String):*
        {
            return dic[key];
        }
        
        public function getByNamePrefix(prefix:String):Array
        {
            var arr:Array = [];
            var list:Array = [];
            for (var n:String in dic)
                if (n.substr(0, prefix.length) == prefix)
                    list.push({name:n, data:dic[n]});
            list.sortOn("key");
            for each (var obj:Object in list)
                arr.push(obj.data);
            return arr;
        }
        
        public function get all():Array
        {
            return getByNamePrefix("");
        }
        
        public function dispose():void
        {
            for (var key:* in dic) 
                remove(key);
        }
        
    }
}