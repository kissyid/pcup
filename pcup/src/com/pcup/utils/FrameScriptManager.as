package com.pcup.utils
{
    import flash.display.FrameLabel;
    import flash.display.MovieClip;

    /**
     * @author pihao
     * @createTime Aug 16, 2015 5:02:43 AM
     */
    public class FrameScriptManager
    {
        private var _mc:MovieClip;
        private var _labelsDict:Object;
        private var _scripts:Array;
        
        public function FrameScriptManager(movieClip:MovieClip)
        {
            if (null == movieClip) throw new Error("FrameScriptManager::movieClip is null.");
            _mc = movieClip;
            _labelsDict = getLabelsDict(_mc);
        }
        
        /**
         * @param frame  frame index (start from 1), or frame label name
         * @param callback
         */
        public function addFrameScript(frame:*, callback:Function):void
        {
            if (isNaN(Number(frame))) frame = _labelsDict[frame];
            if (undefined == frame || frame < 1) return;
            frame -= 1;
            
            _mc.addFrameScript(frame, callback);
            
            if (null == _scripts) _scripts = [];
            _scripts.push(frame); 
        }
        
        private function getLabelsDict(mc:MovieClip):Object
        {
            var dict:Object = {};
            for each (var label:FrameLabel in mc.currentLabels) {
                dict[label.name] = label.frame;
            }
            return dict;
        }
        
        public function destroy():void
        {
            for each (var i:int in _scripts) {
                _mc.addFrameScript(i, null);
            }
            _scripts = null;
            _labelsDict = null;
            _mc = null;
        }
        
    }
}