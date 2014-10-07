package com.pcup.display
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.clearTimeout;
    import flash.utils.getTimer;
    import flash.utils.setTimeout;

    /**
     * Apple 滑动
     *
     * 1. 内容中的对象可直接用 MouseEvent.CLICK 事件来获取单击事件, 拖动时不会触发
     * 2. this 的所有 child 操作均被重写为内容的 child 操作
     * 3. 溢出: 指某对象出现在非正常停靠位置；停靠位置: 指某对象静止下来时所在的位置
     * 4. 关键参考(http://zwwdm.com/?post=84)
     *
     * @example
<listing version="3.0">
var bg:Bitmap = new Bitmap(new BitmapData(600, 400, true, 0xffffd7d7));
addChild(bg);
var slider:Slider = new Slider(600, 400);
addChild(slider);
var _content:Sprite = new Sprite();  
for (var i:int = 0; i < 30; i++) {
    for (var j:int = 0; j < 30; j++) {
        var cube:Sprite = new Sprite();
        cube.graphics.beginFill(Math.random() * 0xffffff);
        cube.graphics.drawRect(0, 0, 100, 100);
        cube.graphics.endFill();
        cube.name = "(" + i + "," + j + ")";
        cube.x = j * (cube.width + 10);
        cube.y = i * (cube.height + 10);
        cube.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{trace(e.target.name)});
        var t:TextField = new TextField();
        t.mouseEnabled = false;
        t.text = cube.name;
        cube.addChild(t);
        _content.addChild(cube);
    }
}
slider.addChild(_content);
</listing>
     * 
     * @author pihao
     */
    public class Slider extends Sprite
    {
        static private const DECAY_NORMAL:Number = 0.95;    // 速度衰减率:未溢出
        static private const DECAY_OVER_GO:Number = 0.5;    // 速度衰减率:惯性溢出
        static private const DECAY_OVER_BACK:Number = 0.35; // 速度衰减率:溢出归位
        
        /** 滚动条的最大停靠位置(为提高效率, 故存储于些, 以免每次都运算) */
        private var barMaxPosition:Point;
        /** 滚动条隐藏延迟方法ID */
        private var barTimeoutId:uint;

        /** 是否可以水平拖动 */ private var isX:Boolean;
        /** 是否可以垂直拖动 */ private var isY:Boolean;

        /** 内容容器 */
        private var content:Sprite;

        /** 水平滚动条 */    private var hBar:Shape;
        /** 垂直滚动条 */    private var vBar:Shape;

        /** 滚动区域 */ private var scrollArea:Rectangle;

        /** 鼠标位置(开始拖动时)*/   private var m0:Point;
        /** 鼠标位置(当前)     */   private var m1:Point;
        /** 内容位置(开始拖动时)*/   private var c0:Point;
        /** 内容位置(当前)     */   private var c1:Point;

        /** 速度 */
        private var speed:Point;
        /** 舞台鼠标路径 */
        private var path:Vector.<PathPoint>;
        /** 是否正在作拖动操作. 以此来代替是否达到拖动条件的运算判断, 提高效率 */
        private var isDragging:Boolean;


        /**
         * @param viewWidth 可视宽度
         * @param viewHeight 可视高度
         * @param direction 滑动方向. 0:任意方向, 1:水平, 2:垂直
         */
        public function Slider(viewWidth:uint, viewHeight:uint, direction:int = 0)
        {
            _viewArea = new Rectangle(0, 0, viewWidth, viewHeight);
            _direction = direction;

            m0 = new Point();
            m1 = new Point();
            c0 = new Point();
            c1 = new Point();
            speed = new Point();
            scrollArea = new Rectangle();
            barMaxPosition = new Point();

            var s:Shape = new Shape();
            s.graphics.beginFill(0);
            s.graphics.drawRect(0, 0, viewArea.width, viewArea.height);
            s.graphics.endFill();
            mask = s;
            super.addChild(mask);

            // 填充, 防止点到空白时无法拖动
            s = new Shape();
            s.graphics.beginFill(0, 0);
            s.graphics.drawRect(0, 0, viewArea.width, viewArea.height);
            s.graphics.endFill();
            super.addChild(s);

            content = new Sprite();
            super.addChild(content);

            // 初始化状态
            this.direction = _direction;
            this.barEnable = _barEnable;
            this.barW = _barW;

            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }

        private function mouseDownHandler(e:MouseEvent):void
        {
            removeEventListener(Event.ENTER_FRAME, onFrame);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.ROLL_OUT, onMouseUp);

            // 重置参数
            speed.x = 0;
            speed.y = 0;
            isDragging = false;
            path = new Vector.<PathPoint>();

            // 记录鼠标按下时的坐标
            m0.x = e.stageX;
            m0.y = e.stageY;
        }
        
        private function onMouseMove(e:MouseEvent):void
        {
            // 禁止内容鼠标事件, 这样就内容就可以通过监听 MouseEvent.CLICK 事件来实现单击, 否则拖动后也会造成单击
            content.mouseChildren = false;

            // 临时存储, 提高后面读取此数据的效率
            m1.x = e.stageX;
            m1.y = e.stageY;

            // 还没开始拖动
            if (!isDragging)
            {
                // 是否满足拖动条件(拖动距离大于5象素时才开始拖动, 以此防止误操作, 也防止了内容单击过于敏感的问题)
                if (isX && Math.abs(m1.x - m0.x) > 5
                    ||
                    isY && Math.abs(m1.y - m0.y) > 5)
                {
                    isDragging = true;

                    // 更新鼠标位置
                    m0.x = m1.x;
                    m0.y = m1.y;

                    // 记录内容位置
                    c0.x = c1.x = content.x;
                    c0.y = c1.y = content.y;

                    clearTimeout(barTimeoutId);
                    if (hBar) hBar.visible = true;
                    if (vBar) vBar.visible = true;
                }
            }

            if (isDragging)
            {
                path.push(new PathPoint(m1.x, m1.y, getTimer()));

                // 计算内容当前位置
                c1.x = c0.x + (m1.x - m0.x);
                c1.y = c0.y + (m1.y - m0.y);

                /**
                 * 溢出时拖动距离损失一半.
                 * 溢出情况有三种: 内容可完全显示, 左端溢出, 右端溢出.
                 */
                if (scrollArea.x > 0 || c1.x > 0)
                {
                    if (c0.x > 0 || c0.x < scrollArea.x) c1.x -= (c1.x - c0.x) / 2;       // 开始拖动前已溢出
                    else                                 c1.x /= 2;                       // 开始拖动前未溢出
                }
                else if (c1.x < scrollArea.x)
                {
                    if (c0.x > 0 || c0.x < scrollArea.x) c1.x -= (c1.x - c0.x) / 2;
                    else                                 c1.x -= (c1.x - scrollArea.x) / 2;
                }
                if (scrollArea.y > 0 || c1.y > 0)
                {
                    if (c0.y > 0 || c0.y < scrollArea.y) c1.y -= (c1.y - c0.y) / 2;
                    else                                 c1.y /= 2;
                }
                else if (c1.y < scrollArea.y)
                {
                    if (c0.y > 0 || c0.y < scrollArea.y) c1.y -= (c1.y - c0.y) / 2;
                    else                                 c1.y -= (c1.y - scrollArea.y) / 2;
                }

                update();
            }
        }
        
        private function onMouseUp(e:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.ROLL_OUT, onMouseUp);

            content.mouseChildren = true;

            removeOldPathPoint(getTimer());

            // 至少两个点才进行计算
            if (path.length > 1)
            {
                // 临时存储 _path 中的第一个点和最后一个点
                var p0:PathPoint = path[0];
                var p1:PathPoint = path[(path.length - 1)];

                var totalTime:Number = (p1.t - p0.t) / 15;  // 除一个数来调整惯性力度
                if (totalTime != 0)
                {
                    if (isX) speed.x = (p1.x - p0.x) / totalTime;
                    if (isY) speed.y = (p1.y - p0.y) / totalTime;
                }
            }

            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        private function onFrame(e:Event):void
        {
            // 更新位置
            c1.x += speed.x;
            c1.y += speed.y;

            // 减速
            speed.x *= DECAY_NORMAL;
            speed.y *= DECAY_NORMAL;

            checkOverflow();
            update();
        }


        /** 处理溢出(溢出即内容出现在非法停靠位置时) */
        private function checkOverflow():void
        {
            // 溢出量
            var overX:Number = 0;
            var overY:Number = 0;

            if (isX)
            {
                // 内容可完全显示时, 随便怎么拖都是溢出
                if (content.width < viewArea.width)
                {
                    overX = c1.x;
                }
                // 内容超出显示范围
                else
                {
                    // 左端溢出(向右拖)
                    if (c1.x > 0)
                    {
                        overX = c1.x;
                    }
                    // 右端溢出(向左拖)
                    else if (c1.x < scrollArea.x)
                    {
                        overX = c1.x - scrollArea.x;
                    }
                }

                /**
                 * 溢出
                 * 情况一: 溢出量增大时, 溢出量 * 速度 > 0
                 * 情况二: 溢出量减小时, 溢出量 * 速度 < 0
                 */
                if (overX != 0)
                {
                    if (overX * speed.x > 0)
                    {
                        speed.x -= overX * DECAY_OVER_GO;    // 惯性运动导致溢出时, 用原速度与溢出量做运算
                    }
                    else
                    {
                        speed.x = -overX * DECAY_OVER_BACK;  // 溢出归位时, 取溢出量的比例值
                    }
                }
            }
            if (isY)
            {
                if (content.height < viewArea.height)
                {
                    overY = c1.y;
                }
                else
                {
                    if (c1.y > 0)
                    {
                        overY = c1.y;
                    }
                    else if (c1.y < scrollArea.y)
                    {
                        overY = c1.y - scrollArea.y;
                    }
                }

                if (overY != 0)
                {
                    if (overY * speed.y > 0)
                    {
                        speed.y -= overY * DECAY_OVER_GO;
                    }
                    else
                    {
                        speed.y = -overY * DECAY_OVER_BACK;
                    }
                }
            }

            /**
             * 没有溢出，且速度太小.
             *
             * 溢出量说明:
             * 经测试, 取 1 作为比较值.
             *
             * 速度说明:
             * 为了提高效率没有做开方运算, 换以用最小速度的平方值来做比较.
             * 比如最小速度为 0.5, 那么就用 0.25 (0.5的平方)来做比较.
             * 经测试, 取 0.5 作为比较值.
             *
             * 比较值说明:
             * 溢出量和速度的比较值, 过小时会出现速度很慢内容移动起来像是在跳动, 过大时内容会停止得很突兀.
             */
            if (overX * overX < 1 &&
                overY * overY < 1 &&
                speed.x * speed.x + speed.y * speed.y < 0.25)
            {
                removeEventListener(Event.ENTER_FRAME, onFrame);

                // 延迟隐藏滚动条(300毫秒)
                clearTimeout(barTimeoutId);
                barTimeoutId = setTimeout(hideScrollBar, 300);

                // 对齐边缘
                if      ( c1.x                 *  c1.x                 < 1) c1.x = 0;
                else if ((c1.x - scrollArea.x) * (c1.x - scrollArea.x) < 1) c1.x = scrollArea.x;
                if      ( c1.y                 *  c1.y                 < 1) c1.y = 0;
                else if ((c1.y - scrollArea.y) * (c1.y - scrollArea.y) < 1) c1.y = scrollArea.y;
            }
        }

        private function update():void
        {
            updateContentPosition();
            updateScrollBar();
        }
        
        private function updateContentPosition():void
        {
            if (isX) content.x = c1.x;
            if (isY) content.y = c1.y;
        }
        
        private function updateScrollBar():void
        {
            if (!_barEnable) return;

            var L:Number;   // 滚动条长度
            var P:Number;   // 滚动条位置

            if (isX)
            {
                hBar.graphics.clear();

                // 内容超出显示范围
                if (content.width > viewArea.width)
                {
                    // 先按常规情况计算出长度, 若溢出后面将直接减去溢出量
                    L = viewArea.width * viewArea.width / content.width;

                    // 左端溢出
                    if (c1.x > 0)
                    {
                        L -= c1.x;                  if (L < _barW) L = _barW;
                        P = 0;
                    }
                    // 右端溢出
                    else if (c1.x < scrollArea.x)
                    {
                        L -= scrollArea.x - c1.x;   if (L < _barW) L = _barW;
                        P = viewArea.width - L;
                    }
                    // 无溢出, 即常规情况
                    else
                    {
                        if (L < _barW) L = _barW;

                        P = viewArea.width * -content.x / content.width;
                        // 防止: 滚动条长度小于其宽度时, 当滚动条滚动至右端时会跑出视窗
                        if (P > barMaxPosition.x) P = barMaxPosition.x;
                    }

                    hBar.graphics.beginFill(barColor, 0.5);
                    hBar.graphics.drawRoundRect(0, 0, L, _barW, _barW, _barW);
                    hBar.graphics.endFill();

                    hBar.x = P;
                }
            }
            if (isY)
            {
                vBar.graphics.clear();

                if (content.height > viewArea.height)
                {
                    L = viewArea.height * viewArea.height / content.height;

                    if (c1.y > 0)
                    {
                        L -= c1.y;                    if (L < _barW) L = _barW;
                        P = 0;
                    }
                    else if (c1.y < scrollArea.y)
                    {
                        L -= scrollArea.y -c1.y;      if (L < _barW) L = _barW;
                        P = viewArea.height - L;
                    }
                    else
                    {
                        if (L < _barW) L = _barW;

                        P = viewArea.height * -content.y / content.height;
                        if (P > barMaxPosition.y) P = barMaxPosition.y;
                    }

                    vBar.graphics.beginFill(barColor, 0.5);
                    vBar.graphics.drawRoundRect(0, 0, _barW, L, _barW, _barW);
                    vBar.graphics.endFill();

                    vBar.y = P;
                }
            }
        }

        private function resetScrollBar():void
        {
            if (hBar) { hBar.graphics.clear();    if (super.contains(hBar)) super.removeChild(hBar);    hBar = null; }
            if (vBar) { vBar.graphics.clear();    if (super.contains(vBar)) super.removeChild(vBar);    vBar = null; }

            if (_barEnable)
            {
                if (isX) { hBar = new Shape();    super.addChild(hBar);  hBar.y = viewArea.height - _barW - 2; }
                if (isY) { vBar = new Shape();    super.addChild(vBar);  vBar.x = viewArea.width  - _barW - 2; }
            }
        }
        
        private function hideScrollBar():void
        {
            if (hBar) hBar.visible = false;
            if (vBar) vBar.visible = false;
        }


        private function addPathPoint(pathPoint:PathPoint):void
        {
            removeOldPathPoint(pathPoint.t);
            path.push(pathPoint);
        }
        
        private function removeOldPathPoint(t:int):void
        {
            while (path.length > 0)
            {
                if (t - path[0].t < 101) // 删除100毫秒之前的点，只用100毫秒之内的点
                {
                    break;
                }
                path.shift();
            }
        }
        
        public function dispose():void
        {
            removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }



        private function updateScrollRect():void
        {
            scrollArea.x       = viewArea.width  - content.width  - content.getBounds(content).x;
            scrollArea.y       = viewArea.height - content.height - content.getBounds(content).y;
            scrollArea.width   = content.width;
            scrollArea.height  = content.height;

            // 开始惯性运动(防止滚动区域小于视窗时没有对齐)
            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        override public function addChild(child:DisplayObject):DisplayObject {
            var obj:DisplayObject = content.addChild(child);
            updateScrollRect();
            return obj;
        }
        override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
            var obj:DisplayObject = content.addChildAt(child, index);
            updateScrollRect();
            return obj;
        }
        override public function getChildAt(index:int):DisplayObject {
            var obj:DisplayObject = content.getChildAt(index);
            updateScrollRect();
            return obj;
        }
        override public function getChildByName(name:String):DisplayObject {
            var obj:DisplayObject = content.getChildByName(name);
            updateScrollRect();
            return obj;
        }
        override public function getChildIndex(child:DisplayObject):int {
            var obj:int = content.getChildIndex(child);
            updateScrollRect();
            return obj;
        }
        override public function removeChild(child:DisplayObject):DisplayObject {
            var obj:DisplayObject = content.removeChild(child);
            updateScrollRect();
            return obj;
        }
        override public function removeChildAt(index:int):DisplayObject {
            var obj:DisplayObject = content.removeChildAt(index);
            updateScrollRect();
            return obj;
        }
        override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
            content.removeChildren(beginIndex, endIndex);
            updateScrollRect();
        }

        
        
        /** 可视区域 */
        public function get viewArea():Rectangle
        {
            return _viewArea;
        }
        private var _viewArea:Rectangle;

        /**
         * 滑动方向
         * 0:任意方向, 1:水平, 2:垂直
         */
        public function get direction():uint
        {
            return _direction;
        }
        public function set direction(value:uint):void
        {
            _direction = (value == 1 || value == 2) ? value : 0;
            
            isX = _direction != 2;
            isY = _direction != 1;
            resetScrollBar();
        }
        private var _direction:uint = 0;
        
        /**
         * 是否使用滚动条
         * @default true
         */
        public function get barEnable():Boolean
        {
            return _barEnable;
        }
        public function set barEnable(value:Boolean):void
        {
            _barEnable = value;
            resetScrollBar();
        }
        private var _barEnable:Boolean = true;
        
        /**
         * 滚动条宽度
         * @default 5
         */
        public function get barW():uint
        {
            return _barW;
        }
        public function set barW(value:uint):void
        {
            _barW = value;

            // 更新滚动条最大停靠位置
            barMaxPosition.x = viewArea.width  - _barW;
            barMaxPosition.y = viewArea.height - _barW;
        }
        private var _barW:uint = 5;
        
        /**
         * 滚动条颜色(RRGGBB)
         * @default 0
         */
        public var barColor:uint = 0;

    }

}


class PathPoint
{
    public var x:Number;
    public var y:Number;
    public var t:int;

    public function PathPoint(x:Number, y:Number, t:int)
    {
        this.x = x;
        this.y = y;
        this.t = t;
    }
}
