package com.pcup.fw.errors
{
    
    /**
     * @author ph
     * @createTime Nov 19, 2014 2:04:18 AM
     */
    public class SingletonError extends Error
    {
        public function SingletonError(message:*="Cannot instantiate single class.", id:*=0)
        {
            super(message, id);
        }
    }
}