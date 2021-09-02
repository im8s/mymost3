using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


/// <summary>
/// 
/// </summary>
public abstract class BaseRequstBuilder
{
    protected bool noTip;
    protected Action<int, string> mErrListener;

    protected string RequstParam { get; set; }

    protected string RequstUrl { get; set; }

    public abstract BaseRequstBuilder Url(string url);

    public abstract BaseRequstBuilder AddParams(String key, String value);

    public abstract BaseRequstBuilder AddParams(Dictionary<string, string> pari);

    public abstract BaseCall Build(bool beforeLogin = false);

    public BaseRequstBuilder NoErrorTip()
    {
        noTip = true;
        return this;
    }

    public BaseRequstBuilder AddErrorListener(Action<int, string> callback)
    {
        mErrListener = callback;
        return this;
    }
}
