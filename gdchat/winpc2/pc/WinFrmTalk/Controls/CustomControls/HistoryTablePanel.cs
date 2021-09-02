using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class HistoryTablePanel : UserControl
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
        
        public HistoryTablePanel()
        {
            InitializeComponent();
        }

        public TableLayoutPanelEx CurrentPanel { get { return this.tlpHistoryTable; } }

        private void MyTabLayoutPanel_Load(object sender, EventArgs e)
        {
            historyTabVScroll.SetCurrentPanel(tlpHistoryTable.Name);
            historyTabVScroll.v_scale = 30;
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
            this.historyTabVScroll.AddScollerBouttom(sroller, FristDataCount / pageSize);
        }

        public int PAGER_SIZE = 50;   //单页个数

        #region 批量添加控件
        /// <summary>
        /// 批量添加控件
        /// </summary>
        /// <param name="views">控件集合</param>
        internal void AddViewsToPanel(List<Control> views)
        {
            #region 避免出现第一行空白
            if (tlpHistoryTable.RowCount == 1)
            {
                tlpHistoryTable.RowStyles.Clear();
                tlpHistoryTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 1));
            }
            #endregion

            //是否允许继续触发数据加载监控
            historyTabVScroll.canAdd = views.Count >= PAGER_SIZE ? 0 : -1;

            tlpHistoryTable.SuspendLayout();
            foreach (Control item in views)
            {
                item.Margin = new Padding(0);
                tlpHistoryTable.RowCount = tlpHistoryTable.RowStyles.Count + 1;
                tlpHistoryTable.RowStyles.Add(new RowStyle(SizeType.Absolute, item.Height));
                tlpHistoryTable.Controls.Add(item, 0, tlpHistoryTable.RowCount - 1);
                Application.DoEvents();
            }
            tlpHistoryTable.ResumeLayout();

            //loading.stop();  //关闭等待符
        }
        #endregion

        #region 从列表移除单个项
        /// <summary>
        /// 从列表移除单个项
        /// </summary>
        /// <param name="crl_item">需要移除的项</param>
        public void RemoveItem(Control crl_item)
        {
            var position = tlpHistoryTable.GetPositionFromControl(crl_item);
            if (position == null || position.Row == -1)
                return;
            tlpHistoryTable.Controls.Remove(crl_item);
            tlpHistoryTable.RowStyles[position.Row].Height = 0;
            if (crl_item != null)
                crl_item.Dispose();
        }
        #endregion

        #region 在指定行插入一个控件
        /// <summary>
        /// 在指定行插入一个控件
        /// </summary>
        /// <param name="crl_item"></param>
        /// <param name="row_index"></param>
        public void InsertItem(Control crl_item, int row_index)
        {
            tlpHistoryTable.SuspendLayout();
            crl_item.Margin = new Padding(0);
            tlpHistoryTable.RowStyles.Insert(row_index, new RowStyle(SizeType.Absolute, crl_item.Height));
            #region 所有控件向下位移
            Dictionary<int, Control> tab_crl = new Dictionary<int, Control>();
            //循环每一行，获取所有的控件
            foreach (Control item in tlpHistoryTable.Controls)
            {
                var position = tlpHistoryTable.GetPositionFromControl(item);
                tab_crl.Add(position.Row, item);
            }
            //重新排序
            for (int index = tlpHistoryTable.RowStyles.Count; index > 0; index--)
            {
                if (!tab_crl.ContainsKey(index))
                    continue;
                var item = tab_crl[index];
                tlpHistoryTable.SetRow(item, index + 1);     //RowStyles[0].Height 为 0
            }
            #endregion
            tlpHistoryTable.Controls.Add(crl_item, 0, row_index);
            tlpHistoryTable.ResumeLayout();
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
            var position = tlpHistoryTable.GetPositionFromControl(item);
            return position == null ? -1 : position.Row;
        }
        #endregion

        #region 通过friend获取对应的NewsItem
        public NewsItem GetNewsItemByFriend(string userId)
        {
            foreach(Control control in tlpHistoryTable.Controls)
            {
                if(control is NewsItem item)
                {
                    if (item.friendData.UserId == userId)
                        return item;
                }
            }
            return null;
        }
        #endregion

        #region 通过friend获取对应的FriendItem
        public FriendItem GetFriendItemByFriend(string userId)
        {
            foreach (Control control in tlpHistoryTable.Controls)
            {
                if (control is FriendItem item)
                {
                    if (item.friendData.UserId == userId)
                        return item;
                }
            }
            return null;
        }
        #endregion
        
        #region 通过friend获取对应的UserItem
        public UserItem GetUserItemByFriend(string userId)
        {
            //foreach (Control control in tlpHistoryTable.Controls)
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

        #region 清除所有控件和布局
        /// <summary>
        /// 清除所有控件和布局
        /// </summary>
        public void ClearTabel(bool isDispon = true)
        {
            while (true)
            {
                foreach (Control item in tlpHistoryTable.Controls)
                {
                    tlpHistoryTable.Controls.Remove(item);
                    if (isDispon)
                        item.Dispose();
                }
                if (tlpHistoryTable.Controls.Count == 0)
                    break;
            }

            tlpHistoryTable.RowStyles.Clear();
            tlpHistoryTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 0));
            tlpHistoryTable.RowCount = 1;
            tlpHistoryTable.Height = 0;
            historyTabVScroll.pageIndex = 1;
            Helpers.ClearMemory();
        }
        #endregion

      //  private LodingUtils loading;    //等待符
        /// <summary>
        /// 开启等待符，添加控件结束时stop
        /// </summary>
        public void ShowLoading()
        {
            //loading = new LodingUtils();
            //loading.start();
            //loading.parent = this.tlpHistoryTable;
        }

        #region 列表控件变更
        private void tlpHistoryTable_ControlRemoved(object sender, ControlEventArgs e)
        {
            //容器高度重新计算
            int newHeight = 0;
            foreach (RowStyle rowStyle in tlpHistoryTable.RowStyles)
            {
                newHeight += (int)rowStyle.Height;
            }
            //当前移除的控件高度去掉
            tlpHistoryTable.Size = new Size(tlpHistoryTable.Width, newHeight - e.Control.Height);

            //修改滚动条高度
            historyTabVScroll.UpdateVScrollLocation();
        }

        private void tlpHistoryTable_ControlAdded(object sender, ControlEventArgs e)
        {
            //容器高度重新计算
            int newHeight = 0;
            foreach (RowStyle rowStyle in tlpHistoryTable.RowStyles)
            {
                newHeight += (int)rowStyle.Height;
            }
            //当前添加的控件高度添加
            tlpHistoryTable.Size = new Size(tlpHistoryTable.Width, newHeight);

            //修改滚动条高度
            historyTabVScroll.UpdateVScrollLocation();
        }
        #endregion
    }
}
