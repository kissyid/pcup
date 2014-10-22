package com.pcup.utils
{
    public class StringUtil
    {
        
        /**
         * string interpolation like: `my name is {0}.`
         */
        static public function substitute(str:String, ...repl):String
        {
            for (var i:int in repl)
                str = str.replace(new RegExp("\\{" + i + "\\}", "g"), repl[i]);
            return str;
        }
        
        
    }
}