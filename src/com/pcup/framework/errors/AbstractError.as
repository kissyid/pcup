package com.pcup.framework.errors
{
    /**
     * @author ph
     * @createTime Nov 24, 2014 11:40:30 PM
     */
    public class AbstractError extends Error
    {
        public function AbstractError(message:*="Cannot instantiate abstract class.", id:*=0)
        {
            super(message, id);
        }
    }
}