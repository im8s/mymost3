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
   
    public partial class USEFriendList : UserControl
    {
        private List<object> _friendsList = new List<object>();
      
        private int _Row;
        private int _Col;
        private int _Count;
        public Size _PicSize;
        //绑定的添加的集合
        public List<object> FriendsList
        {
            get { return _friendsList; }
            set { _friendsList = value; }
        }
      //固定显示的行
        public int  Row
        {
            get { return _Row; }
            set { _Row = value; }
        }
            
        //固定显示的列
        public int Col
        {
            get { return _Col; }
            set { _Col = value; }

        }
        public int Count
        {
            get { return _Count; }
            set { _Count = value; }
        }
        public Size PicSize
        {
            get { return _PicSize; }
            set { _PicSize = value; }
        }
        public USEFriendList()
        {
            InitializeComponent();
            Row = 1;
            Col = 1;
        }

        //1.多行1列（有滚动条）
        //2多列1行有滚动条）
        //3.多列多行（有滚动条）
        //4.列数最大的限制；总数的最大限制
        //列数最大限制时，外框也需要限制
        //需要做一个限制？当确定了col，和row以后窗体就固定大小就不能改变大小
        /// <summary>
        /// 计算所有的宽度和高度
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void USEFriendList_Load(object sender, EventArgs e)
        {
            int w = palList.Size.Width;
            int h = palList.Size.Height;
            //  USEpicAddName uSEpicAddName = new USEpicAddName();
            //  int picW = uSEpicAddName.Width;
            //   int picH = uSEpicAddName.Height;

            //  int count = _friendsList.Count;
           
            Col = Count/Row;
            if(Row == 1)
            {
                palList.WrapContents = false;
            }
            else
            {
                palList.WrapContents = true;
            }
           
            for (int i = 0; i < Row; i++)
               {
                for (int j = 0; j < Col; j++)
                {
                    USEpicAddName uSEpicAddName = new USEpicAddName();
                    uSEpicAddName.Size = new Size(68, 100);
                    uSEpicAddName.pics.Size = PicSize;
                  //  uSEpicAddName.pics = WinFrmTalk.Properties.Resources.Logo;
                    uSEpicAddName.Location = new Point(3 + uSEpicAddName.Size.Width * j, 3 + uSEpicAddName.Size.Height * i);
                    uSEpicAddName.lblName.Location = new Point(0, PicSize.Height + 15);
                  
                    uSEpicAddName.lblName.Text = (i * Col + j).ToString() + "方法";
                    palList.Controls.Add(uSEpicAddName);
                 /*  if ((i == Row - 1) && (j == lost)&&(Row>1))
                    {
                        break;
                    }*/
                }
            }



        }
    }
}
