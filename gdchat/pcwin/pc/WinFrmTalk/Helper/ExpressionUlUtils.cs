using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WinFrmTalk.Model;

namespace WinFrmTalk.Helper
{
    class ExpressionUlUtils
    {
       

     /// <summary>
     /// 
     /// </summary>
     /// <param name="pageIndex">页索引</param>
     /// <param name="pagesize">页数量</param>
        internal static void ExrpressionList( int pageIndex,int pagesize)
        {
            string userid= Applicate.MyAccount.userId;
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "user/emoji/list") 
            .AddParams("access_token", Applicate.Access_Token)
            .AddParams("userId", userid)
            .AddParams("pageIndex", pageIndex.ToString())
            .AddParams("pageSize", pagesize.ToString())
                .Build().AddErrorListener((code, err) =>
                {
                   
                })
                .Execute((sccess, room) =>
                {
                    if (sccess)
                    {
                        //将room解析
                       var members = JsonConvert.DeserializeObject<List<object>>(room["data"].ToString());
                       
                        foreach( var item in members)
                        {
                            var member = JsonConvert.DeserializeObject<Dictionary<string, object>>(item.ToString());
                            /*collectType
                            createTime
                            emojiId
                            fileLength
                            fileSize
                            msg
                            type
                            url
                            userId*/

                        }
                     
                    }
                });
        }
        /// <summary>
        /// 删除自定义表情
        /// </summary>
       internal static void RemoveExpression( string emojiId)
        {

            if (emojiId == null)
            {
                return;
            }
           
            string userid = Applicate.MyAccount.userId;
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "/user/emoji/delete") //获取群详情
            .AddParams("access_token", Applicate.Access_Token)
              .AddParams("emojiId", emojiId)

                .Build().AddErrorListener((code, err) =>
                {

                })
                .Execute((sccess, room) =>
                {
                    if (sccess)
                    {


                    }
                });
        }
    }
}
