using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Helper.MVVM;

namespace WinFrmTalk
{
    public partial class MyVScrollBar : UserControl
    {
        #region 列表需求（如数据库列表）
        public int pageIndex = 1;
        #endregion

        int climt, cset_x; //滚动位置最大值和固定的左右的位置
        bool cmouse_Press = false; //鼠标按下
        bool cmouse_Wheel = true; //鼠标滑轮事件
        Point cmouseOff; //存放当前鼠标位置
        Control currentPanel;   //正在活动的控件（需要滚动的）
        Control parentPanel;    //活动panel和滚动条共同的父级控件
        /// <summary>
        /// 每滚动一下的像素
        /// </summary>
        public int v_scale = 60;

        public Action<int> mSroller ;   //向下滚动监听
        public Action topSroller;       //滑动到顶部的监听

        public int lastScorll { get; private set; }

        /// <summary>
        /// 控制容器不会疯狂触发加载
        /// <para>-1为没有更多数据可以加载， 0为正在加载数据不允许重复触发， 1为可以加载更多数据</para>
        /// </summary>
        public int canAdd { get; set; }

        public int canTop { get; set; }

        /// <summary>
        /// 添加向下滚动监听
        /// </summary>
        /// <param name="sroller"></param>
        /// <param name="FristPageCount"></param>
        internal void AddScollerBouttom(Action<int> sroller, int FristPageCount)
        {
            mSroller = sroller;
            canAdd = 1;
            pageIndex = FristPageCount;
        }

        /// <summary>
        /// 添加滑动到顶部的监听
        /// </summary>
        /// <param name="sroller"></param>
        internal void AddScollerTop(Action sroller)
        {
            topSroller = sroller;
            canTop = 1;
        }

        #region 设置需要滚动的panel
        /// <summary>
        /// 设置需要滚动的panel
        /// </summary>
        /// <param name="panel_name">需要进行滚动的panel，必须在同一父控件内</param>
        public void SetCurrentPanel(string panel_name)
        {
            currentPanel = this.Parent.Controls[panel_name];
            parentPanel = this.Parent;

            //显示对话内容框鼠标事件
            currentPanel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
            TakeScrollBar_panel.MouseWheel += new MouseEventHandler(c_OnMouseWheel);
            //滚动条位置定义
            cset_x = TakeScrollHard_panel.Location.X; //固定左右位置为当前位置
            climt = TakeScrollBar_panel.Height - TakeScrollHard_panel.Height; //滚动最大高度
            TakeScrollHard_panel.Location = new Point(cset_x, 0); //先将位置设置到最顶
        }
        #endregion

        /// <summary>
        /// 实例化自定义滚动条
        /// </summary>
        public MyVScrollBar()
        {
            InitializeComponent();
        }

        private void MyVScrollBar_Load(object sender, EventArgs e)
        {
            
        }

        #region 设置滚动条是否允许滚动
        /// <summary>
        /// 设置滚动条是否允许滚动
        /// </summary>
        private void cCalc_Scroll()
        {
            if ((currentPanel.Height - parentPanel.Height) <= 0)
            {
                cmouse_Wheel = false;
                currentPanel.Top = 0;
                //MultiSelectPanel.Top = 0;
                TakeScrollHard_panel.Location = new Point(cset_x, 0);
            }
            else
            {
                cmouse_Wheel = true;
            }
        }
        #endregion

        #region 滚动块事件
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
                    //MultiSelectPanel.Top = p_set;
                }
            }
        }

        private void TakeScrollHard_panel_MouseUp(object sender, MouseEventArgs e)
        {
            cmouse_Press = false; //鼠标放开
        }
        #endregion

        #region 滚动条事件
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
                    //MultiSelectPanel.Top = -set_y;
                    cmouse_Press = false; //鼠标为放开状态

                    int p_set = Convert.ToInt32((parentPanel.Height - currentPanel.Height) * ((decimal)set_y / (decimal)climt));
                    if (p_set > 0) p_set = 0;
                    currentPanel.Top = p_set;
                    //MultiSelectPanel.Top = p_set;
                }
            }
        }

        private void TakeScrollBar_panel_MouseLeave(object sender, EventArgs e)
        {
            cmouse_Wheel = false; //不可使用滑轮
        }
        #endregion

        #region 鼠标滚轮事件
        //此鼠标滑轮事件与上面固定高度鼠标滑轮事件不同，容器高度不断变化
        public void c_OnMouseWheel(object sender, MouseEventArgs e)
        {
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
                ////MultiSelectPanel.Top = p_set;
                #endregion

                #region 按像素滚动
                if(e.Delta > 0)     //滚轮向上
                {
                    //到达顶部不翻滚
                    if (currentPanel.Top != 0)
                    {
                        currentPanel.Top += v_scale;      //按刻度滚动
                        if (currentPanel.Top > 0) currentPanel.Top = 0;     //超范围，顶部空白
                    }
                }
                if (e.Delta < 0)     //滚轮向上
                {
                    //到达底部不翻滚
                    if (currentPanel.Top == parentPanel.Height - currentPanel.Height)
                        return;

                    currentPanel.Top -= v_scale;      //按刻度滚动
                    if (currentPanel.Top < (parentPanel.Height - currentPanel.Height))  //Top为负数
                        currentPanel.Top = parentPanel.Height - currentPanel.Height;    //超范围
                }
                set_y = Convert.ToInt32((decimal)currentPanel.Top / (decimal)(parentPanel.Height - currentPanel.Height) * (decimal)climt);
                TakeScrollHard_panel.Location = new Point(cset_x, set_y);
                #endregion

                #region 滚动80%，需要加载更多的数据
                if((decimal)TakeScrollHard_panel.Location.Y / (decimal)climt > (decimal)0.9)
                {
                    //触发添加数据的监听
                    if (mSroller != null && canAdd == 1)
                    {
                        //翻页
                        pageIndex++;

                        canAdd = 0;
                        mSroller(pageIndex);
                        if (canAdd != -1)
                            canAdd = 1;
                    }

                }
                #endregion

                #region 滚动到达顶部，触发监听
                if (currentPanel.Top == 0 && canTop == 1)
                {
                    //触发监听
                    if (topSroller != null)
                    {
                        canTop = 0;
                        topSroller();
                        if (canTop != -1)
                            canTop = 1;
                    }

                }
                #endregion
            }
        }
        #endregion

        #region 更新进度条和panel的位置
        /// <summary>
        /// 更新进度条和panel的位置
        /// </summary>
        public void UpdateVScrollLocation()
        {
            if (currentPanel == null || parentPanel == null)
                return;

            #region 调整currentPanel.Top
            //如果底部有空白
            if (currentPanel.Top < (parentPanel.Height - currentPanel.Height))   
                currentPanel.Top = parentPanel.Height - currentPanel.Height;
            //如果顶部有空白
            if (currentPanel.Top > 0)
                currentPanel.Top = 0;
            #endregion

            int set_y = 0;

            //如果面板需要滚动条滚动
            cCalc_Scroll();
            if (cmouse_Wheel)
                set_y = Convert.ToInt32((decimal)currentPanel.Top / (decimal)(parentPanel.Height - currentPanel.Height) * (decimal)climt);
            TakeScrollHard_panel.Location = new Point(cset_x, set_y);
        }
        #endregion
    }
}
