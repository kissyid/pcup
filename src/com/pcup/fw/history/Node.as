package com.pcup.fw.history
{
    
    /**
     * 
     * @author phx
     * @createTime Sep 28, 2014 2:13:10 AM
     */
    public class Node
    {
        public var module:Class;
        public var params:Array;

        public function Node(module:Class, args:Array = null)
        {
            this.module = module;
            this.params = args;
        }
    }
}