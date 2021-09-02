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
    public partial class MsgTabVScroll : UserControl
    {
        /// <summary>
        /// 实例化自定义滚动条
        /// </summary>
        public MsgTabVScroll()
        {
            InitializeComponent();
        }
        int climt, cset_x; //滚动位置最大值和固定的左右的位置
        bool cmouse_Press = false; //鼠标按下
        bool cmouse_Wheel = true; //鼠标滑轮事件
        Point cmouseOff; //存放当前鼠标位置
        Control currentPanel;   //正在活动的控件（需要滚动的）
        Control ShowInfoShade;   //用于获取复选框焦点的面板
        Control parentPanel;    //活动panel和滚动条共同的父级控件

        public Action mSroller;    //滚动监听事件

        /// <summary>
        /// 每滚动一下的像素
        /// </summary>
        public int v_scale = 30;


        public int lastScorll { get; private set; }

        /// <summary>
        /// 控制容器不会疯狂触发加载
        /// <para>-1为没有更多数据可以加载， 0为正在加载数据不允许重复触发， 1为可以加载更多数据</para>
        /// </summary>
        public int canAdd { get; set; }

        internal void AddScollerBouttom(Action sroller)
        {
            mSroller = sroller;
            canAdd = 1;
        }

        #region 设置需要滚动的panel
        /// <summary>
        /// 设置需要滚动的panel
        /// </summary>
        /// <param name="panel_name">需要进行滚动的panel，必须在同一父控件内</param>
        public void SetCurrentPanel(string panel_name)
        {
            currentPanel = this.Parent.Controls[panel_name];
            currentPanel.SizeChanged += CurrentPanel_SizeChanged;   //showinfo改变大小时
            parentPanel = this.Parent;

            //显示对话内容框鼠标事件
            currentPanel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
            parentPanel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
            TakeScrollBar_panel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
            //滚动条位置定义
            cset_x = TakeScrollHard_panel.Location.X; //固定左右位置为当前位置
            climt = TakeScrollBar_panel.Height - TakeScrollHard_panel.Height; //滚动最大高度
            TakeScrollHard_panel.Location = new Point(cset_x, 0); //先将位置设置到最顶
        }
        /// <summary>
        /// 设置需要滚动的复选panel
        /// </summary>
        /// <param name="panel_name">需要进行滚动的panel，必须在同一父控件内</param>
        public void SetShowInfoShade(string panel_name)
        {
            ShowInfoShade = this.Parent.Controls[panel_name];
            ShowInfoShade.SizeChanged += CurrentPanel_SizeChanged;   //showinfo改变大小时

            //显示对话内容框鼠标事件
            ShowInfoShade.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
        }
        #endregion

        #region 设置滚动条是否允许滚动
        /// <summary>
        /// 设置滚动条是否允许滚动
        /// </summary>
        private void cCalc_Scroll()
        {
            if ((currentPanel.Height - parentPanel.Height) <= 0)
            {
                cmouse_Wheel = canAdd > -1 ? true : false;
                currentPanel.Top = 0;
                ShowInfoShade.Top = 0;
                TakeScrollHard_panel.Location = new Point(cset_x, 0);
            }
            else
            {
                cmouse_Wheel = true;
            }
        }
        #endregion

        private void TakeScrollHard_panel_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left) //鼠标左键
            {
                cmouseOff.Y = e.Y;  //取当前位置
                cmouse_Press = true; //鼠标按下
            }
        }

        private void TakeScrollHard_panel_MouseLeave(object sender, EventArgs e)
        {
            cmouse_Wheel = false; //滑轮不可用
        }

        private void TakeScrollHard_panel_MouseMove(object sender, MouseEventArgs e)
        {
            cCalc_Scroll();
            if (cmouse_Wheel)   //可以用滑轮
            {
                if (cmouse_Press) //鼠标按下状态
                {
                    int set_y = TakeScrollHard_panel.Top + e.Y - cmouseOff.Y; //计算当前纵向坐标
                    if (set_y < 0) { set_y = 0; } //超范围
                    else if (set_y > climt) { set_y = climt; } //超范围
                    else { TakeScrollHard_panel.Location = new Point(cset_x, set_y); } //滚动块的定位

                    int p_set = Convert.ToInt32((parentPanel.Height - currentPanel.Height) * ((decimal)set_y / (decimal)climt));
                    if (p_set > 0) p_set = 0;
                    currentPanel.Top = p_set;
                    ShowInfoShade.Top = p_set;
                }
            }
        }

        private void TakeScrollHard_panel_MouseUp(object sender, MouseEventArgs e)
        {
            cmouse_Press = false; //鼠标放开
        }

        private void TakeScrollBar_panel_MouseMove(object sender, MouseEventArgs e)
        {
            cCalc_Scroll();  //可以使用滑轮
        }

        private void TakeScrollBar_panel_MouseUp(object sender, MouseEventArgs e)
        {
            cCalc_Scroll();
            if (cmouse_Wheel)
            {
                if (e.Button == MouseButtons.Left) //鼠标左键
                {
                    int set_y = e.Y; //当前纵坐标
                    if (set_y > climt) { set_y = climt; } //超范围
                    TakeScrollHard_panel.Location = new Point(cset_x, set_y); //滚动块定位
                    currentPanel.Top = -set_y;//装内容的panel滚动显示
                    ShowInfoShade.Top = -set_y;
                    cmouse_Press = false; //鼠标为放开状态

                    int p_set = Convert.ToInt32((parentPanel.Height - currentPanel.Height) * ((decimal)set_y / (decimal)climt));
                    if (p_set > 0) p_set = 0;
                    currentPanel.Top = p_set;
                    ShowInfoShade.Top = p_set;
                }
            }
        }

        private void TakeScrollBar_panel_MouseLeave(object sender, EventArgs e)
        {
            cmouse_Wheel = false; //不可使用滑轮
        }

        #region 鼠标滚轮事件
        //此鼠标滑轮事件与上面固定高度鼠标滑轮事件不同，容器高度不断变化
        internal void c_OnMouseWheel(object sender, MouseEventArgs e)
        {
            currentPanel.SuspendLayout();
            int set_y = 0;

            cCalc_Scroll();
            if (cmouse_Wheel) //是否判断鼠标滑轮
            {
                #region 按比例滚动
                //if (e.Delta > 0) //滑轮向上
                //{
                //    set_y = TakeScrollHard_panel.Location.Y - 5; //每次移动5
                //    if (set_y < 0) { set_y = 0; } //超范围
                //}
                //if (e.Delta < 0)  //滑轮向下
                //{
                //    set_y = TakeScrollHard_panel.Location.Y + 5; //每次移动5
                //    if (set_y > climt) { set_y = climt; } //超范围
                //}
                //TakeScrollHard_panel.Location = new Point(cset_x, set_y); //滚动块的定位

                //int p_set = Convert.ToInt32((parentPanel.Height - currentPanel.Height) * ((decimal)set_y / (decimal)climt));
                //if (p_set > 0) p_set = 0;
                //currentPanel.Top = p_set;
                ////ShowInfoShade.Top = p_set;
                #endregion

                #region 按像素滚动
                if (e.Delta > 0)     //滚轮向上，Top正增长
                {
                    //到达顶部不翻滚
                    if (currentPanel.Top == 0)
                    {
                        #region 滚动到达顶部再次触发滚动翻页，需要加载更多的数据
                        //触发添加数据的监听
                        if (mSroller != null && canAdd == 1)
                        {
                            //翻页

                            canAdd = 0;
                            mSroller();
                            if (canAdd != -1)
                                canAdd = 1;
                        }
                        #endregion

                        currentPanel.ResumeLayout();
                        return;
                    }

                    currentPanel.Top = (currentPanel.Top + v_scale) > 0 ?
                        0 :     //超范围，顶部空白
                        currentPanel.Top + v_scale;      //按刻度滚动

                    ShowInfoShade.Top = currentPanel.Top;
                }
                if (e.Delta < 0)     //滚轮向下
                {
                    if (currentPanel.Top == parentPanel.Height - currentPanel.Height ||     //到达底部不翻滚
                        parentPanel.Height - currentPanel.Height >= 0)  //底部空白不滚动
                    {
                        currentPanel.ResumeLayout();
                        return;
                    }

                    currentPanel.Top = (currentPanel.Top - v_scale) < (parentPanel.Height - currentPanel.Height) ?  //是否滚动将会超过最大滚动值
                        (parentPanel.Height - currentPanel.Height) :    //超范围
                        (currentPanel.Top - v_scale);       //按刻度滚动
                    //currentPanel.Top = -32768;    //极限值
                    ShowInfoShade.Top = currentPanel.Top;
                }
                set_y = Convert.ToInt32((decimal)currentPanel.Top / (decimal)(parentPanel.Height - currentPanel.Height) * (decimal)climt);
                TakeScrollHard_panel.Location = new Point(cset_x, set_y);
                #endregion
            }
            currentPanel.ResumeLayout();
        }
        #endregion

        #region 滚动条跟随滚动面板改变大小
        private void CurrentPanel_SizeChanged(object sender, EventArgs e)
        {

            climt = TakeScrollBar_panel.Height - TakeScrollHard_panel.Height; //滚动最大高度
        }
        #endregion

        #region 滚动条直接到底部
        public void SetVScroolToBottom()
        {
            if (currentPanel == null)
                return;

            Invoke(new Action(() =>
            {
                TakeScrollHard_panel.Location = new Point(cset_x, climt);
                //面板拉到最底部
                currentPanel.Top = (parentPanel.Height - currentPanel.Height) > 0 ? 0 : (parentPanel.Height - currentPanel.Height);
                ShowInfoShade.Top = currentPanel.Top;
            }));
        }
        #endregion

        #region 更新进度条和panel的相对位置
        /// <summary>
        /// 更新进度条和panel的相对位置
        /// </summary>
        public void UpdateVScrollLocation()
        {
            #region 调整currentPanel.Top
            //如果底部有空白
            if (currentPanel.Top < (parentPanel.Height - currentPanel.Height))
                currentPanel.Top = parentPanel.Height - currentPanel.Height;
            //如果顶部有空白
            if (currentPanel.Top > 0)
                currentPanel.Top = 0;
            #endregion
            ShowInfoShade.Top = currentPanel.Top;

            int set_y = 0;
            try
            {
                //滚动条跟随Panel
                set_y = Convert.ToInt32((decimal)currentPanel.Top / (decimal)(parentPanel.Height - currentPanel.Height) * (decimal)climt);
                TakeScrollHard_panel.Location = new Point(cset_x, set_y);
            }
            catch (Exception ex)
            {
                LogUtils.Log("UpdateVScrollLocation错误   =_=  :::" + ex.Message);
            }
        }
        #endregion
    }
}
