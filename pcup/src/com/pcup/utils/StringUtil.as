package com.pcup.utils
{
    public class StringUtil
    {
        /**
         * Decode `.buildtimestamp` file
         * Embed code example:
         *   [Embed(source=".buildtimestamp", mimeType="application/octet-stream")]
         *   const buildtimestamp:Class;
         * @param release true:release time, false:build time
         */
        static public function getBuildTimestamp(buildTimestampXML:*, release:Boolean = true):String
        {
            var str:String = null;
            var xml:XML = XML(buildTimestampXML);
            if (xml)
            {
                str = release ? xml.release.@time : xml.build.@time;
                str = str.replace(/[- :]/g, "");
            }
            return str;
        }
        
        /**
         * String interpolation like: `my name is {0}.`
         */
        static public function substitute(str:String, ...repl):String
        {
            for (var i:int in repl)
                str = str.replace(new RegExp("\\{" + i + "\\}", "g"), repl[i]);
            return str;
        }
        
        
    }
}