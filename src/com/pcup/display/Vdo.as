package com.pcup.display
{
	import com.pcup.fw.events.DataEvent;
	import com.pcup.fw.hack.Sprite;

	import flash.display.Shape;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;


    [Event(name = "error", type = "com.pcup.fw.events.DataEvent")]
    /** video information */
    [Event(name="data" type="com.pcup.fw.events.DataEvent")]


	/**
     * Video player
     *
	 * Demo:
<listing version="3.0">
var v:Vdo = new Vdo(600, 400);
addChild(v);
v.addEventListener(ErrorEvent.ERROR, trace);
v.addEventListener(Vdo.META_DATA, onMeta);
v.open("d:/video/foo.flv");

stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown);

private function onDown(e:KeyboardEvent):void
{
    switch (e.keyCode)
    {
        case Keyboard.SPACE:
            v.togglePause();
        break;
        case Keyboard.LEFT:
            v.seek(v.time - 5);
        break;
        case Keyboard.RIGHT:
            v.seek(v.time + 5);
        break;
        case Keyboard.A:
            v.seek(10);
        break;
        default:
    }
}
private function onMeta(e:Event):void
{
    trace("video duration:" + v.duration);
}
</listing>
     *
     * @author pihao
     */
    public class Vdo extends Sprite
    {
        private var video:Video;
		private var nc:NetConnection;
		private var ns:NetStream;

        private var viewArea:Rectangle;
        private var _duration:Number = 0;
        private var vdoURL:String;


        public function Vdo(viewWidth:uint = 320, viewHeight:uint = 240)
        {
            viewArea = new Rectangle(0, 0, viewWidth, viewHeight);

            var s:Shape = new Shape();
            s.graphics.beginFill(0);
            s.graphics.drawRect(0, 0, viewArea.width, viewArea.height);
            s.graphics.endFill();
            addChild(s);

			video = new Video();
			video.smoothing = true;
			addChild(video);

			nc = new NetConnection();
			nc.client = new Object();
            addNCListenner();
            nc.connect(null);
        }

        public function open(vdoURL:String):void
        {
            if (!nc.connected) dispError("no connection");

            reset();

			ns = new NetStream(nc);
			ns.client = new Object();
			ns.client.onMetaData = onMetaData;
            addNSListenner();
			video.attachNetStream(ns);

            this.vdoURL = vdoURL;
			ns.play(vdoURL);
		}

        private function addNCListenner():void
        {
            nc.addEventListener(IOErrorEvent.IO_ERROR            , errorHandler);
            nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            nc.addEventListener(NetStatusEvent.NET_STATUS        , netStatusHandler);
        }
        private function removeNCListenner():void
        {
            nc.removeEventListener(IOErrorEvent.IO_ERROR            , errorHandler);
            nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            nc.removeEventListener(NetStatusEvent.NET_STATUS        , netStatusHandler);
        }

        private function addNSListenner():void
        {
            ns.addEventListener(IOErrorEvent.IO_ERROR    , errorHandler);
            ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        }
        private function removeNSListenner():void
        {
            ns.removeEventListener(IOErrorEvent.IO_ERROR    , errorHandler);
            ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        }

        public function play():void
        {
            if (!videoReady) return;
            ns.resume();
        }
        public function pause():void
        {
            if (!videoReady) return;
            ns.pause();
        }
        public function togglePause():void
        {
            if (!videoReady) return;
            ns.togglePause();
        }
        public function stop():void
        {
            if (!videoReady) return;
            ns.seek(0);
            ns.pause();
        }

        /**
         * specify time to play (unit: second)
         */
        public function seek(offset:Number):void
        {
            if (!videoReady) return;
            if      (offset < 0        ) offset = 0;
            else if (offset > _duration) offset = _duration;

            ns.seek(offset);
        }

        /** 0~1 */
        public function get volume():Number
        {
            if (!videoReady) return 1;
            return ns.soundTransform.volume;
        }
        public function set volume(value:Number):void
        {
            if (!videoReady) return;

                 if (value < 0) value = 0;
            else if (value > 1) value = 1;

            var st:SoundTransform = ns.soundTransform;
            st.volume = value;
            ns.soundTransform = st;
        }

        public function get time():Number
        {
            if (!videoReady) return 0;
            else             return ns.time;
        }

        public function get duration():Number
        {
            return _duration;
        }

        override public function dispose():void
        {
            super.dispose();
            if (nc)
            {
                removeNCListenner();
                try {nc.close();} catch(er:Error){}
                nc = null;
            }
            if (ns)
            {
                removeNSListenner();
                ns.dispose();
                ns = null;
            }
        }

        private function get videoReady():Boolean
        {
            if (!nc.connected)
            {
                dispError("no connection");
                return false;
            }
            if (!ns)
            {
                dispError("no open video");
                return false;
            }

            return true;
        }

        private function reset():void
        {
			if (ns)
			{
                ns.dispose();
				ns = null;
			}

            video.width  = viewArea.width;
            video.height = viewArea.height;

            _duration = 0;
        }


        private function netStatusHandler(e:NetStatusEvent):void
		{
            switch (e.info.code)
			{
                case "NetStream.Play.Start":
                case "NetStream.Unpause.Notify":
                    // Start, Unpause
                    break;
                break;
                case "NetStream.Pause.Notify":
                    // Pause
                    break;
                case "NetStream.Play.Stop":
                    // Play over
                    stop();
                break;
                case "NetConnection.Connect.Success":
                break;
                case "NetConnection.Connect.Failed":
                case "NetConnection.Connect.Rejected":
					dispError("connect fail");
                break;
				case "NetStream.Play.StreamNotFound":
					dispError("video not found: " + vdoURL);
                break;
            }
        }
        /**
         * @param info video information (_duration/width/height/framerate ...)
         */
        public function onMetaData(info:Object):void
		{
			//trace("metadata: _duration=" + info._duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);

			if (info._duration == 0 || info.width == 0 || info.height == 0) return;

            _duration = info.duration;

			if (info.width / info.height > viewArea.width / viewArea.height)
			{
				video.width  = viewArea.width;
				video.height = video.width * (info.height / info.width);
			} else {
				video.height = viewArea.height;
				video.width  = video.height * (info.width / info.height);
			}

			video.x = viewArea.x + (viewArea.width - video.width) / 2;
			video.y = viewArea.y + (viewArea.height - video.height) / 2;

            dispatchEvent(new DataEvent(DataEvent.DATA, info));
		}


        private function errorHandler(e:ErrorEvent):void
        {
            dispError(e.text);
        }

        private function dispError(text:String):void
        {
            var e:DataEvent = new DataEvent(DataEvent.ERROR);
            e.data = text;
            dispatchEvent(e);
        }

    }

}
