package com.pcup.utils
{
    import flash.display.DisplayObject;
    
    /**
     * 
     * @author phx
     * @createTime Oct 6, 2014 1:34:25 AM
     */
    public class NumberUtil
    {
        static public function showAll(obj:DisplayObject, ctnWidth:int, ctnHeight:int):DisplayObject
        {
            var scale:Number = Math.min(ctnWidth / obj.width, ctnHeight / obj.height);
            obj.scaleX = obj.scaleY = scale;
            return obj;
        }
        
        
    }
}