package flexUnitTests.com.pcup.utils
{
    import com.pcup.utils.FrameScriptManager;
    
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.getDefinitionByName;
    
    import flexunit.framework.Assert;
    
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    
    public class FrameScriptManagerTest
    {
        private const RES_URL:String = "res/test.swf";
        private const MAX_LOAD_TIME:uint = 1000;
        private var _mc:MovieClip;
        private var _mng:FrameScriptManager;
        
        [Before]
        public function setUp():void
        {
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                var MC:Class = getDefinitionByName("mc.FrameScriptManagerTest") as Class;
                _mc = new MC();
                _mng = new FrameScriptManager(_mc);
            });
            l.load(new URLRequest(RES_URL), new LoaderContext(false, ApplicationDomain.currentDomain));
        }
        
        [After]
        public function tearDown():void
        {
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test(async)]
        public function testAddFrameScriptByFrame():void
        {
            testAddFrameScript(3);
        }
        
        [Test(async)]
        public function testAddFrameScriptByLabel():void
        {
            testAddFrameScript("third");
        }
        
        [Test(async)]
        public function testDestroy():void
        {
            Async.delayCall(this, function():void {
                assertNotNull("MovieClip Lost.", _mc);
                try {
                    _mng.destroy();
                } catch (er:Error) {
                    Assert.fail("Destroy failed: " + er.message);
                }
            }, MAX_LOAD_TIME);
        }
        
        
        private function testAddFrameScript(frame:*):void
        {
            Async.delayCall(this, function():void {
                assertNotNull("MovieClip Lost.", _mc);
                var executed:Boolean = false;
                _mng.addFrameScript(frame, function():void{
                    executed = true;
                });
                _mc.gotoAndStop(frame);
                assertTrue("Frame script not executed.", executed);
            }, MAX_LOAD_TIME);
        }
    }
}