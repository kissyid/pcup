package com.pcup.utils
{
    import com.pcup.framework.errors.AbstractError;
    
    import flash.display.Stage;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    
    /**
     * @author ph
     * @createTime Nov 24, 2014 11:25:01 PM
     */
    public class Console
    {
        public function Console()
        {
            throw new AbstractError();
        }
        
        static private var t:TextField;
        
        static public function init(stg:Stage):void
        {
            if (!stg) throw new Error("null parameter.");
            if (!t)
            {
                t = new TextField(); //t.border = true;
                t.defaultTextFormat = new TextFormat(null, 26, 0xFFFFFF, true);
                t.mouseEnabled = false;
                t.alpha = 0.5;
                t.wordWrap = true;
                t.width = stg.stageWidth;
                t.height = stg.stageHeight;
                t.background = true;
                t.backgroundColor = 0;
                t.text = "--- console start ---";
                stg.addChild(t);
            }
        }
        
        static public function print(obj:*):void
        {
            t.appendText("\n> " + String(obj));
        }
        
        
    }
}