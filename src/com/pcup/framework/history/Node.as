package com.pcup.framework.history
{
    
    /**
     * 
     * @author phx
     * @createTime Sep 28, 2014 2:13:10 AM
     */
    public class Node
    {
        public var module:Class;
        public var params:Object;

        public function Node(module:Class, args:Object = null)
        {
            this.module = module;
            this.params = args;
        }
    }
}