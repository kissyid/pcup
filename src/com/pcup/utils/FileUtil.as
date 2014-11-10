package com.pcup.utils
{
    import flash.filesystem.File;
    
    /**
     * @author phx
     * @createTime Sep 27, 2014 4:49:32 PM
     */
    public class FileUtil
    {
        /** Useful for Apple device */
        static public function tryToRemoveAppDirPrefix(fileURL:String):String
        {
            var appDirURL:String = File.applicationDirectory.nativePath + "/";
            if (fileURL.match(appDirURL)) return String(fileURL).substr(appDirURL.length);
            return fileURL;
        }
        
        static public function exists(fileURL:String):Boolean
        {
            return (new File(fileURL)).exists;
        }
        
        static public function getImageURLsInDirectorys(dirURLs:Array):Array
        {
            var arr:Array = [];
            for each (var i:* in dirURLs) 
                arr = arr.concat(getImageURLsInDirecotry(String(i)));
            return arr;
        }
        
        static private function getImageURLsInDirecotry(dirURL:String):Array
        {
            var f:File = new File(dirURL);
            if (!f.exists) return [];
            var list:Array = f.getDirectoryListing();
            var urls:Array = [];
            for each (f in list) if (f.extension && (f.extension.toLowerCase() == "jpg" || f.extension.toLowerCase() == "png"))
                urls.push(dirURL + f.name);
            return urls;
        }
        
        static public function getSubDirURLs(dirURL:String):Array
        {
            var f:File = new File(dirURL);
            if (!f.exists) return [];
            var list:Array = f.getDirectoryListing();
            var urls:Array = [];
            for each (f in list) if (f.isDirectory)
                urls.push(dirURL + f.name + "/");
            return urls;
        }
        
        static public function getFileName(url:String):String
        {
            var f:File = new File(url);
            if (!f.exists) return null;
            return f.name;
        }
        static public function getFileExtention(url:String):String
        {
            var f:File = new File(url);
            if (!f.exists) return null;
            return f.extension;
        }
        
    }
}