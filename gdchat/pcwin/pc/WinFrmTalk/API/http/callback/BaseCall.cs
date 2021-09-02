using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk;

public class BaseCall
{

    private Action<int, string> mErrListener;
    private bool mNotTip;
    //private bool mNotLoding;

    public string requstUrl;
    public string tag;
    private long requestTime;


    public BaseCall(string url)
    {
        requstUrl = url;
    }

    public BaseCall AddErrorListener(Action<int, string> callback)
    {
        mErrListener = callback;
        return this;
    }

    public BaseCall BindTag(string tag)
    {
        this.tag = tag;
        return this;
    }


    public void NoErrorTip(bool noTip)
    {
        mNotTip = noTip;
    }


    public void NoLoading(bool loding)
    {
    }

    public void Execute(Action<bool, Dictionary<string, object>> callback)
    {

        requestTime = UIUtils.CurrentTimeMillis();
        Task.Factory.StartNew(() =>
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requstUrl);

                //Post请求方式
                request.Method = "GET";
                // 内容类型
                request.ContentType = "application/x-www-form-urlencoded";
                // 获得响应流
                HttpWebResponse response = (System.Net.HttpWebResponse)request.GetResponse();
                StreamReader myreader = new StreamReader(response.GetResponseStream(), Encoding.UTF8);

                if (IsCancelRequest())
                {
                    response.Close();
                    myreader.Close();
                    return;
                }
                // 获得数据
                string responseText = myreader.ReadToEnd();

                // 处理数据后回调回去
                HandleResponseData(responseText, false, callback);
            }
            catch (Exception)
            {
                OnError("网络不通，请检查线路或网卡", callback, -1);
                LogHelper.LogInfo("网络不通  requst :" + requstUrl);
            }
        });
    }

    public void ExecuteList<T>(Action<bool, T> callback)
    {
        requestTime = UIUtils.CurrentTimeMillis();
        Task.Factory.StartNew(() =>
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requstUrl);
                //Post请求方式
                request.Method = "GET";
                // 内容类型
                request.ContentType = "application/x-www-form-urlencoded";
                // 获得响应流
                HttpWebResponse response = (System.Net.HttpWebResponse)request.GetResponse();
                StreamReader myreader = new StreamReader(response.GetResponseStream(), Encoding.UTF8);

                if (IsCancelRequest())
                {
                    response.Close();
                    myreader.Close();
                    return;
                }
                // 获得数据
                string responseText = myreader.ReadToEnd();

                HandleResponseData(responseText, true, callback, true);
            }
            catch (Exception)
            {
                OnError("网络不通，请检查线路或网卡", callback, -1);
                LogHelper.LogInfo("网络不通  requst :" + requstUrl);
            }
        });

    }

    public void ExecuteJson<T>(Action<bool, T> callback)
    {
        requestTime = UIUtils.CurrentTimeMillis();
        Task.Factory.StartNew(() =>
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requstUrl);
                //Post请求方式
                request.Method = "GET";
                // 内容类型
                request.ContentType = "application/x-www-form-urlencoded";

                // 获得响应流
                HttpWebResponse response = (System.Net.HttpWebResponse)request.GetResponse();
                StreamReader myreader = new StreamReader(response.GetResponseStream(), Encoding.UTF8);
                // 获得数据

                if (IsCancelRequest())
                {
                    response.Close();
                    myreader.Close();
                    return;
                }
                string responseText = myreader.ReadToEnd();

                // 处理数据后回调回去
                HandleResponseData(responseText, true, callback);


                if (TimeUtils.SyncTimeDiff() == 0)
                {
                    // 先去解析第一层，获得服务器的resultCode
                    JObject jo = JsonConvert.DeserializeObject<JObject>(responseText);
                    long sTime = jo.Value<long>("currentTime"); // 这里有个坑，有些服务器会返回秒的时间戳
                    TimeUtils.SetTimeDiff(sTime);
                }

            }
            catch (Exception)
            {
                OnError("网络不通，请检查线路或网卡", callback, -1);
                LogHelper.LogInfo("网络不通  requst :" + requstUrl);
            }
        });
    }


    /// <summary>
    /// /得到服务器数据后的后续数据处理
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="responseText"></param>
    /// <param name="isResolve"></param>
    /// <param name="callback"></param>
    private void HandleResponseData<T>(string responseText, bool isResolve, Action<bool, T> callback, bool list = false)
    {

        if (IsCancelRequest())
        {
            return;
        }

        LogUtils.Log("http 服务器响应数据： " + responseText);

        if (callback == null && mErrListener == null)
        {    // 回调函数为空，不做任何处理
            return;
        }

        // 先去解析第一层，获得服务器的resultCode
        JObject jo = JsonConvert.DeserializeObject<JObject>(responseText);
        int code = jo.Value<int>("resultCode");

        if (code == CODE_SUCCESS)
        {
            try
            {
                // 没有data的情况
                if (!jo.ContainsKey("data") || jo["data"] == null)
                {
                    var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
                    // 不需要解析json, 直接返回
                    if (list)
                    {

                        OnError("接口数据解析出错", callback, code);
                    }
                    else
                    {
                        OnSuccess(data, callback);
                    }

                    return;
                }

                // data 为空的情况
                string beanJson = jo["data"].ToString();
                if (string.IsNullOrEmpty(beanJson))
                {
                    if (isResolve)
                    {
                        OnError("接口数据解析出错", callback, code);
                        LogHelper.LogInfo("接口数据解析出错  requst :" + requstUrl + "  \n response :" + responseText);
                    }
                    else
                    {
                        var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
                        // 不需要解析json, 直接返回
                        OnSuccess(data, callback);
                    }
                    return;
                }

                if (isResolve)
                {
                    // 需要解析
                    if (list)
                    {
                        T bean = JsonConvert.DeserializeObject<T>(responseText);
                        OnSuccess(bean, callback);
                    }
                    else
                    {
                        T bean = JsonConvert.DeserializeObject<T>(beanJson);
                        OnSuccess(bean, callback);
                    }
                }
                else
                {
                    // 不需要解析json分两个情况，如果确定了data是一个对象就直接解析里面的数据
                    if (jo["data"].GetType() == typeof(JObject))
                    {
                        var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(beanJson);
                        OnSuccess(data, callback);
                    }
                    else
                    {
                        var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
                        OnSuccess(data, callback);
                    }

                }
            }
            catch (Exception)
            {
                OnError("接口数据解析出错", callback, code);
                LogHelper.LogInfo("接口数据解析出错  requst :" + requstUrl + "  \n response :" + responseText);
            }
        }
        else if (code == CODE_TRANSFER_RECEIVED)
        {
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
            // 不需要解析json, 直接返回
            OnSuccess(data, callback);
        }
        else if (code == CODE_TRANSFER_OUTTIME)
        {
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
            // 不需要解析json, 直接返回
            OnSuccess(data, callback);
        }
        else if (code == CODE_READ_OUTTIME)
        {
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
            // 不需要解析json, 直接返回
            OnSuccess(data, callback);
        }
        else if (code == CODE_READ_HAVERECEIVED)
        {
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
            // 不需要解析json, 直接返回
            OnSuccess(data, callback);
        }
        else if (code == CODE_READ_HAVEOPEN)
        {
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
            // 不需要解析json, 直接返回
            OnSuccess(data, callback);
        }
        else if (code == CODE_READ_PACKED)
        {

            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(responseText);
            // 不需要解析json, 直接返回
            OnSuccess(data, callback);

        }
        else if (code == CODE_NO_TOKEN || code == CODE_TOKEN_ERROR)
        {
            // 重启程序
            Messenger.Default.Send("1030102", MessageActions.RESTART_APP);
        }
        else
        {
            //string msg = jo["resultMsg"].ToString();
            string errmsg = UIUtils.DecodeString(jo, "resultMsg");

            if (UIUtils.IsNull(errmsg))
            {
                errmsg = "操作错误";
            }

            OnError("调用服务器接口失败,原因:" + errmsg, callback, code);
            LogHelper.LogInfo("调用服务器接口失败  requst :" + requstUrl + "  \n response :" + responseText);
        }
    }

    internal string BuildUrl()
    {
        return requstUrl;
    }

    private void OnError<T>(string msg, Action<bool, T> callback, int code)
    {
        if (IsCancelRequest())
        {
            return;
        }

        try
        {
            if (mErrListener != null)
            {
                HttpUtils.Instance.Invoke(mErrListener, code, msg);
            }
            else
            {
                HttpUtils.Instance.Invoke(callback, false, null);
            }


            if (!mNotTip)
            {
                Action<string> action = new Action<string>(ShowErrBox);
                HttpUtils.Instance.Invoke(action, msg);
            }
        }
        catch (Exception ex)
        {
            LogUtils.Log(ex.Message);
        }
    }

    private void OnSuccess<T, K>(K data, Action<bool, T> callback)
    {
        if (IsCancelRequest())
        {
            return;
        }

        if (callback != null)
        {
            try
            {
                HttpUtils.Instance.Invoke(callback, true, data);
            }
            catch (Exception ex)
            {
                LogUtils.Log("窗口句柄出错，无法回到主线程" + ex.Message);
                //callback(true, data);
                throw;
            }

        }
    }




    private bool IsCancelRequest()
    {

        if (!UIUtils.IsNull(tag))
        {
            if (HttpUtils.Instance.CancelPool(tag, requestTime))
            {
                Console.WriteLine("接口请求被取消： " + tag);
                return true;
            }
        }

        return false;
    }
    private void ShowErrBox(string err)
    {
        //Messenger.Default.Send(err, FrmMain.NOTIFY_NOTICE);//通知各页面收到消息

        HttpUtils.Instance.ShowTip(err);


        //var SnackBar = new WinFrmTalk.Controls.SystemControls.Snackbar();
        //SnackBar.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
        //SnackBar.Location = new System.Drawing.Point(327, 604);
        //SnackBar.Name = "SnackBar";
        //SnackBar.Size = new System.Drawing.Size(185, 36);
        //SnackBar.TabIndex = 57;
        //SnackBar.Text = "snackbar1";
        //HttpUtils.Instance.GetControl().Controls.Add(SnackBar);
        //SnackBar.Enqueue(err);
    }

    // 错误码转消息
    private string ErrCodeToMsg(int code)
    {
        string errmsg = "";
        switch (code)
        {
            case -2:
                errmsg = "解析异常";
                break;
            case CODE_NET_ERROE:
                errmsg = "网络错误";
                break;
            case CODE_ARGUMENT_ERROR1:
            case CODE_ARGUMENT_ERROR2:
                errmsg = "缺少必填参数或参数错误";
                break;
            case CODE_INTERNAL_ERROR:
                errmsg = "接口内部异常";
                break;
            case CODE_NO_TOKEN:
                errmsg = "缺少访问令牌";
                break;
            case CODE_TOKEN_ERROR:
                errmsg = "访问令牌过期或无效";
                break;
            case CODE_ACCOUNT_INEXISTENCE:
                errmsg = "帐号不存在";
                break;
            case CODE_ACCOUNT_ERROE:
                errmsg = "帐号或密码错误";
                break;
            case CODE_THIRD_NO_PHONE:
                errmsg = "第三方登录未绑定手机号码";
                break;
            case CODE_THIRD_NO_EXISTS:
                errmsg = "第三方登录时账号不存在";
                break;
        }

        return errmsg;
    }

    public const int CODE_NET_ERROE = -1;// 网络连接错误
    public const int CODE_ERROE = 0;// 未知的错误 或者系统内部错误
    public const int CODE_SUCCESS = 1;// 正确的Http请求返回状态码
    public const int CODE_ARGUMENT_ERROR1 = 1010101;// 请求参数验证失败，缺少必填参数或参数错误
    public const int CODE_ARGUMENT_ERROR2 = 1010102;// 缺少请求参数：%1$s

    public const int CODE_INTERNAL_ERROR = 1020101;// 接口内部异常
    public const int CODE_NO_TOKEN = 1030101;// 缺少访问令牌
    public const int CODE_TOKEN_ERROR = 1030102;// 访问令牌过期或无效

    /* 登陆接口的Http Result Code */
    public const int CODE_ACCOUNT_INEXISTENCE = 1040101;// 帐号不存在
    public const int CODE_ACCOUNT_ERROE = 1040102;// 帐号或密码错误

    // 这个是第三方登录时出错这个第三方账号没有绑定到已有账号，
    public const int CODE_THIRD_NO_PHONE = 1040305;// 第三方登录未绑定手机号码
    // 这个是绑定已有账号时出错这个IM账号不存在，
    public const int CODE_THIRD_NO_EXISTS = 1040306;// 第三方登录时账号不存在

    public const int CODE_READ_OUTTIME = 100101;// 红包过期
    public const int CODE_READ_HAVERECEIVED = 101204;// 群红包已经领取
    public const int CODE_READ_HAVEOPEN = 1;// 群红包仍可以领取
    public const int CODE_READ_PACKED = 100102;// 第三方登录时账号不存在
    public const int CODE_TRANSFER_RECEIVED = 100302;// 第三方登录时账号不存在
    public const int CODE_TRANSFER_OUTTIME = 100301;// 转账超时

}
