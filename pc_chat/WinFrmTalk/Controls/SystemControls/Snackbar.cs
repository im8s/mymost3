using System;
using System.Drawing;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WinFrmTalk.Controls.SystemControls
{

    /// <summary>
    /// 提示框控件
    /// </summary>
    public partial class Snackbar : Control
    {

        /// <summary>   
        /// 显示时间(一般为3秒)
        /// </summary>
        public const int DisplayTime = 3000;

        public const int MIN_WIDTH = 120;
        public const int MARGIN_BOTTOM = 20;

        private Label mTextView;


        public Snackbar()
        {
            InitializeComponent();
            this.BackColor = ColorTranslator.FromHtml("#323232");
            this.Visible = false;//默认隐藏

            this.Height = 36;
            this.Width = MIN_WIDTH;


            InitText();
        }

        private void InitText()
        {
            mTextView = new Label
            {
                ForeColor = ColorTranslator.FromHtml("#FFF"),
                Dock = DockStyle.Fill,
                //mTextView.Anchor = AnchorStyles.None;
                TextAlign = ContentAlignment.MiddleCenter,//垂直水平居中
                Font = new Font("黑体", 9F, FontStyle.Regular, GraphicsUnit.Point, ((byte)(134)))
            };
            //mTextView.Text = content.ToString();
            this.Controls.Add(mTextView);
        }


        //#region 显示提示文本消息
        ///// <summary>
        ///// 显示提示文本消息
        ///// </summary>
        ///// <param name="content"></param>
        //public void Enqueue(string content)
        //{
        //    HttpUtils.Instance.isVisibleTip = true;
        //    mTextView.Text = content;
        //    this.Visible = true;
        //    Task.Factory.StartNew(() =>
        //    {
        //        Thread.Sleep(DisplayTime);
        //        this.Invoke(new Action(() =>
        //        {
        //            this.Visible = false;
        //            HttpUtils.Instance.isVisibleTip = false;

        //        }));
        //    });
        //}
        //#endregion

        public void SetText(string text) {
            HttpUtils.Instance.isVisibleTip = true;
            this.Visible = true;
            mTextView.Text = text;
        }

        public void HideText() {
            HttpUtils.Instance.isVisibleTip = false;
            this.Visible = false;
        }

        //#region 添加元素至容器内
        ///// <summary>
        ///// 添加各种类型元素至容器内(此方法只能主线程调用)
        ///// </summary>
        ///// <param name="content">(支持String和所有控件)</param>
        //private void AddObjectToContainer(object content)
        //{
        //    /*
        //    if (this.Container.Components.Count > 0)
        //    {
        //        for (int i = 0; i < this.Container.Components.Count; i++)
        //        {
        //            this.Container.Remove(this.Container.Components[i]);
        //        }
        //    }*/
        //    if (content is string)
        //    {
        //        var mTextView = new Label();
        //        mTextView.ForeColor = ColorTranslator.FromHtml("#FFF");
        //        mTextView.Dock = DockStyle.Fill;
        //        //mTextView.Anchor = AnchorStyles.None;
        //        mTextView.TextAlign = ContentAlignment.MiddleCenter;//垂直水平居中
        //        mTextView.Font = new Font("黑体", 9F, FontStyle.Regular, GraphicsUnit.Point, ((byte)(134)));
        //        mTextView.Text = content.ToString();
        //        this.Controls.Clear();
        //        this.Controls.Add(mTextView);
        //    }
        //    else
        //    {
        //        this.Controls.Clear();
        //        this.Controls.Add(content as Control);
        //    }
        //}
        //#endregion


        //protected override void OnPaint(PaintEventArgs pe)
        //{
        //    base.OnPaint(pe);
        //}


    }
}
