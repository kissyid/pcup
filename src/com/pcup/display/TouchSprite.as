package com.pcup.display 
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    
    
    /**
     * @author pihao
     */
    public class TouchSprite extends Sprite
    {
        public var dragEnable:Boolean = true;
        public var rotateEnable:Boolean = true;
        
        /**
         * [i][0]: local coordinate at touch-begin
         * [i][1]: stage coordinate at touch-begin
         * [i][2]: stage coordinate at touch-move
         */
        private var touchPoints:Vector.<Array> = new Vector.<Array>;
        
        private var touchIds:Vector.<int> = new Vector.<int>;
        
        private var appearUpdate:Boolean;   // the switch of update first touch-point property
        private var leaveUpdate:Boolean;    // the switch of update second touch-point property
        
        private var tmpScale:Number = 1;
        private var tmpRotate:Number = 0;
        
        private var operateType:int = -1;
        private const DRAG:int = 1;
        private const ZOOM_ROTATE:int = 2;
        
        
        public function TouchSprite():void 
        {
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        private function onAddedToStage(e:Event):void 
        {
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        }
        private function onRemovedFromStage(e:Event):void 
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        }
        
        override public function dispose():void
        {
            super.dispose();
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            onRemovedFromStage(null);
        }
        
        
        private function onTouchBegin(e:TouchEvent):void
        {
            touchIds.push(e.touchPointID);
            
            // Sometimes, "e.target" is not "this", so need transform
            var targetLocal:Point = new Point(e.localX, e.localY);
            var global:Point = (e.target as DisplayObject).localToGlobal(targetLocal);
            var thisLocal:Point = this.globalToLocal(global);
            touchPoints.push([thisLocal, new Point(e.stageX, e.stageY), new Point()]);
            
            if (touchIds.length == 1)
            {
                operateType = DRAG;
            }
            else if (touchIds.length == 2)
            {
                operateType = ZOOM_ROTATE;
                appearUpdate = true;
            }
            else
            {
                //trace("More than two touch-point, current number of touch-point:", touchId.length);
            }
        }
        private function onTouchMove(e:TouchEvent):void 
        {
            for (var i:* in touchIds)
            {
                if (touchIds[i] == e.touchPointID)
                {
                    // Constantly update the stage-coordinate of touch-point
                    touchPoints[i][2] = new Point(e.stageX, e.stageY);
                    
                    /**
                     * Update stage-coordinate and scale/rotate of "this" when the second touch-point appear.
                     * Otherwise, shaking when the second touch-point appear.
                     * "i == 0" for update the first touch-point.
                     */
                    if (appearUpdate && i == 0)
                    {
                        touchPoints[0][1] = new Point(e.stageX, e.stageY);
                        
                        tmpScale = scaleX;
                        tmpRotate = rotation;
                        
                        appearUpdate = false;
                    }
                    
                    /** 
                     * Update stage-coordinate when there is a touch-point leave and the remaining number is one.
                     * Otherwise, shaking when there is a touch-point leave and the remaining number is one.
                     */ 
                    if (leaveUpdate && i == 0)
                    {
                        // "i == 0" for update the first touch-point.
                        touchPoints[0][1] = new Point(e.stageX, e.stageY);
                        touchPoints[0][0] = globalToLocal(touchPoints[0][1]);
                        
                        leaveUpdate = false;
                    }
                }
            }
            
            if (operateType == DRAG && dragEnable) 
            {
                correctPosition();
            }
            else if (operateType == ZOOM_ROTATE)
            {
                var L1:Number = Math.sqrt(Math.pow(touchPoints[0][1].x - touchPoints[1][1].x, 2) + Math.pow(touchPoints[0][1].y - touchPoints[1][1].y, 2));
                var L2:Number = Math.sqrt(Math.pow(touchPoints[0][2].x - touchPoints[1][2].x, 2) + Math.pow(touchPoints[0][2].y - touchPoints[1][2].y, 2));
                var currentScale:Number = tmpScale * (L2 / L1);
                if      (currentScale > scaleMax) currentScale = scaleMax;
                else if (currentScale < scaleMin) currentScale = scaleMin;
                scaleX = scaleY = currentScale;
                
                if (rotateEnable)
                {
                    var angle1:Number = getAngle(touchPoints[0][1].x - touchPoints[1][1].x, touchPoints[0][1].y - touchPoints[1][1].y);
                    var angle2:Number = getAngle(touchPoints[0][2].x - touchPoints[1][2].x, touchPoints[0][2].y - touchPoints[1][2].y);
                    var currentRotate:Number = tmpRotate + (angle2 - angle1);
                    rotation = currentRotate;
                }
                
                correctPosition();
            }
        }
        private function onTouchEnd(e:TouchEvent):void 
        {
            for (var i:* in touchIds) 
            {
                if (touchIds[i] == e.touchPointID)
                {
                    touchIds.splice(i, 1);
                    touchPoints.splice(i, 1);
                }
            }
            
            if (touchIds.length == 1 && hitTestPoint(touchPoints[0][2].x, touchPoints[0][2].y))
            {
                operateType = DRAG;
                leaveUpdate = true;
            }
            else if (touchIds.length == 0)
            {
                operateType = -1;
            }
        }
        
        
        // Correct the position of "this"
        private function correctPosition():void 
        {
            var temP:Point = localToGlobal(touchPoints[0][0]);
            x += touchPoints[0][2].x - temP.x;
            y += touchPoints[0][2].y - temP.y;
        }
        
        // Get the angle by two point
        private function getAngle(X:Number, Y:Number):Number 
        {
            const GRAD_PI:Number = 180 / Math.PI;
            
            if (X == 0)
            {
                if (Y < 0)  return 270;
                else        return 90;
            }
            else if (Y == 0)
            {
                if (X < 0)  return 180;
                else        return 0;
            }
            
            if (Y > 0)
            {
                if (X > 0)  return Math.atan(Y / X) * GRAD_PI;
                else        return 180 - Math.atan(Y / -X) * GRAD_PI;
            }
            else
            {
                if (X > 0)  return 360 - Math.atan( -Y / X) * GRAD_PI;
                else        return 180 + Math.atan( -Y / -X) * GRAD_PI;
            }
        }
        
        
        private var scaleMin:Number = 0;
        private var scaleMax:Number = 0;
        private var minL:uint = 100;
        private var maxL:uint = 7000;
        public function setScaleScope(min:uint = 100, max:uint = 7000):void
        {
            if (min > max) return;
            minL = min;
            maxL = max;
        }
        
        override protected function afterChildrenUpdated():void
        {
            super.afterChildrenUpdated();
            
            if (this.width == 0 || this.height == 0) return;
            if (this.width < this.height)
            {
                scaleMin = minL / (this.width / this.scaleX);
                scaleMax = maxL / (this.height / this.scaleY);
            }
            else
            {
                scaleMin = minL / (this.height / this.scaleY);
                scaleMax = maxL / (this.width / this.scaleX);
            }
        }
        
    }

}