using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk;

namespace TestListView
{

    //
    // 列表控件-缓存
    // liuxuan
    // 2019-6-11 12:05:04
    //
    public partial class XListView : UserControl
    {
        #region 双缓冲
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000;
                return cp;
            }
        }
        #endregion

        #region 全局变量
        //上一次的xlist高度，防止最小化时为0
        private int lastXListHeight = 0;
        // 列表总高
        private int total_height;
        // 最后一次的滚动条进度
        private int last_progress;
        // 缓存 - 项高度
        private int[] mCacheHeight;
        // 缓存 - 项是否创建
        private int[] mCacheCreated;
        // 缓存 - 项
        private Control[] mCacheControl;
        // 适配器
        private IBaseAdapter mAdapter;

        public delegate void EventScrollHandler();

        public bool mLoading; // 是否正在加载

        public int ViewHeight
        {
            get
            {
                if (this.Height > 0)
                {
                    lastXListHeight = Height;
                    return Height;
                }
                else
                {
                    return lastXListHeight;
                }
            }
        }

        // 获取当前滚动的位置 取值为 0-100
        public int Progress
        {
            get
            {
                return vScrollBar.Value;
            }
        }

        // 获取容器宽度
        public int ItemGroupWidth
        {
            get
            {
                return this.Width - vScrollBar.Width;
            }
        }

        // 获取滚动条宽度
        public int ScrollBarWidth
        {
            get
            {

                return vScrollBar.Width;
            }
            set
            {
                vScrollBar.Width = value;
                panel1.Width = this.Width - value;
            }
        }


        public XListView()
        {
            InitializeComponent();
        }
        #endregion

        #region 控件加载事件
        // 加载事件
        private void XListView_Load(object sender, EventArgs e)
        {
            int x = this.Width - vScrollBar.Width;
            Point point = vScrollBar.Location;
            point.X = x;
            vScrollBar.Location = point;
            vScrollBar.Height = ViewHeight;
            panel1.Width = this.Width - vScrollBar.Width;
        
        }

        #endregion

        #region 控件大小改变事件
        private void XListView_SizeChanged(object sender, EventArgs e)
        {
            vScrollBar.Height = ViewHeight;
            vScrollBar.Location = new Point(this.Width - vScrollBar.Width, 0);
            panel1.Width = this.Width - 10 - vScrollBar.Width;
            if (mAdapter != null)
            {
                FillControlToPanel();
            }
        }

        #endregion

        #region 进度条滚动事件
        // 进度条滚动事件
        private void vScrollBar_Scroll()
        {
            if (vScrollBar.Value == last_progress)
            {
                return;
            }

            if (mAdapter == null || mAdapter.GetItemCount() == 0)
            {
                return;
            }

            if (this.Height > GetListHeight())
            {
                return;
            }

            last_progress = vScrollBar.Value;

            float max = GetListHeight() - this.Height;

            int movey = Convert.ToInt32(last_progress / 100.0f * max * -1);
            // 移动panel
            MovePanelLocation(movey);
            // 填补控件
            FillControlToPanel();
        }
        #endregion

        #region 鼠标滚轮滚动事件
        // 鼠标滚动事件
        private void View_MouseWheel(object sender, System.Windows.Forms.MouseEventArgs e)
        {
            if (mAdapter == null || mAdapter.GetItemCount() == 0)
            {
                return;
            }

            int movey = (e.Delta >> 2);

            if (movey >= 0)
            {
                if (panel1.Location.Y == 0)
                {   // 滑动到了顶部
                    if (HeaderRefresh != null)
                    {
                        Invoke(HeaderRefresh);
                    }
                    return;
                }
                else if (panel1.Location.Y > 0)
                {
                    // 滑动超过了顶部
                    movey = -panel1.Location.Y;

                    if (HeaderRefresh != null)
                    {
                        Invoke(HeaderRefresh);
                    }

                }
                else if (Math.Abs(panel1.Location.Y) < movey)
                    movey = Math.Abs(panel1.Location.Y);
                //Console.WriteLine("向上滚动");
            }
            else
            {
                //Console.WriteLine("向下滚动");
                if (this.Height > GetListHeight())
                {
                    movey = 0;
                }
                else if (this.Height - GetListHeight() - movey > panel1.Location.Y)
                {
                    // 滑动到了底部
                    int height = GetListHeight() - this.Height;
                    movey = Math.Abs(panel1.Location.Y) - height;

                    if (FooterRefresh != null)
                    {
                        Invoke(FooterRefresh);
                    }
                }
            }

            if (movey == 0)
            {
                return;
            }

            // 移动panel
            MovePanelLocation(panel1.Location.Y + movey);
            // 同步滚动条
            MoveScrollbar(panel1.Location.Y);
            // 填补控件
            FillControlToPanel();
        }

        #endregion

        #region 滚动列表-坐标

        // 移动到某一个位置
        private void MovePanelLocation(int location_y)
        {
            Point point = panel1.Location;
            point.Y = location_y;
            panel1.Location = point;
        }
        #endregion

        #region 滚动进度条-坐标

        // 移动滚动条 到某一个位置
        private void MoveScrollbar(int location_y)
        {
            // 总高度
            int height = GetListHeight() - this.Height;
            if (height <= 0)
                return;
            //LogUtils.Log("MoveScrollbar:" + location_y + " , " + height);

            // 当前偏移 / 总高 = 进度
            int pro = Convert.ToInt32(Math.Abs(location_y) / (float)height * 100);
            pro = Math.Min(pro, 100);

            vScrollBar.SetProgress(pro);
        }

        #endregion

        #region 填充控件到列表

        // 根据当前的位置，自定填充控件
        private void FillControlToPanel()
        {
            this.SuspendLayout();

            int height = 0;
            int index = 0;
            int pos = Math.Abs(panel1.Location.Y);
            while (height < pos && index < mAdapter.GetItemCount())
            {
                height += GetItemHeight(index++);
            }

            // 向上填充
            if (index >= 1 && !DataCreated(index - 1))
            {
                int last = index - 1;
                // 取出控件
                Control control = GetItemControl(last);
                // 放到界面
                Point point = control.Location;
                //如果填充控件过程中刷新了控件导致panel的大小发生变化
                if (pos != Math.Abs(panel1.Location.Y))
                {
                    height = 0;
                    pos = Math.Abs(panel1.Location.Y);
                    //重新计算前面的高度
                    //如果上一个控件已经创建
                    if (DataCreated(last - 1) && Math.Abs(mCacheControl[last - 1].Location.Y) > 0)
                        height = GetItemHeight(last) + GetItemHeight(last - 1) + Math.Abs(mCacheControl[last - 1].Location.Y);
                    else
                    {
                        for (int i = last; i > -1; i--)
                        {
                            height += GetItemHeight(i);
                        }
                    }
                }
                if (panel1.Height - Height != pos)
                {
                    //int y = panel1.Location.Y < 0 ? Height - panel1.Height : 0;
                    //panel1.Location = new Point(panel1.Location.X, y);
                    pos = panel1.Height - Height;
                    height = 0;
                    if (DataCreated(last - 1) && Math.Abs(mCacheControl[last - 1].Location.Y) > 0)
                        height = GetItemHeight(last) + GetItemHeight(last - 1) + Math.Abs(mCacheControl[last - 1].Location.Y);
                    else
                    {
                        for (int i = last; i > -1; i--)
                        {
                            height += GetItemHeight(i);
                        }
                    }
                }
                point.Y = height - GetItemHeight(last);
                control.Location = point;

                //control.Width = vScrollBar.Location.X;

                panel1.Controls.Add(control);
            }

            // 向下填充数据
            while (height < pos + this.Height && index < mAdapter.GetItemCount())
            {
                //如果填充控件过程中刷新了控件导致panel的大小发生变化
                if (pos != Math.Abs(panel1.Location.Y))
                {
                    height = 0;
                    pos = Math.Abs(panel1.Location.Y);
                    //重新计算前面的高度
                    if (DataCreated(index - 1) && Math.Abs(mCacheControl[index - 1].Location.Y) > 0)
                        height = GetItemHeight(index - 1) + Math.Abs(mCacheControl[index - 1].Location.Y);
                    else
                    {
                        for (int i = index - 1; i > -1; i--)
                        {
                            height += GetItemHeight(i);
                        }
                    }
                }

                // 判断这个位置是否已经有数据了
                if (!DataCreated(index))
                {
                    // 取出控件
                    Control control = GetItemControl(index);
                    // 放到界面
                    Point point = control.Location;
                    point.Y = height;
                    control.Location = point;

                    //control.Width = vScrollBar.Location.X;

                    panel1.Controls.Add(control);
                }

                height += GetItemHeight(index++);
            }

            this.ResumeLayout();
        }
        #endregion

        #region 获取所有控件累计高度
        private int GetListHeight()
        {
            if (total_height > 0)
            {
                return total_height;
            }

            total_height = 0;

            for (int i = 0; i < mAdapter.GetItemCount(); i++)
            {
                total_height += GetItemHeight(i);
            }

            return total_height;
        }

        #endregion

        #region 修改控件坐标
        private void ModifyLocation(Control control, int loc_y)
        {
            Point point = control.Location;
            point.Y = loc_y;
            control.Location = point;
        }
        #endregion

        #region 获取控件坐标
        private int GetIndexLocation(int index)
        {
            int pos = 0;

            for (int i = 0; i < index; i++)
            {
                pos += GetItemHeight(i);
            }

            return pos;
        }
        #endregion

        #region 给子控件添加滚轮事件
        private void AddCrlMouseWheel(Control crl)
        {
            foreach (Control item in crl.Controls)
            {
                if (item.Controls.Count > 0)
                    AddCrlMouseWheel(item);
                item.MouseWheel += (sender, ev) => View_MouseWheel(sender, ev);
            }
            crl.MouseClick += (sender, ev) => View_MotseClick(sender, ev);
        }
        #endregion

        // =======================下面是提供给外部调用的方法=======================

        #region 设置适配器方法

        /// <summary>
        /// 设置适配器方法
        /// </summary>
        /// <param name="adapter"></param>
        public void SetAdapter(IBaseAdapter adapter)
        {
            if (adapter == null)
            {
                return;
            }

            mAdapter = adapter;

            ClearList();

            // 默认先显示 第0个位置
            if (mAdapter.direction)
            {
                ShowRangeStart(0, 0);
            }
            else
            {
                ShowRangeEnd(mAdapter.GetItemCount() - 1, 0);
            }

            FillControlToPanel();

            panel1.Height = GetListHeight();
        }


        #endregion

        #region 清空列表方法
        /// <summary>
        /// 清空列表方法
        /// </summary>
        public void ClearList()
        {
            int total = mAdapter.GetItemCount();
            mCacheHeight = new int[total];
            mCacheCreated = new int[total];
            mCacheControl = new Control[total];
            total_height = 0;

            panel1.Height = 0;
            Point point = panel1.Location;
            point.Y = 0;
            panel1.Location = point;

            //for (int i = panel1.Controls.Count - 1; i > -1; i--)
            //{
            //    Control crl = panel1.Controls[i];
            //    panel1.Controls.RemoveAt(i);
            //    crl.Dispose();
            //}
            Helpers.DisposeCrl(panel1);
            Helpers.ClearMemory();
        }


        #endregion

        #region 获取控件项方法

        // 获取某一个控件的方法
        public Control GetItemControl(int index)
        {
            if (index > mAdapter.GetItemCount() || index < 0)
            {
                Console.WriteLine("xlistview GetItemControl  index " + index);
                return null;
            }

            // 先从缓存里面去获控件
            if (mCacheControl[index] != null)
            {
                return mCacheControl[index];
            }

            // 然后调用外界创建一下
            Control control = mAdapter.OnCreateControl(index);
            // 添加滚轮事件
            AddCrlMouseWheel(control);
            // 保存到缓存
            mCacheControl[index] = control;
            mCacheCreated[index] = 1;
            return control;
        }

        #endregion

        #region 获取控件高度方法
        // 获取某一个控件的高度
        public int GetItemHeight(int index)
        {
            // 先从缓存里面去获取高度
            if (mCacheHeight[index] > 0)
            {
                return mCacheHeight[index];
            }

            // 然后去外界测量一下
            int height = mAdapter.OnMeasureHeight(index) + mAdapter.interval;
            // 保存到缓存
            mCacheHeight[index] = height;

            return height;
        }

        #endregion

        #region 判断项是否创建方法
        /// <summary>
        /// 判断某项是否已在列表中创建
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool DataCreated(int index)
        {
            if (index < 0 || index >= mCacheCreated.Length)
            {
                return false;
            }

            return mCacheCreated[index] == 1;
        }

        #endregion

        #region 插入项方法
        /// <summary>
        /// 插入数据方法
        /// 注意 ： 
        /// 要先去真实的插入数据 
        /// 在调用这个方法
        /// </summary>
        /// <param name="index"></param>
        public void InsertItem(int index, bool isCreate = true)
        {
            if (index > mAdapter.GetItemCount() || index < 0)
            {
                Console.WriteLine("xlistview 调用插入方法不正确  index " + index);
                return;
            }

            this.SuspendLayout();

            try
            {
                // 集合变大了，创建新的集合
                int total = mAdapter.GetItemCount();
                int[] tempHeight = new int[total];
                int[] tempCreated = new int[total];
                Control[] tempControl = new Control[total];

                // 数据拷贝
                int temp = 0;
                for (int i = 0; i < total - 1; i++)
                {
                    temp = i;
                    if (i >= index)
                    {
                        temp = i + 1;
                    }

                    tempHeight[temp] = mCacheHeight[i];
                    tempCreated[temp] = mCacheCreated[i];
                    tempControl[temp] = mCacheControl[i];
                }


                mCacheHeight = tempHeight;
                mCacheCreated = tempCreated;
                mCacheControl = tempControl;

                panel1.Height += GetItemHeight(index);
                total_height += GetItemHeight(index);

                if (isCreate)
                {
                    int height = GetIndexLocation(index);

                    // 取出控件
                    Control create = GetItemControl(index);
                    // 放到界面
                    ModifyLocation(create, height);
                    panel1.Controls.Add(create);

                    // 移动panpel的项 
                    height += GetItemHeight(index);
                    int next = index + 1;
                    while (next < mAdapter.GetItemCount())
                    {
                        if (DataCreated(next))
                        {
                            Control control = GetItemControl(next);
                            ModifyLocation(control, height);
                        }

                        height += GetItemHeight(next);
                        next++;
                    }
                }
                //同步滚动条
                MoveScrollbar(panel1.Location.Y);
            }
            catch (Exception ex) { LogHelper.log.Error("----列表容器插入子项出错，方法（InsertItem） : \n" + ex.Message); }

            this.ResumeLayout();
        }

        #endregion

        #region 插入批量数据的方法
        /// <summary>
        /// 插入数据方法
        /// 注意 ： 
        /// 要先去真实的插入数据 
        /// 在调用这个方法
        /// </summary>
        /// <param name="index"></param>
        public void InsertRange(int index)
        {
            if (index > mAdapter.GetItemCount() || index < 0)
            {
                Console.WriteLine("xlistview 调用批量插入不正确  index " + index);
                return;
            }

            this.SuspendLayout();

            // 集合变大了，创建新的集合
            int last = mCacheCreated.Length;
            int total = mAdapter.GetItemCount();
            int diff = total - last;
            if (diff <= 0)
            {
                LogUtils.Log("数据没有发送改变");
                return;
            }

            int[] tempHeight = new int[total];
            int[] tempCreated = new int[total];
            Control[] tempControl = new Control[total];

            // 数据拷贝 上部分
            for (int i = 0; i < index; i++)
            {
                tempHeight[i] = mCacheHeight[i];
                tempCreated[i] = mCacheCreated[i];
                tempControl[i] = mCacheControl[i];
            }

            int insertitemHeight = 0;
            for (int i = index; i < index + diff; i++)
            {
                int itemheight = mAdapter.OnMeasureHeight(i) + mAdapter.interval;
                tempHeight[i] = itemheight;
                insertitemHeight += itemheight;
            }


            // 数据拷贝 下部分
            for (int i = index + diff; i < total; i++)
            {
                int fool = i - diff;
                tempHeight[i] = mCacheHeight[fool];
                tempCreated[i] = mCacheCreated[fool];

                Control control = mCacheControl[fool];
                tempControl[i] = control;

                if (control != null)
                {
                    ModifyLocation(control, control.Location.Y + insertitemHeight);
                }

            }

            mCacheHeight = tempHeight;
            mCacheCreated = tempCreated;
            mCacheControl = tempControl;

            // 重新计算高度
            total_height = -1;
            panel1.Height = GetListHeight();

            if (index == 1 || index == 2)
            {
                ShowRangeStart(diff, 0);
            }
            else
            {
                MoveScrollbar(panel1.Location.Y);
            }

            this.ResumeLayout();

            FillControlToPanel();
        }

        #endregion

        #region 删除项方法
        /// <summary>
        /// 删除项方法
        /// 注意 ： 
        /// 要先调用这个方法
        /// 然后去真实的删除数据
        /// </summary>
        /// <param name="index"></param>

        public void RemoveItem(int index)
        {

            if (index > mAdapter.GetItemCount() || index < 0)
            {
                Console.WriteLine("xlistview 调用移除方法不正确  index " + index);
                return;
            }

            this.SuspendLayout();

            int height = GetIndexLocation(index);

            // 从列表中移除
            if (DataCreated(index))
            {
                Control control = GetItemControl(index);
                panel1.Controls.Remove(control);
            }

            // 移动panpel的项 
            int next = index + 1;
            while (next < mAdapter.GetItemCount())
            {
                if (DataCreated(next))
                {
                    Control control = GetItemControl(next);
                    ModifyLocation(control, height);
                }

                height += GetItemHeight(next);
                // 移动数据
                mCacheHeight[next - 1] = mCacheHeight[next];
                mCacheCreated[next - 1] = mCacheCreated[next];
                mCacheControl[next - 1] = mCacheControl[next];

                next++;
            }

            total_height = height;
            panel1.Height = height;

            //最后一条数据为应该被删除的数据
            mCacheHeight = mCacheHeight.RemoveItem(mCacheHeight.Count() - 1);
            mCacheCreated = mCacheCreated.RemoveItem(mCacheCreated.Count() - 1);
            mCacheControl = mCacheControl.RemoveItem(mCacheControl.Count() - 1);

            // 填充控件到panel - 补瓷砖 
            height = 0;
            next = 0;
            int pos = Math.Abs(panel1.Location.Y);

            while (height < pos && next < mCacheHeight.Length)
            {
                height += GetItemHeight(next++);
            }

            // 向下填充数据
            while (height < pos + ViewHeight && next < mCacheHeight.Length)
            {
                // 判断这个位置是否已经有数据了
                if (!DataCreated(next))
                {
                    int create = next;
                    if (create >= index)
                    {
                        // 与真实数据产生的差异
                        create++;
                    }

                    // 取出控件
                    Control control = mAdapter.OnCreateControl(create);
                    // 保存到缓存
                    mCacheControl[next] = control;
                    mCacheCreated[next] = 1;

                    // 放到界面
                    Point point = control.Location;
                    point.Y = height;
                    control.Location = point;

                    panel1.Controls.Add(control);
                }

                height += GetItemHeight(next++);
            }

            this.ResumeLayout();
        }


        #endregion

        #region 批量删除数据项的方法
        /// <summary>
        /// 批量删除项方法
        /// 注意 ： 
        /// 要先真实的去删除数据
        /// 然后才调用这个方法删除数据项
        /// </summary>
        /// <param name="index">起始位置</param>
        /// <param name="count">要连续删除的个数</param>
        public void DeleteRange(int index, int count)
        {
            if (index + count >= mCacheCreated.Length || index < 0)
            {
                Console.WriteLine("xlistview 调用批量删除不正确  count:, index:  " + count, mCacheCreated.Length, index);
                return;
            }

            this.SuspendLayout();

            // 从列表中移除 控件
            for (int i = index; i < count + index; i++)
            {
                if (DataCreated(i))
                {
                    Control control = GetItemControl(i);
                    panel1.Controls.Remove(control);
                }
            }

            int height = GetIndexLocation(index);

            // 移动panpel的项 
            int next = index + count;
            while (next < mCacheCreated.Length)
            {
                if (DataCreated(next))
                {
                    Control control = GetItemControl(next);
                    ModifyLocation(control, height);
                }

                height += GetItemHeight(next);

                // 移动数据
                mCacheHeight[next - count] = mCacheHeight[next];
                mCacheCreated[next - count] = mCacheCreated[next];
                mCacheControl[next - count] = mCacheControl[next];

                next++;
            }


            int totle = mCacheCreated.Length - count;

            // 缩减数组
            int[] tempHeight = new int[totle];
            int[] tempCreated = new int[totle];
            Control[] tempControl = new Control[totle];

            for (int i = 0; i < totle; i++)
            {
                tempHeight[i] = mCacheHeight[i];
                tempCreated[i] = mCacheCreated[i];
                tempControl[i] = mCacheControl[i];
            }

            mCacheHeight = tempHeight;
            mCacheCreated = tempCreated;
            mCacheControl = tempControl;

            total_height = height;
            panel1.Height = height;

            // 填充控件到panel - 补瓷砖 
            height = 0;
            index = 0;
            int pos = Math.Abs(panel1.Location.Y);

            while (height < pos && index < mCacheHeight.Length)
            {
                height += GetItemHeight(index++);
            }

            // 向下填充数据
            while (height < pos + ViewHeight && index < mCacheHeight.Length)
            {
                // 判断这个位置是否已经有数据了
                if (!DataCreated(index))
                {
                    // 取出控件
                    Control control = GetItemControl(index);
                    // 放到界面
                    Point point = control.Location;
                    point.Y = height;
                    control.Location = point;

                    //control.Width = vScrollBar.Location.X;

                    panel1.Controls.Add(control);
                }

                height += GetItemHeight(index++);
            }

            this.ResumeLayout();
        }

        #endregion

        #region 刷新项方法

        /// <summary>
        ///  刷新某项
        ///  注意会重新掉用该位置的测量高度方法和创建控件方法
        /// </summary>
        /// <param name="index"></param>
        public void RefreshItem(int index)
        {
            if (index > mAdapter.GetItemCount() || index < 0)
            {
                Console.WriteLine("xlistview 调用刷新方法不正确  index " + index);
                return;
            }

            // 重新测量一下高度
            int height = GetItemHeight(index);
            mCacheHeight[index] = 0;
            // 得到差值
            int diff = GetItemHeight(index) - height;

            if (DataCreated(index))
            {
                // 清除旧数据
                Control control = GetItemControl(index);
                int inity = control.Location.Y;
                panel1.Controls.Remove(control);
                control.Dispose();
                control = null;

                // 清除这个位置上的缓存
                mCacheControl[index] = null;
                // 重新去创建
                control = GetItemControl(index);
                ModifyLocation(control, inity);
                panel1.Controls.Add(control);
            }


            panel1.Height += diff;
            total_height += diff;


            // 移动panpel的项 
            int next = index + 1;
            while (next < mAdapter.GetItemCount())
            {
                if (DataCreated(next))
                {
                    Control control = GetItemControl(next);
                    ModifyLocation(control, control.Location.Y + diff);
                }

                next++;
            }
        }


        #endregion

        #region 修改项方法
        /// <summary>
        /// 修改项高度的方法
        /// <para>手动修改项的高度和面板高度，不重新创建控件</para>
        /// </summary>
        /// <param name="index"></param>
        /// <param name="crl_height">控件的新的高度</param>
        public Control ModifyItem(int index, int diff)
        {
            if (index > mAdapter.GetItemCount() || index < 0)
            {
                Console.WriteLine("xlistview 调用刷新方法不正确  index " + index);
                return null;
            }

            int height = mCacheHeight[index];       // 重新测量一下高度
            mCacheHeight[index] = height + diff;    // 赋值新的高度

            panel1.Height += diff;
            total_height += diff;


            // 移动panpel的项 
            int next = index + 1;
            while (next < mAdapter.GetItemCount())
            {
                if (DataCreated(next))
                {
                    Control control = GetItemControl(next);
                    ModifyLocation(control, control.Location.Y + diff);
                }

                next++;
            }

            return mCacheControl[index];
        }
        #endregion

        #region 移动项方法

        /// <summary>
        ///  移动某项
        ///  注意只能用于固定项高才能使用这个方法
        ///  先移动项才能移动数据
        /// </summary>
        /// <param name="fromIndex"></param>
        /// <param name="toIndex"></param>
        public void MoveItem(int fromIndex, int toIndex)
        {
            if (fromIndex == toIndex)
            {
                return;
            }

            if (fromIndex > mAdapter.GetItemCount() || fromIndex < 0)
            {
                Console.WriteLine("xlistview 调用移动方法不正确  fromIndex " + fromIndex);
                return;
            }

            if (toIndex > mAdapter.GetItemCount() || toIndex < 0)
            {
                Console.WriteLine("xlistview 调用移动方法不正确  toIndex " + toIndex);
                return;
            }



            int fromLocation = GetIndexLocation(fromIndex);
            int toLocation = GetIndexLocation(toIndex);
            int height = GetItemHeight(fromIndex);

            // 这个位置的控件没有被创建
            if (!DataCreated(fromIndex))
            {
                Control control = GetItemControl(fromIndex);
                ModifyLocation(control, toLocation);
                panel1.Controls.Add(control);
            }

            // 移动控件到指定位置
            Control mControl = GetItemControl(fromIndex);
            ModifyLocation(mControl, toLocation);

            if (fromIndex < toIndex)
            {
                int next = fromIndex + 1;
                while (next <= toIndex)
                {
                    if (DataCreated(next))
                    {
                        Control control = GetItemControl(next);
                        ModifyLocation(control, fromLocation);
                    }

                    fromLocation += GetItemHeight(next);

                    // 移动数据
                    mCacheHeight[next - 1] = mCacheHeight[next];
                    mCacheCreated[next - 1] = mCacheCreated[next];
                    mCacheControl[next - 1] = mCacheControl[next];

                    next++;
                }
            }
            else
            {
                int next = fromIndex - 1;
                while (next >= toIndex)
                {
                    if (DataCreated(next))
                    {
                        Control control = GetItemControl(next);
                        ModifyLocation(control, fromLocation);
                    }

                    fromLocation -= GetItemHeight(next);

                    // 移动数据
                    mCacheHeight[next + 1] = mCacheHeight[next];
                    mCacheCreated[next + 1] = mCacheCreated[next];
                    mCacheControl[next + 1] = mCacheControl[next];

                    next--;
                }
            }

            // 移动数据
            mCacheHeight[toIndex] = height;
            mCacheCreated[toIndex] = 1;
            mCacheControl[toIndex] = mControl;
        }

        #endregion

        #region 滚动到某个位置方法-正序
        // 显示一页的方法  输入开始行号和偏移量
        public void ShowRangeStart(int start_index, int offset, bool isFillCrl = false)
        {

            if (start_index > mAdapter.GetItemCount() || start_index < 0)
            {
                Console.WriteLine("xlistview ShowRangeStart  index " + start_index);
                return;
            }

            // 将 panel 移动到 0 - start_index + offset的位置
            int total = offset;
            for (int i = 0; i < start_index; i++)
            {
                total += GetItemHeight(i);
            }

            int maxheight = GetListHeight() - ViewHeight;


            if (maxheight > 0 && total > maxheight)
            {
                total = maxheight;
            }

            // 移动到位置
            MovePanelLocation(-total);
            //同步滚动条
            MoveScrollbar(panel1.Location.Y);

            if (isFillCrl)
            {
                //当前panel已创建控件的总高度
                int Crl_TotalHeight = 0;
                //foreach (Control crl in panel1.Controls)
                //    Crl_TotalHeight += crl.Height;
                for(int i = start_index; i < mCacheControl.Length; i++)
                {
                    if (mCacheCreated[i] == 1)
                        Crl_TotalHeight += mCacheControl[i].Height;
                }
                //如果不足则需要填充panel
                if (ViewHeight> Crl_TotalHeight || mCacheCreated[start_index] != 1)
                {
                    FillControlToPanel();
                }
            }
        }

        #endregion

        #region 滚动到某个位置方法-反序

        // 显示一页的方法 输入结束行号和偏移量
        public void ShowRangeEnd(int end_index, int offset, bool isFillCrl = false)
        {

            if (end_index >= mAdapter.GetItemCount() || end_index < 0)
            {
                Console.WriteLine("xlistview ShowRangeEnd  index " + end_index);
                return;
            }

            // 将 panel 移动到 0 - end_index + offset - this.height 的位置

            
            int total = offset - ViewHeight;
            for (int i = 0; i <= end_index; i++)
            {
                total += GetItemHeight(i);
            }


            if (total <= 0)
            {
                total = 0;
            }
            else
            {
                total *= -1;
            }

            // 移动到位置
            MovePanelLocation(total);
            //同步滚动条
            MoveScrollbar(panel1.Location.Y);

            if (isFillCrl)
            {
                //当前panel已创建控件的总高度
                int Crl_TotalHeight = 0;
                int pos = Math.Abs(panel1.Height - ViewHeight);
                foreach (Control crl in panel1.Controls)
                {
                    if (crl.Location.Y >= pos)
                        Crl_TotalHeight += crl.Height;
                }
                //如果不足则需要填充panel
                if (ViewHeight > Crl_TotalHeight || mCacheCreated[end_index] != 1)
                {
                    FillControlToPanel();
                }
            }
        }

        #endregion

        public void RefreshFillControl()
        {
            FillControlToPanel();
        }

        #region 监听列表滚动 - 上拉刷新-下拉加载

        public event EventScrollHandler HeaderRefresh;// 滚动到顶部
        public event EventScrollHandler FooterRefresh;// 滚动到底部

        #endregion


        private void View_CurMouseClick(object sender, System.EventArgs e)
        {
            this.Focus();
        }

        //xxq 2020/3/28 滚动
        private void View_MotseClick(object sender, System.EventArgs e)
        {
            this.Controls[this.Controls.Count - 1].Focus();
        }
    }
}
