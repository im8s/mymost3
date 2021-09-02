using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class DownloadEngine
{
    private DownloadEngine()
    {

    }

    private static DownloadEngine _instance;
    public static DownloadEngine Instance => _instance ?? (_instance = new DownloadEngine());


    public DownloadBuild DownUrl(string url)
    {
        var build = new DownloadBuild(url);
        return build;

    }



}
