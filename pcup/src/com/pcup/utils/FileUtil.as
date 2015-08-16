package com.pcup.utils
{
    import flash.filesystem.File;
    
    /**
     * @author phx
     * @createTime Sep 27, 2014 4:49:32 PM
     */
    public class FileUtil
    {
        /** Useful for the devices that can't load resouce with File.applicationDirectory prefix. */
        static public function tryToRemoveAppDirPrefix(fileURL:String):String
        {
            var appDirURL:String;
            appDirURL = File.applicationDirectory.url;
            if (fileURL.match(appDirURL)) return String(fileURL).substr(appDirURL.length);
            appDirURL = File.applicationDirectory.nativePath + "/";
            if (fileURL.match(appDirURL)) return String(fileURL).substr(appDirURL.length);
            return fileURL;
        }
        
        static public function exists(fileURL:String):Boolean
        {
            return (new File(fileURL)).exists;
        }
        
        static public function getImageURLsInDirectorys(dirURLs:Array, sort:Boolean = true):Array
        {
            var arr:Array = [];
            for each (var i:* in dirURLs) 
                arr = arr.concat(getImageURLsInDirecotry(String(i)));
            if (sort) arr.sort();
            return arr;
        }
        
        static private function getImageURLsInDirecotry(dirURL:String, sort:Boolean = true):Array
        {
            var f:File = new File(dirURL);
            if (!f.exists)
            {
                trace("[WARNING] File not exist:", dirURL);
                return [];
            }
            var list:Array = f.getDirectoryListing();
            var urls:Array = [];
            for each (f in list) if (f.extension && (f.extension.toLowerCase() == "jpg" || f.extension.toLowerCase() == "png"))
                urls.push(dirURL + "/" + f.name);
            if (sort) urls.sort();
            return urls;
        }
        
        static public function getSubDirURLs(dirURL:String, sort:Boolean = true):Array
        {
            var f:File = new File(dirURL);
            if (!f.exists)
            {
                trace("[WARNING] File not exist:", dirURL);
                return [];
            }
            var list:Array = f.getDirectoryListing();
            var urls:Array = [];
            for each (f in list) if (f.isDirectory)
                urls.push(dirURL + "/" + f.name);
            if (sort) urls.sort();
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