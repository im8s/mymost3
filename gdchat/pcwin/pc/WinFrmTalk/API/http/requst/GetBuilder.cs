using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using WinFrmTalk;
using WinFrmTalk.Helper;
using WinFrmTalk.secure;

public class GetBuilder : BaseRequstBuilder
{
    private Dictionary<string, string> hashMap;

    /// <summary>
    /// 请求url
    /// </summary>
    public override BaseRequstBuilder Url(string url)
    {
        RequstUrl = url;
        return this;
    }

    /// <summary>
    /// 请求参数 依次拼接
    /// </summary>
    public override BaseRequstBuilder AddParams(string key, string value)
    {
        if (hashMap == null)
        {
            hashMap = new Dictionary<string, string>();
        }

        hashMap.Add(key, value);

        return this;
    }

    /// <summary>
    /// 请求参数
    /// </summary>
    public override BaseRequstBuilder AddParams(Dictionary<string, string> pari)
    {
        if (pari == null)
        {
            return this;
        }

        if (hashMap == null)
        {
            hashMap = pari;
        }
        else
        {
            foreach (var item in pari)
            {

                if (hashMap.ContainsKey(item.Key))
                {
                    hashMap[item.Key] = item.Value;
                }
                else
                {
                    hashMap.Add(item.Key, item.Value);
                }
            }
        }

        return this;
    }

    /// <summary>
    /// 编译
    /// </summary>
    /// <param name="beforeLogin">是否登陆前接口,用于接口加密</param>
    /// <returns></returns>
    public override BaseCall Build(bool beforeLogin = false)
    {
        // 接口加密系统
        HttpEncrypt(beforeLogin);

        RequstUrl = AppendParams();
        BaseCall call = new BaseCall(RequstUrl);
        call.AddErrorListener(mErrListener);
        call.NoErrorTip(noTip);
        return call;
    }

    /// <summary>
    /// 参数拼接
    /// </summary>
    private string AppendParams()
    {
        StringBuilder sb = new StringBuilder();
        sb.Append(RequstUrl);

        if (!UIUtils.IsNull(hashMap))
        {
            sb.Append("?");

            foreach (KeyValuePair<string, string> kvp in hashMap)
            {
                string value = HttpUtility.UrlEncode(kvp.Value, Encoding.UTF8);
                sb.Append(kvp.Key).Append("=").Append(value).Append("&");
            }
            sb = sb.Remove(sb.Length - 1, 1); // 去掉后面的&
        }

        string url = sb.ToString();
        LogUtils.Log("http 网络请求数据： " + url);
        return url;
    }

    /// <summary>
    /// 接口加密系统
    /// </summary>
    private void HttpEncrypt(bool beforeLogin)
    {
        if (hashMap != null && hashMap.ContainsKey("secret"))
        {
            if (!UIUtils.IsNull(Applicate.Access_Token))
            {
                hashMap.Add("access_token", Applicate.Access_Token);
            }
            return;
        }


        if (beforeLogin)
        {
            BeforeLoginParam();
            return;
        }


        string userId = null;
        if (UIUtils.IsNull(Applicate.Access_Token))
        {
            BeforeLoginParam();
            return;
        }

        if (Applicate.MyAccount == null || UIUtils.IsNull(Applicate.MyAccount.userId))
        {
            BeforeLoginParam();
            return;
        }
        else
        {
            userId = Applicate.MyAccount.userId;
        }


        if (UIUtils.IsNull(Applicate.HTTP_KEY))
        {
            BeforeLoginParam();
            return;
        }


        if (hashMap == null)
        {
            hashMap = new Dictionary<string, string>();
        }

        string salt = TimeUtils.CurrentTimeMillis().ToString();
        if (hashMap.ContainsKey("salt"))
        {
            salt = hashMap["salt"];
            hashMap.Remove("salt");
        }

        hashMap.Remove("access_token");
        string macContent = Applicate.API_KEY + userId + Applicate.Access_Token + Parameter.JoinValues(hashMap) + salt;
        string mac = MAC.EncodeBase64(macContent, Convert.FromBase64String(Applicate.HTTP_KEY));
        hashMap.Add("access_token", Applicate.Access_Token);
        hashMap.Add("salt", salt);
        hashMap.Add("secret", mac);
    }

    /// <summary>
    /// 登陆前验参
    /// </summary>
    private void BeforeLoginParam()
    {

        string salt = TimeUtils.CurrentTimeMillis().ToString();
        if (hashMap != null && hashMap.ContainsKey("salt"))
        {
            salt = hashMap["salt"];
            hashMap.Remove("salt");
        }

        string secret = string.Empty;

        string macContent = Applicate.API_KEY + Parameter.JoinValues(hashMap) + salt;
        byte[] key = MD5.Encrypt(Applicate.API_KEY);

        string mac = MAC.EncodeBase64(macContent, key);

        if (hashMap == null)
        {
            hashMap = new Dictionary<string, string>();
        }
        hashMap.Add("salt", salt);
        hashMap.Add("secret", mac);
    }
}
