package com.pcup.display
{
    import com.greensock.TweenLite;
    import com.pcup.fw.events.DataEvent;
    import com.pcup.fw.hack.Sprite;
    import com.pcup.utils.FileUtil;
    
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    /** page change */
    [Event(name="change" type="com.pcup.fw.events.DataEvent")]
    
    /**
     * @author phx
     * @createTime Oct 6, 2014 12:38:34 AM
     */
    public class SlidePage extends Sprite
    {
        static public var slideMin:int = 20; // pixel
        
        private var urls:Array;
        private var pages:Vector.<Page> = new Vector.<Page>;
        private var _currentPageIndex:int = 0;
        private var currentPage:Page;
        
        private var moveLength:int;
        private var downPageXs:Array;
        private var downMouseX:int;

        public function SlidePage(dirURL:String, viewWidth:uint, viewHeight:uint, gap:int = 20)
        {
            super();
            urls = FileUtil.getImageURLsInDirectorys([dirURL]);
            _viewArea = new Rectangle(0, 0, viewWidth, viewHeight);
            
            moveLength = viewArea.width + gap;
            Page.viewArea = viewArea;
            
            var s:Shape = new Shape();
            s.graphics.beginFill(0);
            s.graphics.drawRect(0, 0, viewArea.width, viewArea.height);
            s.graphics.endFill();
            addChild(s);
            mask = s;
            
            if (urls.length == 0) return;
            initPage();
            addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
        
        private function onDown(e:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
            stage.addEventListener(MouseEvent.ROLL_OUT, onUp);
            downPageXs = [];
            for each (var page:Page in pages) 
                downPageXs.push(page.x);
            downMouseX = stage.mouseX;
        }
        
        private function onMove(e:MouseEvent):void
        {
            for (var i:int in pages) 
                pages[i].x = downPageXs[i] + (stage.mouseX - downMouseX);
        }
        
        private function onUp(e:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
            stage.removeEventListener(MouseEvent.ROLL_OUT, onUp);
            
            if (stage.mouseX - downMouseX < -slideMin && currentPageIndex + 1 < urls.length)
            {
                turnPage(1);
            }
            else if (stage.mouseX - downMouseX > slideMin && currentPageIndex - 1 >= 0)
            {
                turnPage(-1);
            }
            else
            {
                mouseOff();
                for (var i:int in pages) 
                {
                    if (i == 0)
                        TweenLite.to(pages[i], .2, {x:downPageXs[i], onComplete:mouseOn});
                    else
                        TweenLite.to(pages[i], .2, {x:downPageXs[i]});
                }
            }
        }
        
        private function turnPage(offset:int):void
        {
            if (offset != -1 && offset != 1) return;
            
            mouseOff();
            for (var i:int in pages) 
            {
                if (i == 0)
                    TweenLite.to(pages[i], .2, {x:downPageXs[i] - moveLength * offset, onComplete:updatePage, onCompleteParams:[offset]});
                else
                    TweenLite.to(pages[i], .2, {x:downPageXs[i] - moveLength * offset});
            }
        }
        
        private function updatePage(offset:int):void
        {
            _currentPageIndex += offset;    
            dispatchEvent(new DataEvent(DataEvent.CHANGE, currentPageIndex));
            
            if (offset == -1)
            {
                currentPage = pages[0];
                if (pages.length > 2)
                {
                    (removeChild(pages.pop()) as Page).dispose();
                }
                if (currentPageIndex - 1 >= 0)
                {
                    var page:Page = new Page(urls[currentPageIndex - 1]);
                    page.x = -moveLength;
                    pages.unshift(addChild(page));
                }
            }
            else if (offset == 1)
            {
                currentPage = pages[pages.length - 1];
                if (pages.length > 2)
                {
                    (removeChild(pages.shift()) as Page).dispose();
                }
                if (currentPageIndex + 1 < urls.length)
                {
                    page = new Page(urls[currentPageIndex + 1]);
                    page.x = moveLength;
                    pages.push(addChild(page));
                }
            }
            mouseOn();
        }
        
        private function initPage():void
        {
            var page:Page = new Page(urls[0]);
            pages.push(addChild(page));
            currentPage = page;
            
            if (urls.length > 1)
            {
                page = new Page(urls[1]);
                page.x = moveLength;
                pages.push(addChild(page));
            }
        }
        
        private function mouseOn():void
        {
            this.mouseEnabled = this.mouseChildren = true;
        }
        private function mouseOff():void
        {
            this.mouseEnabled = this.mouseChildren = false;
        }
        
        override public function dispose():void
        {
            super.dispose();
            removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
            while (pages.length > 0) pages.pop().dispose();
        }

        public function get viewArea():Rectangle
        {
            return _viewArea;
        }
        private var _viewArea:Rectangle;
        
        public function get currentPageIndex():int
        {
            return _currentPageIndex;
        }
        public function get currentBitmapData():BitmapData
        {
            return currentPage.bitmapData;
        }
        
        public function get pageNum():int
        {
            return urls.length;
        }

        
    }
}


import com.pcup.fw.events.DataEvent;
import com.pcup.fw.hack.Sprite;
import com.pcup.utils.NumberUtil;
import com.pcup.utils.QueueLoader;
import com.pcup.utils.Res;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;


class Page extends Sprite
{
    public static var viewArea:Rectangle;
    private var loading:TextField;
    private var loader:QueueLoader;
    private var res:Res;
    private var _bitmapData:BitmapData = null;

    public function Page(url:String)
    {
        this.graphics.beginFill(0xffffff, .3);
        this.graphics.drawRect(0, 0, viewArea.width, viewArea.height);
        this.graphics.endFill();
        
        var t:TextField = new TextField();
        t.defaultTextFormat = new TextFormat(null, 32, 0xa0a0a0);
        t.autoSize = TextFieldAutoSize.LEFT;
        t.text = "LOADING...";
        t.x = viewArea.width - t.width >> 1;
        t.y = viewArea.height - t.height >> 1;
        t.mouseEnabled = false;
        addChild(t);
        loading = t;
        
        loader = new QueueLoader();
        loader.addEventListener(DataEvent.COMPLETE, onAllFramesLoaded);
        loader.load([url]);
    }
    
    private function onAllFramesLoaded(e:DataEvent):void
    {
        loader.removeEventListener(DataEvent.COMPLETE, onAllFramesLoaded);
        
        this.graphics.clear();
        this.graphics.beginFill(0, 0);
        this.graphics.drawRect(0, 0, viewArea.width, viewArea.height);
        this.graphics.endFill();
        
        removeChild(loading);
        
        res = e.data as Res;
        var bmp:Bitmap = res.getByNamePrefix("")[0];
        if (bmp)
        {
            NumberUtil.showAll(bmp, viewArea.width, viewArea.height);
            bmp.x = viewArea.width - bmp.width >> 1;
            bmp.y = viewArea.height - bmp.height >> 1;
            addChild(bmp);
            _bitmapData = bmp.bitmapData;
        }
    }
    
    override public function dispose():void
    {
        super.dispose();
        loader.removeEventListener(DataEvent.COMPLETE, onAllFramesLoaded);
        loader.dispose();
    }

    public function get bitmapData():BitmapData
    {
        return _bitmapData;
    }
    
}