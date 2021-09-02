using SqlSugar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.Model
{
    public class EmojiData
    {
        /// <summary>
        /// emoji编码
        /// </summary>
        [SugarColumn(IsPrimaryKey = true, IsNullable = false)]
        public string emojiCode { get; set; }

        /// <summary>
        /// emoji图片转rtf后的字符串
        /// </summary>
        [SugarColumn(IsNullable = false, Length = 1000)]
        public string emojiRtf { get; set; }


        /// <summary>
        /// 如果为0则底色为白色，为1则是绿色
        /// </summary>
        public int isMine { get; set; }

        #region 创建表
        /// <summary>
        /// 创建表
        /// </summary>
        public bool CreatEmojiTable()
        {
            using (var db = DBSetting.ConstantDBContext)
            {
                //创建数据库表
                try
                {
                    if (!db.Queryable<sqlite_master>().Where(s => s.Name == "EmojiData" && s.Type == "table").Any())
                    {
                        db.CodeFirst.SetStringDefaultLength(100).InitTables(typeof(EmojiData));
                    }

                    return true;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }
        #endregion

        public int InsertEmojiData()
        {
            if (string.IsNullOrEmpty(this.emojiCode))
                return 0;
            if (CreatEmojiTable())
            {
                using (var db = DBSetting.ConstantDBContext)
                {
                    //该msgId已存在
                    if (db.Queryable<EmojiData>().Where(m => m.emojiCode == this.emojiCode).Any())
                    {
                        return 0;
                    }

                    var result = db.Insertable(this).ExecuteCommand();
                    return result;
                }
            }
            return 0;
        }

        public int UpdateEmojiData()
        {
            if (string.IsNullOrEmpty(this.emojiCode))
                return 0;
            if (CreatEmojiTable())
            {
                using (var db = DBSetting.ConstantDBContext)
                {
                    return db.Updateable(this).ExecuteCommand();
                }
            }
            return 0;
        }

        public List<EmojiData> GetEmojiDataByIsMin()
        {
            if (CreatEmojiTable())
            {
                using (var db = DBSetting.ConstantDBContext)
                {
                    var list = db.Queryable<EmojiData>().Where(e => e.isMine == isMine).ToList();
                    return list == null ? new List<EmojiData>() : list;
                }
            }
            return new List<EmojiData>();
        }

        /// <summary>
        /// Emoji集合转字典
        /// <para>key: emojiCode, value: emojiRtf</para>
        /// </summary>
        /// <param name="list"></param>
        /// <returns></returns>
        public Dictionary<string, string> ListToDictionary(List<EmojiData> list)
        {
            Dictionary<string, string> emojiDic = new Dictionary<string, string>();
            foreach (EmojiData item in list)
            {
                int index = item.emojiCode.IndexOf("_");
                string key = item.emojiCode.Remove(index);
                emojiDic.Add(key, item.emojiRtf);
            }
            return emojiDic;
        }
    }
}
