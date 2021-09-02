using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace WinFrmTalk
{
    public class JsonFileinfo
    {
        #region 构造方法
        public JsonFileinfo()
        {
            data = new DataOfFile();
        }
        #endregion


        /// <summary>
        /// 返回的数据
        /// </summary>
        public DataOfFile data { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int failure { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int resultCode { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int success { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int time { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int total { get; set; }

        internal string getImageUpPath()
        {
            if (resultCode == 1)
            {
                return data.images[0].oUrl;
            }

            return "";
        }
    }


    #region DataOfFile
    /// <summary>
    /// 此类用于
    /// </summary>
    public class DataOfFile
    {
        #region 重写构造函数
        public DataOfFile()
        {
            audios = new List<Resource>();
            images = new List<Resource>();
            others = new List<Resource>();
            videos = new List<Resource>();
        }
        #endregion
        [Key]
        public string id { get; set; }
        /// <summary>
        /// 音频s
        /// </summary>
        public List<Resource> audios { get; set; }

        /// <summary>
        /// 图片s
        /// </summary>
        public List<Resource> images { get; set; }

        /// <summary>
        /// 其他(也就是文件)s
        /// </summary>
        public List<Resource> others { get; set; }

        /// <summary>
        /// 视频s
        /// </summary>
        public List<Resource> videos { get; set; }

        public List<Resource> files { get; set; }

    }
    #endregion

    #region Resource
    /// <summary>
    /// 资源
    /// </summary>
    public class Resource
    {
        [Key]
        public string id { get; set; }
        /// <summary>
        /// 播放时长
        /// </summary>
        public long length { get; set; }

        /// <summary>
        /// 原始URL
        /// </summary>
        public string oUrl { get; set; }

        /// <summary>
        /// 缩略URL
        /// </summary>
        public string tUrl { get; set; }

        /// <summary>
        /// 文件大小
        /// </summary>
        public long size { get; set; }
    }
    #endregion

}
