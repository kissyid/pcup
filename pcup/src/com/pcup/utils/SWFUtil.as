package com.pcup.utils
{
    import flash.utils.getDefinitionByName;
    
    /**
     * REQUIREMENT: Loaded SWF Domain must be `ApplicationDomain.currentDomain`.
     * 
     * @author pihao
     * @createTime 2014-9-10 5:50:16 PM
     */
    public class SWFUtil
    {
        private static var _ins:SWFUtil;
        public function SWFUtil()
        {
            super();
            if (_ins) throw(new Error("Singleton"));
            _ins = this;
        }
        public static function get ins():SWFUtil
        {
            if (!_ins) new SWFUtil();
            return _ins;
        }
        
        
        public function getClass(className:String):Class
        {
            return getDefinitionByName(className) as Class;
        }
        
        public function getInstance(className:String):*
        {
            var c:Class = getClass(className);
            return new c;
        }
        
    }
}