using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

public class UploadEngine
{
    private UploadEngine()
    {
       
    }

    private static UploadEngine _instance;
    public static UploadEngine Instance => _instance ?? (_instance = new UploadEngine());


    public UploadFileBuild From(string filePath)
    {
        var build = new UploadFileBuild(filePath);
        return build;

    }
    
}
