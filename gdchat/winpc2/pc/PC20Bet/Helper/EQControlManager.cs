using Newtonsoft.Json;
using RichTextBoxLinks;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Helper.MVVM;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    /// <summary>
    /// 自定义控件的公用方法
    /// </summary>
    public static class EQControlManager
    {
        #region 获取字符串的像素宽高
        /// <summary>
        /// 获取字符串的像素宽高
        /// </summary>
        /// <param name="value">字符串值</param>
        /// <param name="font">字符串文本格式</param>
        /// <returns>浮点型Size</returns>
        internal static SizeF GetStringTheSize(string value, Font font)
        {
            Label label = new Label();
            //GraphicsPath gp = new GraphicsPath();
            //StringFormat format = StringFormat.GenericDefault;
            //gp.AddString(value, font.FontFamily, (int)font.Style, font.Height, new PointF(0, 0), format);
            //RectangleF rcBound = gp.GetBounds();

            Graphics graphics = label.CreateGraphics();
            SizeF sizeF = graphics.MeasureString(value, font);
            graphics.Dispose();
            label.Dispose();
            return sizeF;
        }
        #endregion

        public static void StrAddEllipsis(Control control, Font font, int maxWidth = 50)
        {
            //获取行文字所占的大小
            SizeF sizeF = EQControlManager.GetStringTheSize(control.Text, font);
            //替换省略号
            string lable_str = control.Text;
            //过长时直接移除一部分
            if (lable_str.Length > maxWidth)
                lable_str = lable_str.Remove(maxWidth);
            if (sizeF.Width > control.Width)
            {
                while (sizeF.Width >= control.Width - 20)
                {
                    lable_str = lable_str.Remove(lable_str.Length - 1);
                    sizeF = EQControlManager.GetStringTheSize(lable_str, font);
                }
                control.Text = lable_str + "...";
            }
        }

        #region 修改图片的尺寸
        /// <summary>
        /// 修改图片的尺寸
        /// </summary>
        /// <param name="old_bitmap"></param>
        /// <param name="new_width"></param>
        /// <param name="new_height"></param>
        /// <returns></returns>
        internal static Bitmap ModifyBitmapSize(Bitmap old_bitmap, int new_width, int new_height)
        {
            Bitmap new_bitmap = new Bitmap(new_width, new_height);
            Graphics g = Graphics.FromImage(new_bitmap);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.SmoothingMode = SmoothingMode.HighQuality;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;
            g.DrawImage(old_bitmap, new Rectangle(0, 0, new_width, new_height), new Rectangle(0, 0, old_bitmap.Width, old_bitmap.Height), GraphicsUnit.Pixel);
            g.Dispose();
            //old_bitmap.Dispose();

            return new_bitmap;
        }
        #endregion

        #region 按最大值修改长宽进行自适应
        /// <summary>
        /// 按最大值修改长宽进行自适应
        /// </summary>
        /// <param name="width"></param>
        /// <param name="height"></param>
        /// <param name="maxWidth"></param>
        /// <param name="maxHeight"></param>
        internal static void ModifyWidthAndHeight(ref int width, ref int height, int maxWidth, int maxHeight)
        {
            //暂时只考虑长宽最大值相同的情况
            if (maxWidth != maxHeight)
            {
                return;
            }
            //都没有超过最大值
            if (width <= maxWidth && height <= maxHeight)
            {
                return;
            }
            //只有宽度超过了最大值
            else if (width > maxWidth && height <= maxHeight)
            {
                height = Convert.ToInt32((decimal)maxWidth / (decimal)width * (decimal)height);
                width = maxWidth;
            }
            //只有高度超过了最大值
            else if (width <= maxWidth && height > maxHeight)
            {
                width = Convert.ToInt32((decimal)maxHeight / (decimal)height * (decimal)width);
                height = maxHeight;
            }
            //都超过了最大值
            else if (width > maxWidth && height > maxHeight)
            {
                if (width >= height)
                {
                    height = Convert.ToInt32((decimal)maxWidth / (decimal)width * (decimal)height);
                    width = maxWidth;
                }
                else
                {
                    width = Convert.ToInt32((decimal)maxHeight / (decimal)height * (decimal)width);
                    height = maxHeight;
                }
            }
        }
        #endregion

        #region 对两张图片进行重叠
        /// <summary>
        /// 对两张图片进行重叠
        /// </summary>
        /// <param name="fImage">透明度（0-1）</param>
        /// <param name="strFrontImage">前景图（透明）</param>
        /// <param name="strBackImage">背景图（不透明）</param>
        internal static Bitmap getMixImage(float fImage, Bitmap frontImage, string strBackImage)
        {
            if (!File.Exists(strBackImage))
                return null;

            try
            {
                Bitmap background = new Bitmap(strBackImage);
                int iwidth = background.Width > frontImage.Width ? background.Width : frontImage.Width;
                int iheight = background.Height > frontImage.Height ? background.Height : frontImage.Height;
                //按最大值修改气泡长宽
                ModifyWidthAndHeight(ref iwidth, ref iheight, 200, 200);
                background = ModifyBitmapSize(background, iwidth, iheight);
                //frontImage = ModifyBitmapSize(frontImage, 140, 160);
                Bitmap mixImage2 = new Bitmap(iwidth, iheight);
                //this.mixImage.Width = iwidth;            
                //this.mixImage.Height = iheight;            
                Graphics g = Graphics.FromImage(mixImage2);
                float[][] colormatrix ={
                new float[]{1,0,0,0,0},
                //代表了R                                        
                new float[]{0,1,0,0,0},//代表了G                                        
                new float[]{0,0,1,0,0},//代表了B                                        
                new float[]{0,0,0,fImage,0},//代表了A                                        
                new float[]{0,0,0,0,1}            };
                ColorMatrix cm = new ColorMatrix(colormatrix);
                ImageAttributes imageAtt = new ImageAttributes();
                imageAtt.SetColorMatrix(cm, ColorMatrixFlag.Default, ColorAdjustType.Bitmap);
                //g.DrawImage(background, new Rectangle(iwidth/2 - 15, iheight/2 - 15, 30, 30));
                //g.DrawImage(frontImage, new Rectangle(0, 0, iwidth, iheight), 0, 0, iwidth, iheight, GraphicsUnit.Pixel, imageAtt);
                g.DrawImage(background, new Rectangle(0, 0, iwidth, iheight));
                g.DrawImage(frontImage, new Rectangle(iwidth / 2 - 20, iheight / 2 - 20, 40, 40), 0, 0, frontImage.Width, frontImage.Height, GraphicsUnit.Pixel, imageAtt);
                return mixImage2;
            }
            catch (Exception ex)
            {
                return null;
            }
        }
        #endregion

        #region 改变消息的状态为送达
        /// <summary>
        /// 更新消息的状态为送达（UI）
        /// </summary>
        /// <param name="messageObject">message实体类对象</param>
        /// <param name="lab_msg">消息状态控件</param>
        public static void DrawIsSend(MessageObject messageObject, Label lab_msg)
        {
            //为0代表发送中，绘制加载动画
            //if (messageObject.isSend == 0)
            //{
            //lab_msg.Font = new Font(Program.ApplicationFontCollection.Families.Last(), 13f);//设置文字图标
            //lab_msg.Text = "";     //Unicode转中文后的转动图标
            //lab_msg.ForeColor = Color.Black;
            //lab_msg.Size = new Size(30, 20);
            //lab_msg.Image = null;
            //}
            //else
            //{
            lab_msg.Tag = "isSend_" + messageObject.isSend;
            Image msg_image = null;
            string key = "isSend_" + messageObject.isSend;
            msg_image = BubbleBgDictionary.GetBackground(key);
            if (msg_image == null || BitmapUtils.IsNull(msg_image))
            {
                //为1代表发送成功
                if (messageObject.isSend == 1)
                {
                    msg_image = Image.FromFile(@"Res\StateBg\SendBg.png");
                }
                else if (messageObject.isSend == 0)
                    msg_image = Image.FromFile(@"Res\StateBg\Sending.png");
                //如果发送失败，显示红色感叹号
                else if (messageObject.isSend == -1)
                    msg_image = Image.FromFile(@"Res\StateBg\im_send_fail_nor.png");

                int newHeigh = 18;
                int newWidth = messageObject.isSend == -1 ? 18 : 30;
                msg_image = new Bitmap(msg_image, newWidth, newHeigh);
                BubbleBgDictionary.AddBackground(key, msg_image);
            }

            if (messageObject.isSend == -1)
                lab_msg.MouseDown += (sender, e) =>
                {
                    messageObject.reSendCount = 3;
                    //防止信息状态已经变更，却还会触发事件
                    if (messageObject.isSend != -1)
                        return;
                    if (e.Button == MouseButtons.Left)
                    {
                        if (messageObject.content.Equals("error"))
                        {
                            HttpUtils.Instance.ShowTip("文件已损坏");
                            return;
                        }

                        //消息重发
                        //ShiKuManager.xmpp.SendMessage(messageObject);

                        //修改状态为0，进行重发
                        messageObject.isSend = 0;
                        //修改样式为发送中
                        if (sender is Label label && label.Name.Equals("lab_msg"))
                            DrawIsSend(messageObject, label);

                        switch (messageObject.type)
                        {
                            //图片重发后要刷新控件
                            case kWCMessageType.Image:
                                Messenger.Default.Send(messageObject, token: EQFrmInteraction.ResumeUploadImageMsg);
                                break;
                            case kWCMessageType.Video:
                                messageObject.isLoading = 1;
                                Messenger.Default.Send(messageObject, token: EQFrmInteraction.ResumeUploadVideoMsg);
                                break;
                            case kWCMessageType.Text:
                            case kWCMessageType.Voice:
                            case kWCMessageType.Location:
                            case kWCMessageType.File:
                            case kWCMessageType.History:
                            case kWCMessageType.Gif:
                            case kWCMessageType.Card:
                                ShiKuManager.SendMessage(messageObject);
                                break;
                        }
                    }
                };

            lab_msg.Text = messageObject.isSend == 1 ? "送达" : "";

            lab_msg.Size = new Size(30, 18);
            lab_msg.TextAlign = ContentAlignment.MiddleCenter;
            lab_msg.ForeColor = Color.White;
            lab_msg.Font = new Font("宋体", 8F, FontStyle.Bold, GraphicsUnit.Point, ((byte)(134)));
            //if (lab_msg.Image != null)
            //    lab_msg.Image.Dispose();
            lab_msg.Image = msg_image;
            //}
        }
        #endregion

        #region 改变消息的状态为已读
        public static void DrawIsRead(Label lab_msg)
        {
            lab_msg.Tag = "isRead";
            Image msg_image = null;
            string key = "isRead";
            msg_image = BubbleBgDictionary.GetBackground(key);

            if (msg_image == null || BitmapUtils.IsNull(msg_image))
            {
                msg_image = new Bitmap(@"Res\StateBg\ReadBg.png");
                int newHeigh = 18;
                int newWidth = 30;
                msg_image = new Bitmap(msg_image, newWidth, newHeigh);
                BubbleBgDictionary.AddBackground(key, msg_image);
            }

            lab_msg.Text = "已读";
            lab_msg.TextAlign = ContentAlignment.MiddleCenter;
            lab_msg.ForeColor = Color.White;
            lab_msg.Font = new Font("宋体", 8F, FontStyle.Bold, GraphicsUnit.Point, ((byte)(134)));
            //if (lab_msg.Image != null)
            //    lab_msg.Image.Dispose();
            lab_msg.Image = msg_image;
        }
        #endregion

        #region 改变已读人数
        /// <summary>
        /// 重绘已读人数
        /// </summary>
        /// <param name="readPerson_num"></param>
        /// <param name="lab_msg"></param>
        public static void DrawReadPerson(int readPerson_num, Label lab_msg)
        {
            if (lab_msg == null)
                return;
            lab_msg.Tag = "isSend_1";
            Font labMsgFont = new Font("微软雅黑", 8F, FontStyle.Bold, GraphicsUnit.Point, 134);
            string readPerson_txt = readPerson_num + "人";
            int newWidth = (int)GetStringTheSize(readPerson_txt, labMsgFont).Width + 5;
            if (newWidth != lab_msg.Width)
            {
                Image bg_image = Image.FromFile(@"Res\StateBg\ReadBg.png");
                Bitmap bg_bmp = new Bitmap(bg_image, new Size(newWidth, 18));
                lab_msg.Image = bg_bmp;
                lab_msg.Width = newWidth;
                lab_msg.Font = labMsgFont;
                lab_msg.ForeColor = Color.White;
                lab_msg.Size = new Size(newWidth, lab_msg.Height);
            }
            lab_msg.Text = readPerson_txt;
        }
        #endregion

        #region 不生成气泡包括remin类型的消息类型
        public static bool IsMakeControl(kWCMessageType type)
        {
            if (type == kWCMessageType.IsRead)
                return false;

            return true;
        }
        #endregion

        public static bool JudgeRtfHaveImg(string rtf)
        {
            if (rtf.IndexOf("{\\pict") > -1)
                return true;
            else
                return false;
        }

        public static string JointRtf(string value)
        {
            string rtf_intack = "{\\rtf1\\ansi\\ansicpg936\\deff0\\deflang1033\\deflangfe2052{\\fonttbl{\\f0\\fnil\\fcharset134 \\'cb\\'ce\\'cc\\'e5;}}\r\n\\viewkind4\\uc1\\pard\\lang2052\\f0\\fs18";
            rtf_intack += value + "\\par\r\n}\r\n";
            return rtf_intack;
        }

        #region 提取文本框中的图片
        public static Image RtfToImageSave(string rtf)
        {
            if (string.IsNullOrEmpty(rtf))
                return null;

            try
            {
                int ImgStartIndex = rtf.IndexOf("\\picwgoal"); //获取字符串的位置索引
                int ImgEnd1Index = rtf.IndexOf("\\pichgoal"); //获取字符串的位置索引
                int ImgEnd2Index = rtf.IndexOf("\r\n");//获取字符串的位置索引之间的数据
                string str_width = rtf.Substring(ImgStartIndex + 9, ImgEnd1Index - ImgStartIndex - 9);
                string str_height = rtf.Substring(ImgEnd1Index + 9, ImgEnd2Index - ImgEnd1Index - 9);
                int width = Convert.ToInt16(str_width) > 0 ? Convert.ToInt16(str_width) : -Convert.ToInt16(str_width);
                width = width / 15; //与正常像素大约26倍关系，goal的大约为15被关系
                int height = Convert.ToInt16(str_height);
                height = height / 15;

                //截取图片流
                int _index = rtf.IndexOf("pichgoal");
                if (_index < 0) return null;
                string _rtf = rtf.Remove(0, _index + 8);
                _index = _rtf.IndexOf("\r\n");
                _rtf = _rtf.Remove(0, _index);
                _index = _rtf.IndexOf("\\par\r\n");
                if (_index > 0)
                    _rtf = _rtf.Remove(_index);
                _rtf = _rtf.Replace("}", "").Replace("\r\n", "");

                //IList<string> _ImageList = new List<string>();
                //_ImageList.Add(_rtf);

                byte[] buffer = null;
                int _count = _rtf.Length / 2;
                //for (int i = 0; i != _ImageList.Count; i++)
                //{
                buffer = new byte[_rtf.Length / 2];
                //FileStream _File = new FileStream(Application.StartupPath + "\\" + i.ToString() + ".dat", FileMode.Create);

                for (int z = 0; z != _count; z++)
                {
                    string _TempText = _rtf[z * 2].ToString() + _rtf[(z * 2) + 1].ToString();
                    //_File.WriteByte(Convert.ToByte(_TempText, 16));
                    buffer[z] = Convert.ToByte(_TempText, 16);
                }

                //_File.Close();
                //}

                MemoryStream ms = new MemoryStream(buffer);
                Image _a = Image.FromStream(ms);
                //_a.Save("D:\\bbTest.png");
                //ms.Close();
                //ImageToRtf("D:\\bbTest.png", 1920, 1080);
                //Bitmap _a = new Bitmap(Application.StartupPath + "\\" + "0.dat");
                Bitmap _b = new Bitmap(width, height);
                Graphics g = Graphics.FromImage(_b);

                g.InterpolationMode = InterpolationMode.HighQualityBicubic;

                g.DrawImage(_a, new Rectangle(0, 0, width, height), new Rectangle(0, 0, _a.Width, _a.Height), GraphicsUnit.Pixel);
                g.Dispose();
                if (_b != null)
                {
                    //string filePath = Applicate.LocalConfigData.ImageFolderPath + Guid.NewGuid().ToString("N") + ".png";
                    //_b.Save(filePath);
                    return _b;
                }
                else
                {
                    LogUtils.Log("rtf转图片失败。。");
                }
            }
            catch (Exception ex)
            {
                LogUtils.Log("rtf转图片失败：" + ex.Message);
            }
            return null;
        }
        #endregion

        public static string ImageToRtf(string path, int width, int height)
        {
            Bitmap img = new Bitmap(path);
            using (Bitmap bmp = new Bitmap(width, height))
            {
                Graphics g = Graphics.FromImage(bmp);
                g.Clear(Color.White);
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.CompositingQuality = CompositingQuality.HighQuality;
                g.DrawImage(img, new Rectangle(0, 0, width, height), new Rectangle(0, 0, img.Width, img.Height), GraphicsUnit.Pixel);
                g.Dispose();

                MemoryStream ms = new MemoryStream();
                bmp.Save(ms, ImageFormat.Bmp);
                Image _a = Image.FromStream(ms);
                //_a.Save("D:\\bbTest1.png");
                byte[] buffer = new byte[ms.Length];
                ms.Seek(0, SeekOrigin.Begin);
                ms.Read(buffer, 0, (int)ms.Length);
                ms.Close();

                string rtf = "";
                //十进制转十六进制
                foreach (byte item in buffer)
                {
                    string _TempText = item.ToString("X");
                    rtf += _TempText.Length == 1 ? "0" + _TempText : _TempText;
                    if (rtf.Length % 78 == 0)
                        rtf += "\r\n";
                }
                //添加rtf的前缀和后缀
                string _rtf = string.Format("{{\\pict\\wmetafile8\\picw661\\pich661\\picwgoal375\\pichgoal375 \r\n{0}\r\n}}", rtf, width * 15, height * 15, width * 26, height * 26);
                //string savePath = RtfToImageSave(_rtf);
                return _rtf;
            }
        }

        public static string ImageToRtf(Image image)
        {
            using (Bitmap bmp = new Bitmap(image))
            {
                //Graphics g = Graphics.FromImage(bmp);
                //g.Clear(Color.White);
                //g.SmoothingMode = SmoothingMode.AntiAlias;
                //g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                //g.CompositingQuality = CompositingQuality.HighQuality;
                //g.DrawImage(img, new Rectangle(0, 0, width, height), new Rectangle(0, 0, img.Width, img.Height), GraphicsUnit.Pixel);
                //g.Dispose();

                //MemoryStream ms = new MemoryStream();
                //bmp.Save(ms, ImageFormat.Bmp);
                //Image _a = Image.FromStream(ms);
                ////_a.Save("D:\\bbTest1.png");
                //byte[] buffer = new byte[ms.Length];
                //ms.Seek(0, SeekOrigin.Begin);
                //ms.Read(buffer, 0, (int)ms.Length);
                //ms.Close();

                //string rtf = "";
                ////十进制转十六进制
                //foreach (byte item in buffer)
                //{
                //    string _TempText = item.ToString("X");
                //    rtf += _TempText.Length == 1 ? "0" + _TempText : _TempText;
                //    if (rtf.Length % 78 == 0)
                //        rtf += "\r\n";
                //}
                ////添加rtf的前缀和后缀
                //string _rtf = string.Format("{{\\pict\\wmetafile8\\picw661\\pich661\\picwgoal375\\pichgoal375 \r\n{0}\r\n}}", 
                //    rtf, image.Width * 15, image.Height * 15, image.Width * 26, image.Height * 26);
                //string savePath = RtfToImageSave(_rtf);

                using (RichTextBox richTextBox = new RichTextBox())
                {
                    Clipboard.Clear();
                    Clipboard.SetImage(image);
                    richTextBox.Paste();
                    string _rtf = richTextBox.Rtf;
                    _rtf = subRtf(_rtf);
                    return _rtf;
                }
            }
        }

        #region 绘制椭圆图片
        /// <summary>
        /// 绘制椭圆图片
        /// </summary>
        /// <param name="width"></param>
        /// <param name="height"></param>
        /// <returns></returns>
        public static Bitmap DrawRoundPic(int width, int height, Color bg_color)
        {
            Bitmap bm = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(bm);

            //实线刷
            SolidBrush mysbrush = new SolidBrush(Color.DarkOrchid);
            mysbrush.Color = Color.FromArgb(250, bg_color);

            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.FillEllipse(mysbrush, 0, 0, width - 1, height - 1);
            g.Dispose();
            return bm;
        }
        #endregion

        #region 在控件上绘制圆点和文字
        public static Bitmap DrawPointToCrl(Image image, string str_num, Point point, int width = 20, int height = 20, string p_color = "#FFFF0000")
        {
            //Console.WriteLine(" DrawPointToCrl : "+str_num+"   "+UIUtils.CurrentIntTime());
            #region 绘制圆点
            //Bitmap bmp_point = new Bitmap(width, height);
            //Graphics g = Graphics.FromImage(bmp_point);
            //Color bg_color = ColorTranslator.FromHtml(p_color);

            ////实线刷
            //SolidBrush mysbrush = new SolidBrush(Color.DarkOrchid);
            //mysbrush.Color = Color.FromArgb(250, bg_color);

            //g.SmoothingMode = SmoothingMode.AntiAlias;
            //g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            //g.CompositingQuality = CompositingQuality.HighQuality;
            //g.FillEllipse(mysbrush, 0, 0, width - 1, height - 1);
            //g.Dispose();
            Image bmp_point = Image.FromFile("Res\\red_point.jpg");
            #endregion

            //写上数字
            DrawNumToPoint(bmp_point, str_num);

            //合并图片
            Bitmap new_bmp = CombineRedPointToImg(bmp_point, image, point);
            return new_bmp;
        }

        /// <summary>
        /// 在头像上绘制红点
        /// </summary>
        /// <param name="foreImage">前景图</param>
        /// <param name="backImage">背景图</param>
        /// <returns></returns>
        public static Bitmap CombineRedPointToImg(Image foreImage, Image backImage, Point point)
        {
            Bitmap bitmap = new Bitmap(60, 45);
            Graphics g = Graphics.FromImage(bitmap);
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.DrawImage(backImage, new Rectangle(14, 6, backImage.Width, backImage.Height), 0, 0, backImage.Width, backImage.Height, GraphicsUnit.Pixel);
            g.DrawImage(foreImage, new Rectangle(point.X, point.Y, foreImage.Width, foreImage.Height), 0, 0, foreImage.Width, foreImage.Height, GraphicsUnit.Pixel);
            g.Dispose();

            return bitmap;
        }

        public static void DrawNumToPoint(Image bmp_point, string number)
        {
            using (Graphics g = Graphics.FromImage(bmp_point))
            {
                //实线画刷
                SolidBrush mysbrush1 = new SolidBrush(Color.DarkOrchid);
                mysbrush1.Color = Color.FromArgb(250, Color.White);
                //字体居中
                string str_num = number.Trim();
                PointF pointF;
                //长度为0时只显示红点不显示数字
                if (str_num.Length != 0)
                {
                    if (str_num.Length == 1)
                    {
                        pointF = new PointF(4, 5.2f);
                    }
                    else if (str_num.Length == 2)
                    {
                        pointF = new PointF(1, 5.2f);
                    }
                    else
                    {
                        pointF = new PointF(0, 5.2f);
                    }
                    //写入未读数量
                    g.DrawString(number.Trim(), new Font("宋体", 8F, FontStyle.Bold, GraphicsUnit.Point, ((byte)(134))), mysbrush1, pointF);
                    mysbrush1.Dispose();
                }
            }
        }
        #endregion

        #region 清空控件的所有子控件
        /// <summary>
        /// 清除所有控件和布局
        /// </summary>
        public static void ClearTabel(Control crl, bool isDispon = true)
        {
            //while (crl.Controls.Count > 0)
            //{
            foreach (Control item in crl.Controls)
            {
                //crl.Controls.Remove(item);
                if (isDispon)
                    item.Dispose();
            }
            //if (crl.Controls.Count == 0)
            //    break;
            //}

            crl.Controls.Clear();
            Helpers.ClearMemory();
        }
        #endregion

        #region 判断是否为消息气泡类型消息
        public static bool JudgeIsBubleMsg(kWCMessageType type)
        {
            switch (type)
            {
                case kWCMessageType.History:
                    return true;
                case kWCMessageType.Replay:
                    return true;
                default:
                    return type < kWCMessageType.Remind;
            }
        }
        #endregion

        public static EQPosition GetRichTextPosition(RichTextBox richTextBox)
        {
            EQPosition eQPosition = new EQPosition();
            eQPosition.Row = richTextBox.GetLineFromCharIndex(richTextBox.SelectionStart);
            eQPosition.Column = richTextBox.SelectionStart - richTextBox.GetFirstCharIndexFromLine(eQPosition.Row);
            return eQPosition;
        }

        public static void GroupAtModifyColor(RichTextBox richTextBox)
        {
            //用正则表达式，获取@的key
            MatchCollection matchs = Regex.Matches(richTextBox.Text, @"@[^\s]+\s", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            foreach (Match match in matchs)
            {
                //修改字符串颜色
                richTextBox.Select(match.Index, match.Value.Length - 1);
                richTextBox.SelectionColor = Color.FromArgb(22, 138, 205);
            }
            //光标的位置
            richTextBox.SelectionLength = 0;
        }

        /// <summary>
        /// 获取缩小后的图片
        /// </summary>
        /// <param name="bm">要缩小的图片</param>
        /// <param name="times">要缩小的倍数</param>
        /// <returns></returns>
        public static Bitmap GetSmall(Bitmap bm, double times)
        {
            int nowWidth = (int)(bm.Width / times);
            int nowHeight = (int)(bm.Height / times);
            Bitmap newbm = new Bitmap(nowWidth, nowHeight);//新建一个放大后大小的图片

            if (times >= 1 && times <= 1.1)
            {
                newbm = bm;
            }
            else
            {
                Graphics g = Graphics.FromImage(newbm);
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.CompositingQuality = CompositingQuality.HighQuality;
                g.DrawImage(bm, new Rectangle(0, 0, nowWidth, nowHeight), new Rectangle(0, 0, bm.Width, bm.Height), GraphicsUnit.Pixel);
                g.Dispose();
            }
            return newbm;
        }

        /// <summary>
        /// 获取缩小后的图片
        /// </summary>
        /// <param name="bm">要缩小的图片</param>
        /// <param name="times">要缩小的倍数</param>
        /// <returns></returns>
        public static Bitmap GetSmall(Bitmap bm, int new_width, int new_height)
        {
            Bitmap newbm = new Bitmap(new_width, new_height);//新建一个放大后大小的图片

            if (bm.Width == new_width && bm.Height == new_height)
            {
                newbm = bm;
            }
            else
            {
                Graphics g = Graphics.FromImage(newbm);
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.CompositingQuality = CompositingQuality.HighQuality;
                g.DrawImage(bm, new Rectangle(0, 0, new_width, new_height), new Rectangle(0, 0, bm.Width, bm.Height), GraphicsUnit.Pixel);
                g.Dispose();
            }
            return newbm;
        }

        #region 移除控件某个事件
        /// <summary>
        /// 移除控件某个事件
        /// </summary>
        /// <param name="control">控件</param>
        /// <param name="eventName">需要移除的控件名称eg:EventClick</param>
        public static void RemoveControlEvent(this Control control, string eventName)
        {
            FieldInfo _fl = typeof(Control).GetField(eventName, BindingFlags.Static | BindingFlags.NonPublic);
            if (_fl != null)
            {
                object _obj = _fl.GetValue(control);
                PropertyInfo _pi = control.GetType().GetProperty("Events", BindingFlags.NonPublic | BindingFlags.Instance);
                EventHandlerList _eventlist = (EventHandlerList)_pi.GetValue(control, null);
                if (_obj != null && _eventlist != null)
                    _eventlist.RemoveHandler(_obj, _eventlist[_obj]);
            }
        }
        #endregion

        #region 根据msg类型转化为简短文本
        public static string ChangeContentByType(MessageObject msg)
        {
            switch (msg.type)
            {
                case kWCMessageType.Text:
                    break;
                case kWCMessageType.CUSTOM_EMOT:
                case kWCMessageType.EMOT_PACKAGE:
                case kWCMessageType.Image:
                    return "[图片]";
                case kWCMessageType.Gif:
                    return "[动画表情]";
                case kWCMessageType.Voice:
                    return "[语音]";
                case kWCMessageType.Video:
                    return "[视频]";
                case kWCMessageType.Location:
                    return "[位置]";
                case kWCMessageType.Card:
                    return "[名片]";
                case kWCMessageType.File:
                    return "[文件]";
                case kWCMessageType.History:
                    return "[历史消息]";
                default:
                    break;
            }
            return msg.content;
        }
        #endregion

        #region GetFilePath
        public static string GetFilePathByType(MessageObject msg)
        {
            string filePath = "";
            string fileName = "";
            switch (msg.type)
            {
                case kWCMessageType.Image:
                    if (string.IsNullOrEmpty(msg.content) && !string.IsNullOrEmpty(msg.fileName))
                        fileName = FileUtils.GetFileName(msg.fileName);
                    else if (!string.IsNullOrEmpty(msg.content))
                        fileName = FileUtils.GetFileName(msg.content);
                    filePath = Applicate.LocalConfigData.ImageFolderPath + fileName;
                    break;
                case kWCMessageType.Video:
                    if (string.IsNullOrEmpty(msg.content) && !string.IsNullOrEmpty(msg.fileName))
                        fileName = FileUtils.GetFileName(msg.fileName);
                    else if (!string.IsNullOrEmpty(msg.content))
                        fileName = FileUtils.GetFileName(msg.content);
                    filePath = Applicate.LocalConfigData.VideoFolderPath + fileName;
                    break;
                case kWCMessageType.File:
                    fileName = FileUtils.GetFileName(msg.fileName);
                    filePath = Applicate.LocalConfigData.FileFolderPath + fileName;
                    break;
            }
            return filePath;
        }
        #endregion

        #region 非启用状态不改变背景色
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int wndproc);
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        public const int GWL_STYLE = -16;
        public const int WS_DISABLED = 0x8000000;

        public static void SetControlEnabled(Control c, bool enabled)
        {
            if (enabled)
            { SetWindowLong(c.Handle, GWL_STYLE, (~WS_DISABLED) & GetWindowLong(c.Handle, GWL_STYLE)); }
            else
            { SetWindowLong(c.Handle, GWL_STYLE, WS_DISABLED | GetWindowLong(c.Handle, GWL_STYLE)); }
        }
        #endregion

        #region 计算文本消息的高度
        [DllImport("user32.dll", EntryPoint = "SendMessageA")]
        private static extern int SendMessage(IntPtr hwnd, int wMsg, IntPtr wParam, string lParam);
        public static void CalculateWidthAndHeight_Text(MessageObject msg, bool isSave = true, int maxWidth = 260)
        {
            using (RichTextBoxEx richTextBox = new RichTextBoxEx())
            {
                //正常消息
                richTextBox.Size = new Size(maxWidth, 50);
                richTextBox.Text = Applicate.getFilterContent(msg.content);
                richTextBox.Font = new Font(Applicate.SetFont, 10F);
                richTextBox.MinimumSize = new Size(0, 25);  //最小高度25
                richTextBox.ReadOnly = true;
                richTextBox.ScrollBars = RichTextBoxScrollBars.None;
                richTextBox.WordWrap = true;
                float max_width = 0;
                //通过自适应高度计算
                richTextBox.ContentsResized += new ContentsResizedEventHandler((sender, e) =>
                {
                    if (string.IsNullOrEmpty(richTextBox.Text))
                        return;

                    string str_rtf = richTextBox.Rtf;
                    if (msg.BubbleWidth < maxWidth)
                    {
                        //分割每一行
                        string[] str_row = richTextBox.Text.Split(new string[] { "\n" }, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string item in str_row)
                        {
                            int item_width = GetWidthByStr(item, richTextBox, ref str_rtf);
                            if (item_width > max_width)
                                max_width = item_width;
                            //到达了最大宽度
                            if (max_width >= maxWidth)
                            {
                                max_width = maxWidth;
                                break;
                            }
                        }
                        if (max_width < 1)
                            return;
                        //如果文字宽度不足260
                        if (max_width < maxWidth)
                            msg.BubbleWidth = (int)max_width + 5;
                        else
                            msg.BubbleWidth = maxWidth + 5;
                    }
                    //if (msg.BubbleHeight > e.NewRectangle.Height)
                    msg.BubbleHeight = e.NewRectangle.Height;
                    richTextBox.Size = new Size(msg.BubbleWidth + 2, msg.BubbleHeight);
                    richTextBox.Rtf = str_rtf;

                    //记录保存气泡的长宽
                    if (isSave)
                        msg.UpdateData();
                });
                int EM_GETLINECOUNT = 0x00BA;//获取总行数的消息号 
                SendMessage(richTextBox.Handle, EM_GETLINECOUNT, IntPtr.Zero, "");
                //得到RichTextBox高度
                //richTextBox.Resize += (sender, e) =>
                //{
                //    int sf = richTextBox.Font.Height * (lc + 1) + richTextBox.Location.Y;
                //    richTextBox.Height = sf;
                //};
                //richTextBox.Width = 50;
            }
        }

        private static int GetWidthByStr(string item, RichTextBoxEx richTextBox, ref string str_rtf)
        {
            if (string.IsNullOrEmpty(item))
                return 0;

            //空格的数量
            int whiteSpaceCount = item.Split(' ').Length - 1;
            item = item.Replace(" ", "");
            //计算改行emoji所占的宽度
            int item_emojiCount = 0;
            //匹配符合规则的表情code
            MatchCollection matchs = Regex.Matches(item, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            item_emojiCount = matchs.Count;
            foreach (Match match in matchs)
            {
                string item_value = match.Groups[0].Value;
                //表情code去除[]
                string image_name = item_value.Replace("[", "").Replace("]", "");
                //检查是否为已存在的emoji表情
                //string path = string.Format(@"Res\Emoji\{0}.png", image_name);
                //if (!File.Exists(path))
                if (!EmojiCodeDictionary.GetEmojiDataIsMine().ContainsKey(image_name))
                    item_emojiCount--;
                else
                {
                    item = item.Replace(item_value, "");
                    str_rtf = str_rtf.Replace(item_value, EmojiCodeDictionary.GetEmojiRtfByCode(image_name));
                    //richTextBox.Rtf = richTextBox.Rtf.Replace(item_value, EmojiCodeDictionary.GetEmojiRtfByCode(image_name));
                }
            }

            //获取行文字所占的大小
            SizeF sizeF = GetStringTheSize(item, new Font(Applicate.SetFont, 10F));

            //特殊符号表情
            matchs = Regex.Matches(richTextBox.Rtf, @"\\u-[0-9a-zA-Z]+\?", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            int emojiSymbol = matchs.Count / 2;

            //总宽度（emoji表情符号计算长度欠缺3个像素）
            int item_width = item_emojiCount * 26 + (int)sizeF.Width + emojiSymbol * 4 + whiteSpaceCount * 4;
            return item_width;
        }

        public static Dictionary<string, Size> CalculateWidthAndHeight_Reply(MessageObject msg, bool isSave = true, int maxWidth = 260)
        {
            //需要返回的控件的大小
            Dictionary<string, Size> dic = new Dictionary<string, Size>();
            //计算回复的消息的原内容
            int re_width = 0, re_height = 0;
            using (RichTextBoxEx replyTextBox = new RichTextBoxEx())
            {
                var replyMsg = JsonConvert.DeserializeObject<MessageObject>(msg.objectId);
                //显示的对方发送的内容
                string from_content = ChangeContentByType(replyMsg);
                //转emoji
                replyTextBox.Text = replyMsg.fromUserName + ": " + from_content;

                replyTextBox.Size = new Size(maxWidth, 50);
                replyTextBox.WordWrap = true;
                replyTextBox.ReadOnly = true;
                replyTextBox.BorderStyle = BorderStyle.None;
                replyTextBox.ScrollBars = RichTextBoxScrollBars.None;
                replyTextBox.BringToFront();
                replyTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left;
                replyTextBox.Location = new Point(5, 0);
                replyTextBox.Font = new Font(Applicate.SetFont, 10F);
                replyTextBox.ForeColor = Color.Gray;
                replyTextBox.ScrollBars = RichTextBoxScrollBars.None; float max_width = 0;
                //通过自适应高度计算
                replyTextBox.ContentsResized += new ContentsResizedEventHandler((sender, e) =>
                {
                    string str_rtf = replyTextBox.Rtf;
                    if (re_width < maxWidth)
                    {
                        //分割每一行
                        string[] str_row = replyTextBox.Text.Split(new string[] { "\n" }, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string item in str_row)
                        {
                            int item_width = GetWidthByStr(item, replyTextBox, ref str_rtf);
                            if (item_width > max_width)
                                max_width = item_width;
                            //到达了最大宽度
                            if (max_width >= maxWidth)
                            {
                                max_width = maxWidth;
                                break;
                            }
                        }
                        if (max_width < 1)
                            return;
                        //如果文字宽度不足260
                        //if (max_width < 260)
                        re_width = (int)max_width + 5;
                        //else
                        //    msg.BubbleWidth = e.NewRectangle.Width + 5;
                    }
                    re_height = e.NewRectangle.Height;
                    replyTextBox.Size = new Size(re_width + 2, re_height);
                    replyTextBox.Rtf = str_rtf;
                });
                int EM_GETLINECOUNT = 0x00BA;//获取总行数的消息号 
                SendMessage(replyTextBox.Handle, EM_GETLINECOUNT, IntPtr.Zero, "");
            }
            dic.Add("replyTextBox", new Size(re_width, re_height));

            //计算发送者的消息内容
            int ri_width = 0, ri_height = 0;
            using (RichTextBoxEx richTextBox = new RichTextBoxEx())
            {
                //正常消息
                richTextBox.Size = new Size(maxWidth, 50);
                richTextBox.Text = msg.content;
                richTextBox.Font = new Font(Applicate.SetFont, 10F);
                richTextBox.MinimumSize = new Size(0, 25);  //最小高度25
                richTextBox.ReadOnly = true;
                richTextBox.ScrollBars = RichTextBoxScrollBars.None;
                richTextBox.WordWrap = true;
                float max_width = 0;
                //通过自适应高度计算
                richTextBox.ContentsResized += new ContentsResizedEventHandler((sender, e) =>
                {
                    string str_rtf = richTextBox.Rtf;
                    if (ri_width < maxWidth)
                    {
                        //分割每一行
                        string[] str_row = richTextBox.Text.Split(new string[] { "\n" }, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string item in str_row)
                        {
                            int item_width = GetWidthByStr(item, richTextBox, ref str_rtf);
                            if (item_width > max_width)
                                max_width = item_width;
                            //到达了最大宽度
                            if (max_width >= maxWidth)
                            {
                                max_width = maxWidth;
                                break;
                            }
                        }
                        if (max_width < 1)
                            return;
                        //如果文字宽度不足260
                        //if (max_width < 260)
                        ri_width = (int)max_width + 5;
                        //else
                        //    msg.BubbleWidth = e.NewRectangle.Width + 5;
                    }
                    ri_height = e.NewRectangle.Height;
                    richTextBox.Size = new Size(ri_width, ri_height);
                    richTextBox.Rtf = str_rtf;
                });
                int EM_GETLINECOUNT = 0x00BA;//获取总行数的消息号 
                SendMessage(richTextBox.Handle, EM_GETLINECOUNT, IntPtr.Zero, "");
            }
            dic.Add("richTextBox", new Size(ri_width, ri_height));

            //计算总高和宽
            msg.BubbleWidth = (ri_width > re_width ? ri_width : re_width) + 5;
            msg.BubbleHeight = re_height + 11 + ri_height + 5;
            msg.UpdateData();

            return dic;
        }
        #endregion

        #region 计算图片消息的高度
        public static Size CalculateWidthAndHeight_Image(MessageObject msg)
        {
            int width = 0, height = 0;
            if (msg.location_x > 0 && msg.location_y > 0)
            {
                width = (int)msg.location_x;
                height = (int)msg.location_y;
                ModifyWidthAndHeight(ref width, ref height, 250, 250);
            }
            else
            {
                width = 128;
                height = 128;
            }
            //更新数据库
            msg.BubbleHeight = height;
            msg.BubbleWidth = width;
            msg.UpdateData();
            return new Size(width, height);
        }
        #endregion

        #region 计算remind消息的高度
        public static Size CalculateWidthAndHeight_Remind(MessageObject msg)
        {
            int row_count = 0;
            int width = 0, height = 0;
            string content = string.IsNullOrEmpty(msg.content) ? " " : msg.content;
            //分割每一行
            string[] str_row = content.Split(new string[] { "\n" }, StringSplitOptions.None);
            foreach (string item in str_row)
            {
                //空格的数量
                int whiteSpaceCount = item.Split(' ').Length - 1;
                string str = item.Replace(" ", "");
                SizeF sizeF = GetStringTheSize(str, new Font(Applicate.SetFont, 9F, FontStyle.Bold, GraphicsUnit.Point, 134));
                int now_width = (int)sizeF.Width + whiteSpaceCount * 4;
                if (now_width > 280)
                {
                    int row_num = (int)Math.Ceiling((decimal)now_width / 280);
                    now_width = 280;
                    //height = 20 * row_count;
                    row_count += row_num;
                }
                else
                    row_count++;
                //比较出最大的宽并保存
                if (now_width > width)
                    width = now_width;
            }
            height = row_count > 0 ? row_count * 17 : 17;

            height += 4;    //提高上下边距

            //保存宽高
            msg.BubbleWidth = width + 5;
            msg.BubbleHeight = height;
            msg.UpdateData();

            //msg.content = string.IsNullOrEmpty(msg.content) ? " " : msg.content;
            //CalculateWidthAndHeight_Text(msg, true, 280);

            return new Size(msg.BubbleWidth, msg.BubbleHeight);
        }

        #endregion/// <summary>

        /// 判断是否禁言
        /// </summary>
        /// <returns>返回true则为禁言状态</returns>
        public static bool JudgeIsBannedTalk(Friend friend)
        {
            if (friend.IsGroup != 1)
                return false;
            if (string.IsNullOrEmpty(friend.UserId))
                return true;
            int role = new RoomMember() { roomId = friend.RoomId, userId = friend.UserId }.GetRoleByUserId();
            //是否全体禁言
            string all = LocalDataUtils.GetStringData(friend.UserId + "BANNED_TALK_ALL" + Applicate.MyAccount.userId, "0");
            //管理员和群主除外
            if (!"0".Equals(all) && role != 1 && role != 2)
                return true;

            //是否单个禁言
            string single = LocalDataUtils.GetStringData(friend.UserId + "BANNED_TALK" + Applicate.MyAccount.userId, "0");
            //群主除外
            if (!"0".Equals(single) && role != 1)
            {
                double time = double.Parse(single);
                if (time > TimeUtils.CurrentTimeDouble())
                    return true;
            }

            return false;
        }


        /// <summary>
        /// 截取rtf字符串中的单个图片
        /// </summary>
        /// <param name="rtf"></param>
        /// <returns></returns>
        public static string subRtf(string rtf)
        {
            //rtf1–> RTF版本
            //ansi–> 字符集
            //ansicpg936–> 简体中文
            //deff0–> 默认字体0
            //deflang1033–> 美国英语
            //deflangfe2052–> 中国汉语
            //fonttb–> 字体列表
            //f0->字体0
            //fcharset134->GB2312国标码
            //‘cb\’ce\’cc\’e5–> 宋体
            int startIndex = rtf.IndexOf("{\\pict");
            if (startIndex < 0)
                return rtf;
            rtf = rtf.Substring(startIndex);
            int endIndex = rtf.LastIndexOf("\\par\r\n}\r\n");
            endIndex = endIndex < 0 ? rtf.Length : endIndex;
            rtf = rtf.Substring(0, endIndex);
            return rtf;
        }
        public static string subFileRtf(string rtf)
        {
            //rtf1–> RTF版本
            //ansi–> 字符集
            //ansicpg936–> 简体中文
            //deff0–> 默认字体0
            //deflang1033–> 美国英语
            //deflangfe2052–> 中国汉语
            //fonttb–> 字体列表
            //f0->字体0
            //fcharset134->GB2312国标码
            //‘cb\’ce\’cc\’e5–> 宋体
            int startIndex = rtf.IndexOf("{\\object");
            if (startIndex < 0)
                return rtf;
            rtf = rtf.Substring(startIndex);
            int endIndex = rtf.LastIndexOf("\\par\r\n}\r\n");
            rtf = rtf.Substring(0, endIndex);
            return rtf;
        }

        public static int GetCeiling(this double number)
        {
            return (int)Math.Ceiling(number);
        }

        #region 保存高质量图片
        //获得编码器的函数
        private static ImageCodecInfo GetEncoderInfo(String mimeType)
        {
            int j;
            ImageCodecInfo[] encoders;
            encoders = ImageCodecInfo.GetImageEncoders();
            //Console.WriteLine("GetEncoderInfo: " + encoders.Length);
            for (j = 0; j < encoders.Length; ++j)
            {
                //Console.WriteLine("GetEncoderInfo: " + encoders[j] + "\r\n" + mimeType);
                if (encoders[j].MimeType == mimeType)
                    return encoders[j];
            }
            return null;
        }

        public static void MySave(this Image image, string path, ImageFormat imageFormat)
        {
            //获取编码器
            ImageCodecInfo myImageCodecInfo;

            string mimeType = "image/";
            if (ImageFormat.Png == imageFormat)
                mimeType += "png";
            else if (ImageFormat.Jpeg == imageFormat)
                mimeType += "jpeg";
            else if (ImageFormat.Gif == imageFormat)
                mimeType += "gif";
            else if (ImageFormat.Bmp == imageFormat)
                mimeType += "bmp";
            else if (ImageFormat.Tiff == imageFormat)
                mimeType += "tiff";

            //获得JPEG格式的编码器
            myImageCodecInfo = GetEncoderInfo(mimeType);
            //设置图像质量
            Encoder myEncoder;
            EncoderParameter myEncoderParameter;
            EncoderParameters myEncoderParameters;
            // for the Quality parameter category.
            myEncoder = Encoder.Quality;
            // EncoderParameter object in the array.
            myEncoderParameters = new EncoderParameters(1);
            //设置质量 数字越大质量越好，但是到了一定程度质量就不会增加了，MSDN上没有给范围，只说是32为非负整数
            myEncoderParameter = new EncoderParameter(myEncoder, 100L);
            myEncoderParameters.Param[0] = myEncoderParameter;
            //保存图像
            image.Save(path, myImageCodecInfo, myEncoderParameters);
        }
        #endregion

        public static Bitmap FileToBitmap(string fileName)
        {
            // 打开文件    
            FileStream fileStream = new FileStream(fileName, FileMode.Open, FileAccess.Read, FileShare.Read);
            // 读取文件的 byte[]    
            byte[] bytes = new byte[fileStream.Length];
            fileStream.Read(bytes, 0, bytes.Length);
            fileStream.Close();
            // 把 byte[] 转换成 Stream    
            Stream stream = new MemoryStream(bytes);
            stream.Read(bytes, 0, bytes.Length);
            // 设置当前流的位置为流的开始    
            stream.Seek(0, SeekOrigin.Begin);
            MemoryStream mstream = null;
            try
            {
                mstream = new MemoryStream(bytes);
                return new Bitmap(stream);
            }
            catch (ArgumentNullException ex)
            {
                LogHelper.log.Error("----FileToBitmap : " + ex.Message, ex);
                return null;
            }
            catch (ArgumentException ex)
            {
                LogHelper.log.Error("----FileToBitmap : " + ex.Message, ex);
                return null;
            }
            finally
            {
                stream.Close();
            }
        } 
    }
}
