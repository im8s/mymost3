using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

public abstract class IBaseAdapter
{

    // 列表控件加载方向 -默认正序
    public bool direction = true;                                  
    
    // 间隔
    public int interval = 0;

    // 这里去计算数据的高度
    public abstract int OnMeasureHeight(int index);

    // 这里去创建出控件
    public abstract Control OnCreateControl(int index);

    // 获取数据总个数
    public abstract int GetItemCount();

    // 删除项方法
    public abstract void RemoveData(int index);

    // 插入项方法
    //public void InsertItem(T data, int index);

}
