
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.View;
using WinFrmTalk.Properties;
using System.IO;

namespace WinFrmTalk
{
    public partial class GroupFileItem : UserControl
    {
        //接收窗体传递过来的参数
        public RoomFileBean JsonFileBean;

        public GroupFileItem()
        {
            InitializeComponent();
            #region 继承父类的方法
            //Click Event
            pboxIcon.Click += Parent_Click;
            lblName.Click += Parent_Click;
            lblNickName.Click += Parent_Click;
            lblLength.Click += Parent_Click;
            lblDown.Click += Parent_Click;
            lblDatime.Click += Parent_Click;
            //MouseClick
            pboxIcon.MouseClick += Parent_MouseClick;
            lblName.MouseClick += Parent_MouseClick;
            lblNickName.MouseClick += Parent_MouseClick;
            lblLength.MouseClick += Parent_MouseClick;
            lblDown.MouseClick += Parent_MouseClick;
            lblDatime.MouseClick += Parent_MouseClick;
            //MouseEnter 
            pboxIcon.MouseEnter += Parent_MouseEnter;
            lblName.MouseEnter += Parent_MouseEnter;
            lblNickName.MouseEnter += Parent_MouseEnter;
            lblLength.MouseEnter += Parent_MouseEnter;
            lblDown.MouseEnter += Parent_MouseEnter;
            lblDatime.MouseEnter += Parent_MouseEnter;
            //MouseLeave
            pboxIcon.MouseLeave += Parent_MouseLeave;
            lblName.MouseLeave += Parent_MouseLeave;
            lblNickName.MouseLeave += Parent_MouseLeave;
            lblLength.MouseLeave += Parent_MouseLeave;
            lblDown.MouseLeave += Parent_MouseLeave;
            lblDatime.MouseLeave += Parent_MouseLeave;
            //MouseDown
            pboxIcon.MouseDown += Parent_MouseDown;
            lblName.MouseDown += Parent_MouseDown;
            lblNickName.MouseDown += Parent_MouseDown;
            lblLength.MouseDown += Parent_MouseDown;
            lblDown.MouseDown += Parent_MouseDown;
            lblDatime.MouseDown += Parent_MouseDown;
            #endregion
        }

        #region 父类方法
        //点击

        private void Parent_Click(object sender, EventArgs e)
        {
            this.OnClick(e);
        }
        //点击
        private void Parent_MouseClick(object sender, MouseEventArgs e)
        {
            this.OnMouseClick(e);
        }
        //进入
        private void Parent_MouseEnter(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        private void Parent_MouseLeave(object sender, EventArgs e)
        {
            this.OnMouseLeave(e);
        }

        private void Parent_MouseDown(object sender, EventArgs e)
        {
            this.OnMouseEnter(e);
        }
        #endregion

        public RoomFileBean data;


        private bool is_choose;//是否被选中状态
        public bool IsSelect
        {
            get
            {
                return is_choose;
            }
            set {

                is_choose = value;

                if (is_choose)
                {
                    BackColor = ColorTranslator.FromHtml("#CAC8C6");
                }
                else
                {
                    BackColor = Color.White;
                }
            }
        }

        //添加属性
        //添加文件名字
        public string fileName
        {
            get
            {
                return lblName.Text;
            }
            set
            {
                lblName.Text = value;
            }
        }
        //添加上传人的名字
        public string nickName
        {

            get
            {
                return lblNickName.Text;
            }
            set
            {
                lblNickName.Text = value;
            }
        }
        //时间
        public string Time
        {
            get
            {
                return lblDatime.Text;
            }
            set
            {
                lblDatime.Text = value;
            }
        }
        //长度
        public string Legth
        {
            get
            {
                return lblLength.Text;
            }
            set
            {
                lblLength.Text = value;
            }
        }
        //头像
        public PictureBox GetInco()
        {
            return pboxIcon;
        }


        //下载的状态
        public string Staue
        {
            get
            {
                return lblDown.Text;
            }
            set
            {
                lblDown.Text = value;
            }
        }
        //地址
        public string Url { get; set; }
        //群文件id
        public string ShareId { get; set; }
        public string roomJid { get; set; }
        //鼠标进入的时候颜色变为白色
        public void GroupFileItem_MouseEnter(object sender, EventArgs e)
        {
            if (!IsSelect)
            {
                this.BackColor = DefaultBackColor;
            }
           
        }

        public void GroupFileItem_MouseLeave(object sender, EventArgs e)
        {
            if (!IsSelect)
            {
                this.BackColor = Color.White;
            }
            
        }
        //鼠标验证事件
        
        //状态
        public bool isDown { get; internal set; }


        // 0 默认状态  ，1下载中，2.上传中

        private int downState;
        public int DownState
        {
            get
            {
                return downState;
            }
            set
            {
                downState = value;

                //上传状态
                skp.Visible = downState == 1 || downState == 2;

                if (downState == 1)
                {
                    lblDown.Text = "下载中";
                }

                if (downState == 2)
                {
                    lblDown.Text = "上传中";
                }
            }
        }

        //上传的值
        public void SetProgress(int progress)
        {
            //上传的当前值
            skp.Value = progress;
        }


        public void FillFileIcon()
        {
            switch (data.type)
            {
                case 1:  // 图片

                    if ("gif".Equals(FileUtils.GetFileExtension(Url).ToLower()))
                    {
                        ImageLoader.Instance.Load(Url).NoCache().Into((bit, path)=> {

                            FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                            Image img = Image.FromStream(fs);
                            pboxIcon.Image = img;
                        });
                    }
                    else
                    {
                        ImageLoader.Instance.Load(Url).NoCache().Into(pboxIcon);
                    }
                    
                    break;
                case 2: // music
                    pboxIcon.Image = Resources.ic_muc_flie_type_y;

                    break;
                case 3: // 视屏
                    pboxIcon.Image = Resources.ic_muc_flie_type_v;
                    break;
                case 5: // xls
                    pboxIcon.Image = Resources.ic_muc_flie_type_x;
                    break;
                case 6: // doc
                    pboxIcon.Image = Resources.ic_muc_flie_type_w;
                    break;
                case 4: // ppt
                    pboxIcon.Image = Resources.ic_muc_flie_type_p;
                    break;
                case 10: // pdf
                    pboxIcon.Image = Resources.ic_muc_flie_type_f;
                    break;
                case 11: // apk
                    pboxIcon.Image = Resources.ic_muc_flie_type_a;
                    break;
                case 8: // txt
                    pboxIcon.Image = Resources.ic_muc_flie_type_t;
                    break;
                case 7: // rar of zip
                    pboxIcon.Image = Resources.ic_muc_flie_type_z;
                    break;
                default:
                    pboxIcon.Image = Resources.ic_muc_flie_type_what;
                    break;
            }
        }
    }
}
