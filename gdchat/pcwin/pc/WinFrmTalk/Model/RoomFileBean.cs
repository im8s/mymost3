using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class JsonRoomFileList
{
    public JsonRoomFileList()
    {
        data = new List<RoomFileBean>();
    }

    public List<RoomFileBean> data { get; set; }
}

public class RoomFileBean
{
    /// <summary>
    /// 
    /// </summary>
    public string name { get; set; }
    /// <summary>
    /// bbh哈
    /// </summary>
    public string nickname { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string roomId { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string shareId { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public long size { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public double time { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public int type { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string url { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string userId { get; set; }
}

