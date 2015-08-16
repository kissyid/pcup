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
        /**
         * scale the DisplayObject with maintain aspect ratio
         */
        static public function showAll(obj:DisplayObject, maxWidth:int, maxHeight:int):DisplayObject
        {
            var scale:Number = Math.min(maxWidth / obj.width, maxHeight / obj.height);
            obj.scaleX = obj.scaleY = scale;
            return obj;
        }
        
        /**
         * get the closest value in [min, max]
         */
        static public function closest(value:Number, min:Number, max:Number):Number
        {
            if (min < max)
            {
                if      (value < min) value = min;
                else if (value > max) value = max;
            }
            return value;
        }
        
        /**
         * max must bigger than min
         * @param boundary null is [true, true]
         */
        static public function isBetween(value:Number, min:Number, max:Number, boundary:Array = null):Boolean
        {
            if (min > max) return false;
            
            if (!boundary) boundary = [true, true];
            
            if      ( boundary[0] &&  boundary[1])  return (value >= min && value <= max);
            else if ( boundary[0] && !boundary[1])  return (value >= min && value <  max);
            else if (!boundary[0] &&  boundary[1])  return (value >  min && value <= max);
            else                                    return (value >  min && value <  max);
        }
        
        
        /**
         * fill to specify digit length 
         */
        public static function fill(value:uint, digit:uint):String
        {
            var str:String = String(value);
            if (str.length < digit)
            {
                var addLength:uint = digit - str.length;
                for (var i:int = 0; i < addLength; i++) 
                {
                    str = "0" + str;
                }
            }
            return str;
        }
        
        
        
    }
}