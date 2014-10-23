package com.pcup.display 
{
    import com.pcup.fw.hack.Sprite;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    import flash.utils.Timer;
    
    
    /**
     * Diapatch this event when double-lick.
     * <p>Use this event because the double-click of "MouseEvent" can't use to the "DisplayObjectContainer" which "mouseChilren" is true.</p>
     * @eventType   com.pcup.display.Twotouch.DOUBLE_CLICK
     */
    [Event(name = "doubleClick", type = "com.pcup.display.Twotouch")]
    
    
    /**
     * 两点操作（缩放、旋转）。
     * 直接把要操作的显示对象 addChild 到本类实例中即可。
     * 
     * @author pihao
     */
    public class Twotouch extends Sprite
    {
        /** Define the event type of doubleClick event */
        static public const DOUBLE_CLICK:String = "doubleClick";
        
        /**
         * drag enable or not
         * @default true
         */
        public var dragEnable:Boolean = true;
        /**
         * rotate enable or not
         * @default true
         */
        public var rotateEnable:Boolean = true;
        
        /**
         * The max scale(there is no restriction if the value is zero)
         * @default 0
         */
        public var scaleMax:Number = 0;
        /**
         * The min scale(there is no restriction if the value is zero)
         * @default 0
         */ 
        public var scaleMin:Number = 0; 
        
        /**
         * The max time difference of double-click
         * @default 400ms
         */
        public var doubleTime:uint = 400;
        /**
         * The max deviation of double-click
         * @default 20px
         */
        public var doubleDeviation:uint = 20;
        
        
        /**
         * Save position of touch-points
         *
         * [i][0]: local coordinate at touch-begin
         * [i][1]: stage coordinate at touch-begin
         * [i][2]: stage coordinate at touch-move
         */
        private var touchPoint:Vector.<Array> = new Vector.<Array>;
        
        private var touchId:Vector.<int> = new Vector.<int>;        // id of touch-point
        
        private var appearUpdate:Boolean;                           // the switch of update first touch-point property
        private var leaveUpdate:Boolean;                            // the switch of update second touch-point property
        
        private var clickTimer:Timer;                               // the timer for judge double-click
        private var clickPoint:Point;                               // the position for judge valid region of double-click
        
        private var tmpScale:Number = 1;                            // temporary value of scale
        private var tmpRotate:Number = 0;                           // temporary value of rotate
        
        private var operateType:String;                             // operate type(Drag or ZoomRotate, from the following two constants)
        private const DRAG:String = "drag";                         // define the operate type is drag
        private const ZOOM_ROTATE:String = "zoomRotate";            // define the operate type is zoom-rotate
        
        
        /**
         * Build a new instance of Twotouch.
         */
        public function Twotouch():void 
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        private function onAddedToStage(e:Event):void 
        {
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            
            // Touch mode
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            
            // Double-click
            clickTimer = new Timer(doubleTime, 1);
            addEventListener(TouchEvent.TOUCH_TAP, touchTapHandler);
            
            // Drag & Zoom-rotate
            addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
            stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
            stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler);
        }
        private function onRemovedFromStage(e:Event):void 
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            
            clickTimer.stop();
            clickTimer = null;
            removeEventListener(TouchEvent.TOUCH_TAP, touchTapHandler);
            
            removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
            stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
            stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
        }
        
        
        // Judge double-click 
        private function touchTapHandler(e:TouchEvent):void 
        {
            if (clickTimer.running) 
            {
                if (Math.abs(e.stageX - clickPoint.x) < doubleDeviation && Math.abs(e.stageY - clickPoint.y) < doubleDeviation)
                {
                    clickTimer.reset();
                    dispatchEvent(new Event(Twotouch.DOUBLE_CLICK));
                    //trace("[Twotouch]double-click....");
                }
            }
            else 
            {
                clickTimer.start();
                clickPoint = new Point(e.stageX, e.stageY);
            }
            
        }
        
        
        // TOUCH_BEGIN
        private function touchBeginHandler(e:TouchEvent):void
        {
            // save touch-point-id
            touchId.push(e.touchPointID);
            
            // Sometimes, "e.target" is not "this", so need transform
            var targetLocal:Point = new Point(e.localX, e.localY);
            var global:Point = (e.target as DisplayObject).localToGlobal(targetLocal);
            var thisLocal:Point = this.globalToLocal(global);
            // save some message of touch point
            touchPoint.push([thisLocal, new Point(e.stageX, e.stageY), new Point()]);
            
            // Judge the type of operate, Drag or Zoom-rotate
            if (touchId.length == 1)
            {
                operateType = DRAG;
            }
            else if (touchId.length == 2)
            {
                operateType = ZOOM_ROTATE;
                
                // Turn on "appearUpdate" switch when the second touch-point appear
                appearUpdate = true;
            }
            else
            {
                //trace("[Twotouch]More than two touch-point, current number of touch-point:", touchId.length);
            }
        }
        // TOUCH_MOVE
        private function touchMoveHandler(e:TouchEvent):void 
        {
            // update something
            for (var i:* in touchId)
            {
                if (touchId[i] == e.touchPointID)
                {
                    // Constantly update the stage-coordinate of touch-point
                    touchPoint[i][2] = new Point(e.stageX, e.stageY);
                    
                    /**
                     * Update stage-coordinate and scale/rotate of "this" when the second touch-point appear.
                     * Otherwise, shaking when the second touch-point appear.
                     */
                    if (appearUpdate && i == 0)
                    {
                        // "i == 0" for update the first touch-point.
                        touchPoint[0][1] = new Point(e.stageX, e.stageY);
                        
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
                        touchPoint[0][1] = new Point(e.stageX, e.stageY);
                        touchPoint[0][0] = globalToLocal(touchPoint[0][1]);
                        
                        leaveUpdate = false;
                    }
                    
                }
            }
            
            // Drag
            if (operateType == DRAG && dragEnable) 
            {
                correctPosition();
            }
            // Zoom-rotate
            else if (operateType == ZOOM_ROTATE)
            {
                // Zoom
                var L1:Number = Math.sqrt(Math.pow(touchPoint[0][1].x - touchPoint[1][1].x, 2) + Math.pow(touchPoint[0][1].y - touchPoint[1][1].y, 2));
                var L2:Number = Math.sqrt(Math.pow(touchPoint[0][2].x - touchPoint[1][2].x, 2) + Math.pow(touchPoint[0][2].y - touchPoint[1][2].y, 2));
                var currentScale:Number = tmpScale * (L2 / L1);
                // Control the scale between Max and Min
                if      (scaleMax > 0 && currentScale > scaleMax)   currentScale = scaleMax;
                else if (scaleMin > 0 && currentScale < scaleMin)   currentScale = scaleMin;
                scaleX = scaleY = currentScale;
                
                
                // Rotate
                if (rotateEnable)
                {
                    var angle1:Number = getAngle(touchPoint[0][1].x - touchPoint[1][1].x, touchPoint[0][1].y - touchPoint[1][1].y);
                    var angle2:Number = getAngle(touchPoint[0][2].x - touchPoint[1][2].x, touchPoint[0][2].y - touchPoint[1][2].y);
                    var currentRotate:Number = tmpRotate + (angle2 - angle1);
                    rotation = currentRotate;
                }
                
                // Correct position
                correctPosition();
            }
        }
        // TOUCH_END
        private function touchEndHandler(e:TouchEvent):void 
        {
            // Delete the touch-point that have left
            for (var i:* in touchId) 
            {
                if (touchId[i] == e.touchPointID)
                {
                    touchId.splice(i, 1);
                    touchPoint.splice(i, 1);
                }
            }
            
            // Drag, if there is only one touch-point and it is on "this"
            if (touchId.length == 1 && hitTestPoint(touchPoint[0][2].x, touchPoint[0][2].y))
            {
                operateType = DRAG;
                leaveUpdate = true;
            }
            // There is not touch-point
            else if (touchId.length == 0)
            {
                operateType = null;
            }
        }
        
        
        /** Correct the position of "this" */
        private function correctPosition():void 
        {
            var temP:Point = localToGlobal(touchPoint[0][0]);
            x += touchPoint[0][2].x - temP.x;
            y += touchPoint[0][2].y - temP.y;
        }
        
        
        /** Get the angle by two point */
        private function getAngle(X:Number, Y:Number):Number 
        {
            var GRAD_PI:Number = 180 / Math.PI;
            
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
        
        
        
    }

}