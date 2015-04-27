package com.pcup.net 
{
    import flash.display.Stage;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    
    /** 地址和端口绑定成功 */   [Event(name = "bindSuccess"   , type = "com.pcup.net.TCPCommunication")];
    /** 地址和端口绑定失败 */   [Event(name = "bindFail"      , type = "com.pcup.net.TCPCommunication")];
    /** 与服务端连接成功   */   [Event(name = "connectSuccess", type = "com.pcup.net.TCPCommunication")];
    /** 与服务端连接失败   */   [Event(name = "connectFail"   , type = "com.pcup.net.TCPCommunication")];
    /** 数据发送成功       */   [Event(name = "sendSuccess"   , type = "com.pcup.net.TCPCommunication")];
    /** 数据发送失败       */   [Event(name = "sendFail"      , type = "com.pcup.net.TCPCommunication")];
    /** 被客户端连接上     */   [Event(name = "beConnected"   , type = "com.pcup.net.TCPCommunication")];
    /** 连接断开           */   [Event(name = "close"         , type = "com.pcup.net.TCPCommunication")];
    /** 传输进度. 通过 TCPCommunication.process 获取此数据 */
    [Event(name = "process", type = "com.pcup.net.TCPCommunication")];
    /** 数据接收完成. 通过 TCPCommunication.receiveData 获取此数据 */
    [Event(name = "receiveSuccess", type = "com.pcup.net.TCPCommunication")];
    /** 出现错误 */
    [Event(name = "error", type = "flash.events.ErrorEvent")]
    
    
    /**
     * TCP通讯
     * 
     *      命令: 数据头标记 + 数据尺寸标记(Double) + 数据类型标记(int) +                            命令值(uint) + 数据尾标记
     *  传输进度: 数据头标记 + 数据尺寸标记(Double) + 数据类型标记(int) +                            进度值(uint) + 数据尾标记
     *    String: 数据尾标记 + 数据尺寸标记(Double) + 数据类型标记(int) +                        字符串(UTFBytes) + 数据尾标记
     * ByteArray: 数据头标记 + 数据尺寸标记(Double) + 数据类型标记(int) + 宽(int) + 高(int) + 图片数据(ByteArray) + 数据尾标记
     * 
	 * 下面是一个简单的使用示例。
<listing version="3.0">
tcp.addEventListener(TCPCommunication.CONNECT_SUCCESS, trace);
tcp.addEventListener(TCPCommunication.CONNECT_FAIL   , trace);
tcp.addEventListener(TCPCommunication.SEND_FAIL      , trace);
tcp.addEventListener(TCPCommunication.CLOSE          , trace);
tcp.addEventListener(TCPCommunication.PROCESS        , processHandler);
tcp.addEventListener(TCPCommunication.SEND_SUCCESS   , processHandler);
tcp.addEventListener(TCPCommunication.RECEIVE_SUCCESS, receiveHandler);

// 作为服务端
tcp.bind("127.0.0.1", 8182);
// 作为客户端
//tcp.connect("127.0.0.1", 8182);

private function receiveHandler(e:Event):void 
{
    var receiveData:Object = (e.currentTarget as TCPCommunication).receiveData;
}
private function processHandler(e:Event):void 
{
    trace((e.currentTarget as TCPCommunication).process / 100);
}
private function errorHandler(e:ErrorEvent):void 
{
    trace(e.text);
}
</listing>
     * 
     * @author pihao
     */
    public class TCPCommunication extends EventDispatcher
    {
        // ------------------------------------------------------------------------------------------------------------- 事件类型
        static public const BIND_SUCCESS    :String = "bindSuccess";
        static public const BIND_FAIL       :String = "bindFail";
        static public const CONNECT_SUCCESS :String = "connectSuccess";
        static public const CONNECT_FAIL    :String = "connectFail";
        static public const SEND_SUCCESS    :String = "sendSuccess";
        static public const SEND_FAIL       :String = "sendFail";
        static public const BE_CONNECTED    :String = "beConnected";
        static public const CLOSE           :String = "close";
        static public const PROCESS         :String = "process";
        static public const RECEIVE_SUCCESS :String = "receiveSuccess";
        
        // ------------------------------------------------------------------------------------------------------------- 通讯标记
        /** 数据头标记                     */  static private const DATA_START             :String = "DATA_START"; 
        /** 数据尾标记                     */  static private const DATA_END               :String = "DATA_END";
        /** 数据类型标记 - [私有]命令      */  static private const TYPE_COMMAND           :int = 1;
        /** 数据类型标记 - [私有]传输进度  */  static private const TYPE_PROCESS           :int = 2;
        /** 数据类型标记 - [公共]String    */  static private const TYPE_STRING            :int = 3;
        /** 数据类型标记 - [公共]ByteArray */  static private const TYPE_BYTE_ARRAY        :int = 4;
        /** 命令 - 数据接收完成            */  static private const COMMAND_RECEIVE_SUCCESS:int = 1;
        
        
        
        private var socket:Socket;
        private var serverSocket:ServerSocket;
        /** `数据尺寸标记(Double)`在 ByteArray 中所占长度为8 */
        static private const SIZE_MARK_LONG:uint = 8;
        
        /** 接收到的数据(String/ByteArray) */
        public var receiveData:Object;
        /** 进度(0~100) */
        public var process:uint;
        
        /** 每次接收的数据都合并到这里 */
        private var allBytes:ByteArray = new ByteArray();
        /** 数据尺寸 */
        private var size:Number;
        /** 是否正在接收数据 */
        private var isProcessing:Boolean;
        
        
        /**
         * 创建一个新的 TCPCommunication 实例
         * @param stage 舞台对象. 用于监听在窗口关闭时释放端口
         */
        public function TCPCommunication(stage:Stage) 
        {
            // 窗口关闭时释放占用端口
            stage.nativeWindow.addEventListener(Event.CLOSE, function():void
            {
                if (serverSocket && serverSocket.bound) serverSocket.close();
            });
        }
        
        /**
         * [客户端]连接服务端. 
         * <p>如果当前有连接, 或者已经绑定本地端口. 此方法会先断开所有连接并释放端口, 然后再按参数创建一个新连接.</p>
         * @param host  地址
         * @param port  端口
         */
        public function connect(host:String, port:int):void 
        {
            reset();
            
            // 创建新实例
            socket = new Socket();
            socket.addEventListener(Event.CLOSE                      , closeHandler);
            socket.addEventListener(IOErrorEvent.IO_ERROR            , connetFailHandler);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, connetFailHandler);
            socket.addEventListener(Event.CONNECT                    , connetSuccessHandler);
            socket.addEventListener(ProgressEvent.SOCKET_DATA        , dataHandler);
            
            socket.connect(host, port);
        }
        
        /**
         * [服务端]绑定指定地址和端口
         * <p>如果当前有连接, 或者已经绑定本地端口. 此方法会先断开所有连接并释放端口, 然后再按参数重新绑定.</p>
         * @param host  地址
         * @param port  端口
         */
        public function bind(host:String, port:int):void 
        {
            reset();
            
            try 
            {
                serverSocket = new ServerSocket();
                serverSocket.bind(port, host);
                serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, beConnectHandler);
                serverSocket.listen();
                dispatchEvent(new Event(TCPCommunication.BIND_SUCCESS));
            }
            catch (er:Error)
            {
                reset();
                dispatchEvent(new Event(TCPCommunication.BIND_FAIL));
            }
        }
        
        
        /** [客户端/服务端]接收到数据 */
        private function dataHandler(e:ProgressEvent):void 
        {
            // 取得本次数据包
            var bytes:ByteArray = new ByteArray();
            socket.readBytes(bytes);
            
            // 如果是正在接收数据, 则立即计算进度
            if (isProcessing)
            {
                // 计算进度
                process = uint(((allBytes.length + bytes.length) / size) * 100);
                // 把进度返回给发送端
                send(process, TYPE_PROCESS);
                // 抛出进度事件
                dispatchEvent(new Event(TCPCommunication.PROCESS));
            }
            
            
            // 取头标记
            bytes.position = 0;
            var start:String = bytes.readUTFBytes(DATA_START.length);
            // 取尾标记
            bytes.position = bytes.length - DATA_END.length;
            var end:String = bytes.readUTFBytes(bytes.bytesAvailable);
            
            
            // 如果有头标记
            if (start == DATA_START)
            {
                // 重置参数
                isProcessing = true;
                allBytes.clear();
                
                // 取得数据尺寸
                bytes.position = DATA_START.length;
                size = bytes.readDouble();
            }
            // 如果有尾标记
            if (end == DATA_END)
            {
                if (isProcessing) 
                {
                    // 数据合并数据
                    allBytes.writeBytes(bytes);
                    
                    // 取得数据类型
                    allBytes.position = DATA_START.length + SIZE_MARK_LONG;
                    var type:int = allBytes.readInt();
                    
                    // [私有]命令
                    if (type == TYPE_COMMAND)
                    {
                        var command:uint = allBytes.readUnsignedInt();
                        if (command == COMMAND_RECEIVE_SUCCESS)
                        {
                            dispatchEvent(new Event(TCPCommunication.SEND_SUCCESS));
                        }
                    }
                    // [私有]传输进度
                    else if (type == TYPE_PROCESS)
                    {
                        process = allBytes.readUnsignedInt();
                        dispatchEvent(new Event(TCPCommunication.PROCESS));
                    }
                    // [公共]String
                    else if (type == TYPE_STRING)
                    {
                        receiveData = allBytes.readUTFBytes(allBytes.bytesAvailable - DATA_END.length);
                        dispatchEvent(new Event(TCPCommunication.RECEIVE_SUCCESS));
                        send(COMMAND_RECEIVE_SUCCESS, TYPE_COMMAND);
                    }
                    // [公共]ByteArray
                    else if (type == TYPE_BYTE_ARRAY)
                    {
                        receiveData = new ByteArray();  allBytes.readBytes(receiveData as ByteArray, 0, allBytes.bytesAvailable - DATA_END.length);
                        dispatchEvent(new Event(TCPCommunication.RECEIVE_SUCCESS));
                        send(COMMAND_RECEIVE_SUCCESS, TYPE_COMMAND);
                    }
                    // 未知类型
                    else
                    {
                        dispError("接收到未知类型的数据");
                    }
                }
                
                isProcessing = false;
            }
            // 如果没有尾标记(即中间内容或者第一个包)
            else
            {
                // 数据合并数据
                if (isProcessing) allBytes.writeBytes(bytes);
            }
        }
        /** [客户端/服务端]连接关闭 */
        private function closeHandler(e:Event):void 
        {
            dispatchEvent(new Event(TCPCommunication.CLOSE));
            
            if (isProcessing) dispatchEvent(new Event(TCPCommunication.SEND_FAIL));
        }
        
        
        /** [客户端]服务端连接成功 */
        private function connetSuccessHandler(e:Event):void 
        {
            dispatchEvent(new Event(TCPCommunication.CONNECT_SUCCESS));
        }
        /** [客户端]服务端连接失败 */
        private function connetFailHandler(e:Event):void 
        {
            dispatchEvent(new Event(TCPCommunication.CONNECT_FAIL));
        }
        
        
        /** [服务端]被客户端连接 */
        private function beConnectHandler(e:ServerSocketConnectEvent):void 
        {
            socket = e.socket;
            socket.addEventListener(Event.CLOSE              , closeHandler);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
            
            dispatchEvent(new Event(TCPCommunication.BE_CONNECTED));
        }
        
        
        /**
         * [客户端/服务端]发送数据
         * @param   data   要发送的数据
         * @param   type   发送数据的类型(从`数据类型标记`取值)
         */
        private function send(data:Object, type:int):void 
        {
            if (!socket || !socket.connected)
            {
                dispatchEvent(new Event(TCPCommunication.SEND_FAIL));
                return;
            }
            
            // 准备添加类型标记, 并把数据都转换为 ByteArray 类型
            var bytes:ByteArray = new ByteArray();
            
            // [私有]命令
            if (type == TYPE_COMMAND)
            {
                bytes.writeInt(TYPE_COMMAND);
                if (data is uint) bytes.writeUnsignedInt(data as uint);
            }
            // [私有]传输进度
            else if (type == TYPE_PROCESS)
            {
                bytes.writeInt(TYPE_PROCESS);
                if (data is uint) bytes.writeUnsignedInt(data as uint);
            }
            // [公共]String
            else if (type == TYPE_STRING)
            {
                bytes.writeInt(TYPE_STRING); 
                if (data is String) bytes.writeUTFBytes(data as String);
            }
            // [公共]ByteArray
            else if (type == TYPE_BYTE_ARRAY)
            {
                bytes.writeInt(TYPE_BYTE_ARRAY);
                if (data is ByteArray) bytes.writeBytes(data as ByteArray);
            }
            else 
            {
                trace("[私有]发送的数据类型不正确");
                return;
            }
            
            // 添加其它标记(头+尺寸+尾)
            var tmp:ByteArray = new ByteArray();
            tmp.writeUTFBytes(DATA_START);
            tmp.writeDouble(DATA_START.length + SIZE_MARK_LONG + bytes.length + DATA_END.length);
            tmp.writeBytes(bytes);
            tmp.writeUTFBytes(DATA_END);
            
            // 发送数据
            socket.writeBytes(tmp);
            socket.flush();
        }
        /**
         * 发送数据(String/ByteArray)
         * @param   data  要发送的数据(String/ByteArray)
         */
        public function sendData(data:Object):void
        {
                 if (data is String   ) send(data, TYPE_STRING);
            else if (data is ByteArray) send(data, TYPE_BYTE_ARRAY);
            else
            {
                dispatchEvent(new Event(TCPCommunication.SEND_FAIL));
                dispError("发送的数据类型不正确");
            }
        }
        /** 连接状态 */
        public function get connected():Boolean
        {
            return socket.connected;
        }
        
        
        
        /** 重置.
         * <p>断开已有连接并释放端口.</p>
         */
        public function reset():void
        {
            if (socket)
            {
                if (socket.connected) socket.close();
                socket.removeEventListener(Event.CLOSE                      , closeHandler);
                socket.removeEventListener(IOErrorEvent.IO_ERROR            , connetFailHandler);
                socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connetFailHandler);
                socket.removeEventListener(Event.CONNECT                    , connetSuccessHandler);
                socket.removeEventListener(ProgressEvent.SOCKET_DATA        , dataHandler);
                socket = null;
            }
            if (serverSocket)
            {
                if (serverSocket.bound) serverSocket.close();
                serverSocket.removeEventListener(ServerSocketConnectEvent.CONNECT, beConnectHandler);
                serverSocket = null;
            }
        }
        
        
        
        /**
         * 抛出错误
         * @param  text  错误内容
         */
        private function dispError(text:String):void 
        {
            var e:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);
            e.text = text;
            dispatchEvent(e);
        }
        
    }
    
}