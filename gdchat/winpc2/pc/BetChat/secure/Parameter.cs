using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WinFrmTalk.secure
{
    // 组合验参 asell排序key  帮助类
   public class Parameter
    {
        public static string JoinValues(Dictionary<string, string> hashMap)
        {
            if (hashMap != null && hashMap.Count > 0)
            {
                StringBuilder sb = new StringBuilder();

                // 第一步：把字典按Key的字母顺序排序
                IDictionary<string, string> sortedParams = new SortedDictionary<string, string>(hashMap);
                IEnumerator<KeyValuePair<string, string>> dem = sortedParams.GetEnumerator();

                // 第二步：把所有参数名和参数值串在一起
                StringBuilder query = new StringBuilder("");
                while (dem.MoveNext())
                {
                    string value = dem.Current.Value;
                    sb.Append(value);
                }
                return sb.ToString();
            }

            return "";
        }


    }
}
