using RichTextBoxLinks;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;


namespace WinFrmTalk.View.list
{
    public class TipsAdapter : IBaseAdapter
    {
        #region 变量
        private List<GroupNotices> mDatas;//公告集合
        private List<USEGroupTips> tipslst = new List<USEGroupTips>();//控件集合
        private FrmGrouptips GroupTips;//窗体用于传值
        #endregion

        /// <summary>
        /// 获取数据集合的数量
        /// </summary>
        /// <returns></returns>
        public override int GetItemCount()
        {
            return mDatas.Count;
        }
        public void SetMaengForm(FrmGrouptips tips)
        {
            this.GroupTips = tips;
        }
        /// <summary>
        ///创建控件
        /// </summary>
        /// <param name="i"></param>
        /// <returns></returns>
        public override Control OnCreateControl(int index)
        {



            USEGroupTips uSEGroupTips = new USEGroupTips();

            EQShowInfoPanelAlpha eQShowInfo = new EQShowInfoPanelAlpha();//透明遮罩 

           
            eQShowInfo.Location = uSEGroupTips.Location;
            eQShowInfo.BringToFront();




            uSEGroupTips.lblNickName.Text = mDatas[index].NickName;
            uSEGroupTips.lblDate.Text = TimeUtils.FromatTime(mDatas[index].Time);
            uSEGroupTips.pic.Size = new Size(35, 35);
            ImageLoader.Instance.DisplayAvatar(mDatas[index].Userid, uSEGroupTips.pic);
            uSEGroupTips.BackColor = Color.White;
           //  uSEGroupTips.lblTips.Text = mDatas[index].text;
            uSEGroupTips.Tag = mDatas[index].Id;
            uSEGroupTips.ContextMenuStrip = GroupTips.ContextDel;
            GroupTips.SelectItems = uSEGroupTips;

            eQShowInfo.MouseDown += GroupTips.LblTips_MouseDown;//鼠标事件
         //   uSEGroupTips.lblTips.ContentsResized += GroupTips.lblTips_ContentsResized;

        
        //    return uSEGroupTips;

            RichTextBoxEx richText = new RichTextBoxEx();
            richText.SelectionFont = new Font(Applicate.SetFont, 10);
            richText.Font = new Font(Applicate.SetFont, 10);
            richText.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            richText.Size = new Size(420, 30);
            richText.BackColor = Color.WhiteSmoke;
            richText.Location = new Point(55, 50);
            richText.BorderStyle = BorderStyle.None;
            richText.ScrollBars = RichTextBoxScrollBars.None;
            richText.ReadOnly = true;
            richText.BackColor = Color.White;
            //  防止换行
            richText.Multiline = true;
            richText.BringToFront();
            uSEGroupTips.tips = mDatas[index].text;
            richText.Text = uSEGroupTips.tips;

            richText.Name = "ritch";
            richText.ContentsResized += GroupTips.lblTips_ContentsResized;
            
            richText.DetectUrls = true;
            // 文字提取凭
           // FrmHistoryMsg.Calc_PanelWidth(richText, mDatas[index].Userid);//这行代码会导致字体变成默认的宋体
           
            uSEGroupTips.Controls.Add(eQShowInfo);
           

            // eQShowInfo.Tag = uSEGroupTips;
            uSEGroupTips.Controls.Add(richText);
            

            tipslst.Add(uSEGroupTips);
            eQShowInfo.Size = new Size(uSEGroupTips.Size.Width, OnMeasureHeight(index));
            return uSEGroupTips;
        }
        /// <summary>
        /// 控件的高度
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public override int OnMeasureHeight(int index)

         {
            MessageObject msg = new MessageObject();
            msg.content = mDatas[index].text;
            EQControlManager.CalculateWidthAndHeight_Text(msg,false,420);
            if(msg.BubbleHeight== 26)
            {
                return msg.BubbleHeight + 87;
            }
            else
            {
                return msg.BubbleHeight + 70;//62是根据测试得到根据控件的高度并不固定
            }
            
            
        }
        /// <summary>
        /// 移除某项数据
        /// </summary>
        /// <param name="index"></param>
        public override void RemoveData(int index)
        {
            mDatas.RemoveAt(index);
        }
        /// <summary>
        /// 绑定数据
        /// </summary>
        /// <param name="data"></param>
        public void BindDatas(List<GroupNotices> data)
        {
            mDatas = data;
        }
        /// <summary>
        /// 获取某项的索引数
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        public int GetIndexByFriendId(string Id)
        {

            for (int i = 0; i < GetItemCount(); i++)
            {
                if (GetDatas(i).Id.Equals(Id))
                {
                    return i;
                }
            }

            return -1;
        }
        /// <summary>
        /// 返回某一项
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public GroupNotices GetDatas(int index)
        {

            return mDatas[index];
        }
    }
}
