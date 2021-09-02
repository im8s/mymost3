using CCWin;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Properties;
using ThoughtWorks.QRCode.Codec;

namespace WinFrmTalk
{
    public partial class FrmQRCode : FrmSuspension
    {
        public FrmQRCode()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }
        /// <summary>
        /// 好友二维码
        /// </summary>
        /// <param name="userId"></param>
        public void FriendShow(string userId, string accountId)
        {
            if (!string.IsNullOrEmpty(accountId))
            {
                string str = Applicate.URLDATA.data.website + "?action=user&shikuId=" + accountId;
                LogUtils.Log("生成二维码： "+str);
                Bitmap bmp1 = createCode(str);
                Bitmap bmp2 = null;
                string path = ImageLoader.Instance.GetHeadUrl(userId, false);
                //头像嵌入
                ImageLoader.Instance.Load(path).Error((err) =>
                {
                    bmp2 = Resources.avatar_default;
                    Graphics g = Graphics.FromImage(bmp1);
                    g.DrawImage(bmp1, 0, 0, bmp1.Width, bmp1.Height);
                    g.DrawImage(bmp2, bmp1.Width / 2 - 30 / 2, bmp1.Height / 2 - 30 / 2, 30, 30);
                    GC.Collect();
                    picQRCode.Image = bmp1;


                }).Into((bit, path1) =>
                {
                    bmp2 = bit;
                    Graphics g = Graphics.FromImage(bmp1);
                    g.DrawImage(bmp1, 0, 0, bmp1.Width, bmp1.Height);
                    g.DrawImage(bmp2, bmp1.Width / 2 - 30 / 2, bmp1.Height / 2 - 30 / 2, 30, 30);
                    GC.Collect();
                    picQRCode.Image = bmp1;

                });
            }
           
            this.Show();
            this.Focus();
            this.BringToFront();
        }
        /// <summary>
        /// 群二维码
        /// </summary>
        /// <param name="roomId"></param>
        internal void RoomShow(string roomId)
        {
            if (!string.IsNullOrEmpty(roomId))
            {
                string str = Applicate.URLDATA.data.website + "?action=group&shikuId=" + roomId;
                picQRCode.Image = createCode(str);
            }
            if (string.IsNullOrEmpty(roomId))
            {
                LogHelper.LogInfo("生成二维码失败roomID为空");
               LogUtils.Log("生成二维码失败roomID为空");
            }
            this.Show();
            this.BringToFront();


        }
        /// <summary>
        /// 生成二维码
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        private Bitmap createCode(string str)
        {
            QRCodeEncoder qrCodeEncoder = new QRCodeEncoder();
            qrCodeEncoder.QRCodeEncodeMode = QRCodeEncoder.ENCODE_MODE.BYTE; //编码方式(注意：BYTE能支持中文，ALPHA_NUMERIC扫描出来的都是数字)
            qrCodeEncoder.QRCodeScale = 4; //大小(值越大生成的二维码图片像素越高)
            qrCodeEncoder.QRCodeVersion = 0; //版本(注意：设置为0主要是防止编码的字符串太长时发生错误)
            qrCodeEncoder.QRCodeErrorCorrect = QRCodeEncoder.ERROR_CORRECTION.M; //错误效验、错误更正(有4个等级)
            qrCodeEncoder.QRCodeBackgroundColor = Color.White; //背景色
            qrCodeEncoder.QRCodeForegroundColor = Color.Black; //前景色
            return qrCodeEncoder.Encode(str, Encoding.UTF8);
        }
    }
}
