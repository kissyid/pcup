package com.pcup.utils
{
    
    /**
     * @author phx
     * @createTime Oct 18, 2014 3:43:44 AM
     */
    public class TimeUtil
    {
        /**
         * @param format
         * @param time the date in milliseconds since the midnight on 1970-01-01. 0 is now time
         * @return 
         */
        public static function formatTime(format:String = "%Y-%M-%D %H:%I:%S", time:Number = 0):String
        {
            var date:Date = new Date();
            if (time != 0) date.setTime(time);
            
            var str:String = format;
            str = str.replace(/%Y/g, String(date.fullYear)); // 2014
            str = str.replace(/%y/g, String(date.fullYear % 100)); // 14
            str = str.replace(/%M/g, String(NumberUtil.fill(date.month + 1, 2))); // 01
            str = str.replace(/%m/g, String(date.month + 1)); // 1
            str = str.replace(/%B/g, getMonth(date.month)); // January
            str = str.replace(/%b/g, getMonth(date.month, true)); // Jan
            str = str.replace(/%D/g, NumberUtil.fill(date.date, 2)); // 01
            str = str.replace(/%d/g, String(date.date)); // 1
            str = str.replace(/%H/g, NumberUtil.fill(date.hours, 2)); // 01
            str = str.replace(/%h/g, String(date.hours)); // 1
            str = str.replace(/%I/g, NumberUtil.fill(date.minutes, 2)); // 01
            str = str.replace(/%i/g, String(date.minutes)); // 1
            str = str.replace(/%I/g, NumberUtil.fill(date.minutes, 2)); // 01
            str = str.replace(/%i/g, String(date.minutes)); // 1
            str = str.replace(/%S/g, NumberUtil.fill(date.seconds, 2)); // 01
            str = str.replace(/%s/g, String(date.seconds)); // 1
            
            return str;
            
            function getMonth(index:uint, simple:Boolean = false):String
            {
                var str:String = "";
                switch (index)
                {
                    case 0:  str = simple ? "Jan" : "January";  break;
                    case 1:  str = simple ? "Feb" : "February";  break;
                    case 2:  str = simple ? "Mar" : "March";  break;
                    case 3:  str = simple ? "Apr" : "April";  break;
                    case 4:  str = simple ? "May" : "May";  break;
                    case 5:  str = simple ? "Jun" : "June";  break;
                    case 6:  str = simple ? "Jul" : "July";  break;
                    case 7:  str = simple ? "Aug" : "August";  break;
                    case 8:  str = simple ? "Sep" : "September";  break;
                    case 9:  str = simple ? "Oct" : "October";  break;
                    case 10: str = simple ? "Nov" : "November";  break;
                    case 11: str = simple ? "Dec" : "December";  break;
                }
                return str;
            }
        }
        
        /**
         * @param time the date in milliseconds since the midnight on 1970-01-01
         * @param sourceTimeZone
         * @param targetTimeZone
         * @return 
         */
        public static function convertTimeZone(time:Number, sourceTimeZone:int = 0, targetTimeZone:int = 0):Number
        {
            return time + (targetTimeZone - sourceTimeZone) * 3600 * 1000;
        }
        
        
    }
}