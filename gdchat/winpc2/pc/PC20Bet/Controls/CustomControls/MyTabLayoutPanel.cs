using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using WinFrmTalk.Model;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Controls;

namespace WinFrmTalk
{
    public partial class MyTabLayoutPanel : UserControl
    {
        //双缓冲
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000;
                return cp;
            }
        }
        
        public MyTabLayoutPanel()
        {
            InitializeComponent();
        }

        public TableLayoutPanelEx CurrentPanel { get { return this.showInfo_Panel; } }

        private void MyTabLayoutPanel_Load(object sender, EventArgs e)
        {
            showInfoVScroll.SetCurrentPanel(showInfo_Panel.Name);
            showInfoVScroll.v_scale = 30;
        }

        /// <summary>
        /// 添加监听
        /// </summary>
        /// <param name="sroller">委托</param>
        /// <param name="FristDataCount">初始加载的数据条数</param>
        /// <param name="pageSize">单页的个数</param>
        internal void AddScollerBouttom(Action<int> sroller, int FristDataCount, int pageSize = 50)
        {
            PAGER_SIZE = pageSize;
            //回调
            this.showInfoVScroll.AddScollerBouttom(sroller, FristDataCount / pageSize);
        }

        /// <summary>
        /// 添加顶部监听
        /// </summary>
        /// <param name="sroller">委托</param>
        internal void AddScollerTop(Action sroller)
        {
            //回调
            this.showInfoVScroll.AddScollerTop(sroller);
        }

        public int PAGER_SIZE = 50;   //单页个数
        /// <summary>
        /// 滚动的刻度
        /// </summary>
        public int v_scale
        {
            get => showInfoVScroll.v_scale;
            set => showInfoVScroll.v_scale = value;
        }

        #region 批量添加控件
        /// <summary>
        /// 批量添加控件
        /// </summary>
        /// <param name="views">控件集合</param>
        internal void AddViewsToPanel(List<Control> views, bool isSizeChanged = true, int margin = 0)
        {
            if (UIUtils.IsNull(views))
            {
                return;
            }


            lock (views)
            {
                #region 避免出现第一行空白
                if (showInfo_Panel.RowCount == 1)
                {
                    showInfo_Panel.RowStyles.Clear();
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 1));
                }
                #endregion

                //是否允许继续触发数据加载监控
                showInfoVScroll.canAdd = views.Count >= PAGER_SIZE ? 0 : -1;

                showInfo_Panel.SuspendLayout();
                for (int index = 0; index < views.Count; index++)
                {
                    Control item = views[index];
                    item.Margin = new Padding(margin);
                    showInfo_Panel.RowCount = showInfo_Panel.RowStyles.Count + 1;
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, item.Height));
                    showInfo_Panel.Controls.Add(item, 0, showInfo_Panel.RowCount - 1);

                    if (isSizeChanged)
                    {
                        item.SizeChanged += (sender, e) =>
                        {
                            Control crl = (Control)sender;
                            var position = showInfo_Panel.GetPositionFromControl(crl);
                            int addHeight = (int)crl.Height - (int)showInfo_Panel.RowStyles[position.Row].Height;
                            showInfo_Panel.RowStyles[position.Row].Height = crl.Height;
                            showInfo_Panel.Height += addHeight;
                        };
                    }
                    //Application.DoEvents();
                }
                showInfo_Panel.ResumeLayout();
            }
            //loading.stop();  //关闭等待符
        }
        #endregion

        #region 从列表移除单个项
        /// <summary>
        /// 从列表移除单个项
        /// </summary>
        /// <param name="crl_item">需要移除的项</param>
        public void RemoveItem(Control crl_item, bool isDispose = true)
        {
            var position = showInfo_Panel.GetPositionFromControl(crl_item);
            if (position == null || position.Row == -1)
                return;
            showInfo_Panel.Controls.Remove(crl_item);
            showInfo_Panel.RowStyles.RemoveAt(position.Row);
            if (crl_item != null && isDispose)
                crl_item.Dispose();

            //控件上移，填补空缺
            MoveControl(position.Row, -1);
        }
        #endregion

        #region 在指定行插入一个控件
        /// <summary>
        /// 在指定行插入一个控件
        /// </summary>
        /// <param name="crl_item"></param>
        /// <param name="row_index"></param>
        public void InsertItem(Control crl_item, int row_index, int margin = 0)
        {
            Action action = new Action(() =>
            {
                #region 避免出现第一行空白
                if (showInfo_Panel.RowCount == 1)
                {
                    showInfo_Panel.RowStyles.Clear();
                    showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 1));
                }
                #endregion

                showInfo_Panel.SuspendLayout();
                crl_item.Margin = new Padding(margin);
                showInfo_Panel.RowStyles.Insert(row_index, new RowStyle(SizeType.Absolute, crl_item.Height));
                #region 所有控件向下位移
                Dictionary<int, Control> tab_crl = new Dictionary<int, Control>();
                //循环每一行，获取所有的控件
                foreach (Control item in showInfo_Panel.Controls)
                {
                    var position = showInfo_Panel.GetPositionFromControl(item);
                    tab_crl.Add(position.Row, item);
                }
                //重新排序
                for (int index = showInfo_Panel.RowStyles.Count; index > 0; index--)
                {
                    if (!tab_crl.ContainsKey(index) || index < row_index)
                        continue;
                    var item = tab_crl[index];
                    showInfo_Panel.SetRow(item, index + 1);     //RowStyles[0].Height 为 0
                }
                #endregion
                showInfo_Panel.Controls.Add(crl_item, 0, row_index);
                showInfo_Panel.ResumeLayout();
            });
            if (showInfo_Panel.IsHandleCreated)
                Invoke(action);
        }
        #endregion

        #region 获取子项所在的行
        /// <summary>
        /// 获取子项所在的行
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public int GetRowIndexByItem(Control item)
        {
            var position = showInfo_Panel.GetPositionFromControl(item);
            return position == null ? -1 : position.Row;
        }
        #endregion

        //#region 通过friend获取对应的NewsItem
        //public NewsItem GetNewsItemByFriend(string userId)
        //{
        //    foreach(Control control in showInfo_Panel.Controls)
        //    {
        //        if(control is NewsItem item)
        //        {
        //            if (item.friendData.UserId == userId)
        //                return item;
        //        }
        //    }
        //    return null;
        //}
        //#endregion

        #region 通过friend获取对应的FriendItem
        public FriendItem GetFriendItemByFriend(string userId)
        {
            foreach (Control control in showInfo_Panel.Controls)
            {
                if (control is FriendItem item)
                {
                    if (item.FriendData.UserId == userId)
                        return item;
                }
            }
            return null;
        }
        #endregion
        
        #region 通过friend获取对应的UserItem
        public UserItem GetUserItemByFriend(string userId)
        {
            //foreach (Control control in showInfo_Panel.Controls)
            //{
            //    if (control is UserItem item)
            //    {
            //        if (item.friendData.userId == userId)
            //            return item;
            //    }
            //}
            return null;
        }
        #endregion

        #region 通过VerifingFriend获取对应的VerifyItem
        public VerifyItem GetVerifyItemByVerifingFriend(string userId)
        {
            foreach (Control control in showInfo_Panel.Controls)
            {
                if (control is VerifyItem item)
                {
                    if (item.DataContext.userId == userId)
                        return item;
                }
            }
            return null;
        }
        #endregion


        #region 通过VerifingFriend获取对应的VerifyItem
        public AddFriendItem GetQueryItemByVerifingFriend(string userId)
        {
            foreach (Control control in showInfo_Panel.Controls)
            {
                if (control is AddFriendItem item)
                {
                    if (item.friendData.UserId == userId)
                        return item;
                }
            }
            return null;
        }
        #endregion


        public List<Control> GetCurrControls()
        {
            List<Control> list = new List<Control>();
            foreach (Control control in showInfo_Panel.Controls)
            {
                list.Add(control);
            }
            return list;
        }

        #region 清除所有控件和布局
        /// <summary>
        /// 清除所有控件和布局
        /// </summary>
        public void ClearTabel(bool isDispon = true)
        {
            while (true)
            {
                foreach (Control item in showInfo_Panel.Controls)
                {
                    showInfo_Panel.Controls.Remove(item);
                    if (isDispon)
                        item.Dispose();
                }
                if (showInfo_Panel.Controls.Count == 0)
                    break;
            }

            showInfo_Panel.RowStyles.Clear();
            showInfo_Panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 0));
            showInfo_Panel.RowCount = 1;
            showInfo_Panel.Height = 0;
            showInfoVScroll.pageIndex = 1;
            Helpers.ClearMemory();
        }
        #endregion

        //private LodingUtils loading;    //等待符
        /// <summary>
        /// 开启等待符，添加控件结束时stop
        /// </summary>
        public void ShowLoading()
        {
            //loading = new LodingUtils();
            //loading.start();
            //loading.parent = this.showInfo_Panel;
        }

        #region 列表控件变更
        private void showInfo_Panel_ControlRemoved(object sender, ControlEventArgs e)
        {
            //容器高度重新计算
            int newHeight = 0;
            foreach (RowStyle rowStyle in showInfo_Panel.RowStyles)
            {
                newHeight += (int)rowStyle.Height;
            }
            //当前移除的控件高度去掉
            showInfo_Panel.Size = new Size(showInfo_Panel.Width, newHeight - e.Control.Height);

            //修改滚动条高度
            showInfoVScroll.UpdateVScrollLocation();
        }

        private void showInfo_Panel_ControlAdded(object sender, ControlEventArgs e)
        {
            //容器高度重新计算
            int newHeight = 0;
            foreach (RowStyle rowStyle in showInfo_Panel.RowStyles)
            {
                newHeight += (int)rowStyle.Height;
            }
            //当前添加的控件高度添加
            showInfo_Panel.Size = new Size(showInfo_Panel.Width, newHeight);

            //修改滚动条高度
            showInfoVScroll.UpdateVScrollLocation();
        }
        #endregion

        private void showInfo_Panel_SizeChanged(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// 移动固定位置的控件向上（或向下）移动
        /// </summary>
        /// <param name="start_index">移动多少行</param>
        /// <param name="move_row">移动多少行</param>
        private void MoveControl(int start_index, int move_row)
        {
            Dictionary<int, Control> tab_crl = new Dictionary<int, Control>();
            //循环每一行，获取所有的控件
            foreach (Control item in showInfo_Panel.Controls)
            {
                var position = showInfo_Panel.GetPositionFromControl(item);
                tab_crl.Add(position.Row, item);
            }
            //重新排序（必须从最后一行开始往下挪）
            for (int index = showInfo_Panel.RowStyles.Count; index > 0; index--)
            {
                //如果该行没有控件或者索引小于开始索引，则不进行挪动
                if (!tab_crl.ContainsKey(index) || index < start_index)
                    continue;
                //获得该行的消息气泡
                var item = tab_crl[index];
                showInfo_Panel.SetRow(item, index + move_row);
            }
        }

        private void showInfo_Panel_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}
