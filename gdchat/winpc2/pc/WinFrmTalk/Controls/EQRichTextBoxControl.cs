using RichTextBoxLinks;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQRichTextBoxControl : EQBaseControl
    {
        //private int emoji_count = 0;

        public EQRichTextBoxControl(string strJson) : base(strJson)
        {
            isShowRedPoint = false;
            isRemindMessage = false;
        }

        public EQRichTextBoxControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = false;
            isRemindMessage = false;
        }

        //聊天气泡底色
        //private Color bg_color = JXBaseControl.bg_color;

        RichTextBoxEx richTextBox = new RichTextBoxEx() { Size = new Size(260, 40) };
        public override Control ContentControl()
        {
            //阅后即焚
            if (messageObject.isReadDel == 1 && !messageObject.FromId.Equals(Applicate.MyAccount.userId))
            {
                messageObject.BubbleWidth = 59;
                messageObject.BubbleHeight = 25;
                messageObject.UpdateData();
            }
            else
            {
                //已经计算过气泡宽高
                if (messageObject.BubbleWidth > 0 /*&& messageObject.isReadDel != 1*/)
                {
                    BubbleWidth = messageObject.BubbleWidth;
                    BubbleHeight = messageObject.BubbleHeight;
                    richTextBox.Size = new Size(BubbleWidth, BubbleHeight);
                }
                //自适应大小
                else
                {
                    EQControlManager.CalculateWidthAndHeight_Text(messageObject);
                }
            }

            #region 阅后即焚
            if (messageObject.isReadDel == 1 && messageObject.fromUserId != Applicate.MyAccount.userId)
            {
                richTextBox.ForeColor = Color.Red;
                richTextBox.Text = "点击查看";
                richTextBox.MouseDown += RichTextBox_MouseDown;
            }
            #endregion
            else
            {
                richTextBox.Text = Applicate.getFilterContent(messageObject.content) + " ";
            }

            richTextBox.KeyDown += RichTextBox_KeyDown;
            //转emoji表情并触发计算高度
            Calc_PanelWidth(richTextBox);
            //设置属性
            richTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            richTextBox.BackColor = bg_color;
            richTextBox.BorderStyle = BorderStyle.None;
            richTextBox.BringToFront();
            richTextBox.DetectUrls = true;
            //EQControlManager.SetControlEnabled(richTextBox, false);
            //richTextBox.Enabled = false;
            richTextBox.Font = new Font(Applicate.SetFont, 10F);
            richTextBox.Location = new Point(10, 10);
            //richTextBox.MaximumSize = new Size(260, 0);
            richTextBox.MinimumSize = new Size(0, 25);  //最小高度25
            richTextBox.ReadOnly = true;
            richTextBox.SetReadMode();  //不显示光标
            richTextBox.ScrollBars = RichTextBoxScrollBars.None;
            richTextBox.Tag = Applicate.getFilterContent(messageObject.content) + " ";
            richTextBox.WordWrap = true;
            //richTextBox.SetLineSpace(richTextBox, 50);   //设置行间距
            //richTextBox.ShortcutsEnabled = false;   //屏蔽快捷键

            //点击超链接
            richTextBox.LinkClicked += (sender, e) =>
            {
                System.Diagnostics.Process.Start(e.LinkText);
            };

            //修改@颜色
            EQControlManager.GroupAtModifyColor(richTextBox);

            return richTextBox;
        }

        #region 在文本框进行键盘的快捷键操作
        //private const int WM_COPY = 0x0301;
        //protected override void WndProc(ref Message m)
        //{
        //    //非阅后即焚消息才有复制粘贴
        //    if (m.Msg == WM_COPY && messageObject.isReadDel == 1)
        //        return;
        //    Console.WriteLine("msg == " + m.Msg);
        //    base.WndProc(ref m);
        //}
        private void RichTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (sender is RichTextBoxEx richTextBox)
            {
                //Ctrl + C
                if (e.Control && e.KeyCode == Keys.C)
                {
                    string tag = richTextBox.Tag.ToString();
                    if (richTextBox.Parent.Parent is EQBaseControl talk_panel) {
                        Thread myThread = new Thread(() =>
                        {
                            using (RichTextBoxEx rtbTest = new RichTextBoxEx())
                            {
                                //黏贴板的rtf
                                string rtf = Convert.ToString(Clipboard.GetDataObject().GetData(DataFormats.Rtf));
                                if (string.IsNullOrEmpty(rtf))
                                    return;
                                //匹配符合规则的表情code
                                //MatchCollection matchs = Regex.Matches(tag, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                                //MessageObject msg = MessageObjectDataDictionary.GetMsg(talk_panel.Name.Replace("talk_panel_", ""));
                                MessageObject msg = this.messageObject;
                                Dictionary<string, string> emojiCode_Rtf = new Dictionary<string, string>();
                                if (msg != null)
                                {
                                    bool isMinMsg = msg.fromUserId == Applicate.MyAccount.userId;
                                    //去除奇怪的字符串
                                    rtf = rtf.Replace("{\\*\\picprop}", "");
                                    //foreach (Match match in matchs)
                                    //    rtf = rtf.Replace(EmojiCodeDictionary.GetEmojiRtfByCode(match.Value, isMinMsg), match.Value);
                                    //rtbTest.Rtf = rtf;
                                    string[] rtfs = tag.Split(']');
                                    Parallel.For(0, rtfs.Length, (index, loopState) =>
                                    {
                                        if (string.IsNullOrEmpty(rtfs[index]) || rtfs[index].IndexOf("[") < 0)
                                            loopState.Break();
                                        //匹配符合规则的表情code
                                        MatchCollection matchs = Regex.Matches(rtfs[index] + "]", @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                                        if (matchs.Count > 0)
                                        {
                                            string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(matchs[0].Value, isMinMsg);
                                            if (rtf.IndexOf(emoji_rtf) > -1 && !emojiCode_Rtf.ContainsKey(matchs[0].Value))
                                            {
                                                emojiCode_Rtf.Add(matchs[0].Value, emoji_rtf);
                                            }
                                        }
                                    });
                                    foreach(string key in emojiCode_Rtf.Keys)
                                    {
                                        rtf = rtf.Replace(emojiCode_Rtf[key], key);
                                    }
                                    rtbTest.Rtf = rtf;

                                    int startIndex = richTextBox.SelectionStart;
                                    int selectionLength = richTextBox.SelectionLength;
                                }
                                try
                                {
                                    Clipboard.Clear();
                                    Clipboard.SetDataObject(rtbTest.Text, true, 3, 200);
                                }
                                catch (Exception)
                                {
                                    //ExternalException 剪切版正在被其他程序使用
                                    throw;
                                }
                            }
                        });
                        //注意，一般启动一个线程的时候没有这句话，但是要操作剪切板的话这句话是必需要加上的，因为剪切板只能在单线
                        //程单元中访问，这里的STA就是指单线程单元
                        myThread.SetApartmentState(ApartmentState.STA);
                        myThread.Start();
                    }
                }
            }
        }
        #endregion

        #region 阅后即焚的点击
        private void RichTextBox_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Left)
                return;


            if (xListView != null && xListView.Parent != null && xListView.Parent is ShowMsgPanel showMsgPanel)
            {
                //非阅后即焚不会有点击事件
                if (messageObject == null || messageObject.isReadDel == 0)
                    return;

                //重新计算高度和宽度
                int oldWidth = richTextBox.Width;
                int oldHeight = richTextBox.Height;
                //richTextBox.Size = new Size(260, 40);
                EQControlManager.CalculateWidthAndHeight_Text(messageObject);

                //差值
                MessageObject msg = messageObject.GetMessageObject();
                int diff_width = msg.BubbleWidth - oldWidth;
                int diff_height = msg.BubbleHeight - oldHeight;

                int index = showMsgPanel.msgTabAdapter.msgList.FindIndex(m => m.messageId == msg.messageId);
                Control crl = xListView.ModifyItem(index, diff_height);
                crl.Size = new Size(crl.Width + diff_width, crl.Height + diff_height);

                //重新赋值
                richTextBox.Text = richTextBox.Tag.ToString() + " ";
                Calc_PanelWidth(richTextBox);
                richTextBox.Font = new Font(Applicate.SetFont, 10F);
                richTextBox.ForeColor = Color.Black;
                richTextBox.Size = new Size(msg.BubbleWidth, msg.BubbleHeight);
                if (crl.Controls["talk_panel_" + msg.messageId] is EQRichTextBoxControl talk_panel)
                {
                    //调整UI
                    Size bg_size = new Size();
                    Image bg_bubble = MakeTalkBubble(msg.fromUserId == Applicate.MyAccount.userId, ref bg_size);
                    richTextBox.Parent.BackgroundImage = bg_bubble;     //richTextBox.Parent: imagePanel
                    richTextBox.Parent.Size = new Size(richTextBox.Parent.Width + diff_width, bg_size.Height + 5);
                    talk_panel.Size = new Size(talk_panel.Width + diff_width, richTextBox.Parent.Height + 5);

                    var result = talk_panel.Controls.Find("lab_readDeleted", true);
                    if (result.Length > 0 && result[0] is Label lab_readDeleted && lab_readDeleted.Image != null)
                    {
                        lab_readDeleted.Location = new Point(lab_readDeleted.Location.X + diff_width, lab_readDeleted.Location.Y);
                        //获取该消息的总秒数
                        int second = LocalDataUtils.GetIntData(Applicate.MyAccount.userId + "_ReadDelTime_" + msg.messageId);
                        if (second < 1)
                            second = (int)Math.Round((decimal)BubbleHeight / 20) * 10;
                        //开启计时
                        DrawisReadDel(lab_readDeleted, second);

                        //发送已读
                        ShiKuManager.SendReadMessage(msg.GetFriend(), msg);

                        richTextBox.MouseDown -= RichTextBox_MouseDown;
                    }
                }
            }

            //if (richTextBox.Parent is Panel image_panel &&
            //richTextBox.Parent.Parent is EQBaseControl talk_panel &&
            //richTextBox.Parent.Parent.Parent is TableLayoutPanelEx showInfo_panel)
            //{
            //    //获取msg
            //    string msgId = talk_panel.Name.Replace("talk_panel_", "");
            //    //MessageObject msg = MessageObjectDataDictionary.GetMsg(msgId);
            //    MessageObject msg = this.messageObject;
            //    //非阅后即焚不会有点击事件
            //    if (msg == null || msg.isReadDel == 0)
            //        return;

            //    //重新计算高度和宽度
            //    int oldWidth = richTextBox.Width;
            //    int oldHeight = richTextBox.Height;
            //    //richTextBox.Size = new Size(260, 40);
            //    EQControlManager.CalculateWidthAndHeight_Text(messageObject);

            //    //重新赋值
            //    richTextBox.Text = richTextBox.Tag.ToString() + " ";
            //    Calc_PanelWidth(richTextBox);
            //    richTextBox.Font = new Font(Applicate.SetFont, 10F);
            //    richTextBox.ForeColor = Color.Black;

            //    //调整UI
            //    Size bg_size = new Size();
            //    Image bg_bubble = MakeTalkBubble(msg.fromUserId == Applicate.MyAccount.userId, ref bg_size);
            //    image_panel.BackgroundImage = bg_bubble;
            //    image_panel.Size = new Size(image_panel.Width + (richTextBox.Width - oldWidth), bg_size.Height + 5);
            //    talk_panel.Size = new Size(talk_panel.Width + (richTextBox.Width - oldWidth), image_panel.Height + 5);
            //    showInfo_panel.Height += (richTextBox.Height - oldHeight);
            //    showInfo_panel.RowStyles[msg.rowIndex].Height += (richTextBox.Height - oldHeight);

            //    //阅后即焚控件
            //    var crl_msg = richTextBox.Parent.Parent.Controls["lab_readDeleted"];
            //    if (crl_msg != null && crl_msg is Label lab_readDeleted && lab_readDeleted.Image != null)
            //    {
            //        lab_readDeleted.Location = new Point(lab_readDeleted.Location.X + (richTextBox.Width - oldWidth), lab_readDeleted.Location.Y);
            //        //获取该消息的总秒数
            //        int second = LocalDataUtils.GetIntData(Applicate.MyAccount.userId + "_ReadDelTime_" + msg.messageId);
            //        if (second < 1)
            //            second = (int)Math.Round((decimal)BubbleHeight / 20) * 10;
            //        //开启计时
            //        DrawisReadDel(lab_readDeleted, second);
            //    }
                //发送已读
                //ShiKuManager.SendReadMessage(msg.GetFriend(), msg);

                //richTextBox.MouseDown -= RichTextBox_MouseDown;
            //}
        }
        #endregion

        /// <summary>
        /// 计算显示框高度和宽度，英文字体和中文以及标点、数字的宽度各不相同，需计算
        /// </summary>
        /// <param name="control">气泡内的控件</param>
        public override void Calc_PanelWidth(Control control)
        {
            if (!(control is RichTextBoxEx richContent))
                return;

            //临时建立一个容器装入内容
            //using (RichTextBoxEx canv_Rich = control as RichTextBoxEx)
            //{
            RichTextBoxEx canv_Rich = control as RichTextBoxEx;
            canv_Rich.Font = new Font(Applicate.SetFont, 10F);
            //先取全部Text的值
            canv_Rich.Text = richContent.Text;
            //把code转为emoji
            canv_Rich.Rtf = GetEmoji(canv_Rich.Text, bg_color);

            //
            richContent.Rtf = canv_Rich.Rtf;
            //}
            //richContent.Rtf = canv_Rich.Rtf.Replace("{\\fonttbl{\\f0\\fnil\\fcharset134 \\'cb\\'ce\\'cc\\'e5;}}",
            //    "{\\fonttbl{\\f0\\fnil Segoe UI Symbol;}{\\f1\\fnil\\fcharset134 \\'cb\\'ce\\'cc\\'e5;}}\r\n{\\colortbl ;\\red27\\green41\\blue62;}");       

            BubbleHeight = messageObject.BubbleHeight;
            BubbleWidth = messageObject.BubbleWidth;
            richTextBox.Size = new Size(BubbleWidth, BubbleHeight);
        }

        /// <summary>
        /// 关键词在字符串的出现次数
        /// </summary>
        /// <param name="value">需要检索的字符串</param>
        /// <param name="keyword">关键词</param>
        /// <returns></returns>
        private int IndexOfEx(string value, string keyword)
        {
            //如果是图片，要对长宽进行处理
            int count = 0;
            if (!string.IsNullOrEmpty(value) && !string.IsNullOrEmpty(keyword))
                count = (value.Length - value.Replace(keyword, "").Length) / keyword.Length;
            return count;
        }

        #region StringToEmoji
        /// <summary>
        /// 传递含有emoji code的文本，返回转化为图片后的rtf字符串
        /// </summary>
        /// <param name="ric_text">含有emoji code的文本</param>
        /// <param name="bg_cloor">填充绘画底色的背景色</param>
        /// <param name="code_count">合计有多少emoji_code转为png</param>
        /// <returns></returns>
        private string GetEmoji(string ric_text, Color bg_cloor)
        {
            RichTextBoxEx richTextBox = new RichTextBoxEx();
            richTextBox.Text = ric_text;
            //匹配符合规则的表情code
            //MatchCollection matchs = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            //emoji_count = matchs.Count;
            //string[] newStr = new string[matchs.Count];
            //不用做记录的变量
            //int index = 0;
            bool isParallel = false;
            //是否为自己发送的消息
            bool isMin = messageObject.fromUserId == Applicate.MyAccount.userId;
            string rtf = richTextBox.Rtf;
            ////Parallel.ForEach(matchs.OfType<Match>(), item => 
            //Parallel.For(0, matchs.Count, index =>
            //{
            //    string emoji_code = matchs[index].Value;
            //    //if (rtf.IndexOf(emoji_code) < 0)
            //    //{
            //    //    //ParallelLoopState.Break();
            //    //    return;
            //    //}
            //    //循环替换code为表情图片
            //    if (EmojiCodeDictionary.GetEmojiDataIsMine().ContainsKey(emoji_code.Replace("[", "").Replace("]", "")))
            //    {
            //        string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(emoji_code, isMin);
            //        rtf = rtf.Replace(emoji_code, emoji_rtf);
            //    }
            //    else
            //        emoji_count--;
            //});
            //richTextBox.Rtf = rtf;

            //循环替换code为表情图片
            //List<string> replacedEmoji = new List<string>();
            //foreach (Match item in matchs)
            //{
            //    if (replacedEmoji.Contains(item.Value))
            //        continue;

            //    //newStr[index] = item.Groups[0].Value;
            //    //index++;
            //    string emoji_code = item.Value;
            //    //已经被替换过了
            //    if (rtf.IndexOf(emoji_code) < 0)
            //        continue;
            //    //循环替换code为表情图片
            //    if (EmojiCodeDictionary.GetEmojiDataIsMine().ContainsKey(emoji_code.Replace("[", "").Replace("]", "")))
            //    {
            //        richTextBox.Rtf = richTextBox.Rtf.Replace(emoji_code, EmojiCodeDictionary.GetEmojiRtfByCode(emoji_code, isMin));
            //    }
            //    else
            //        emoji_count--;

            //    replacedEmoji.Add(item.Value);
            //}

            //for (int i = 0; i < newStr.Length; i++)
            //{
            //    bool isMin = messageObject.fromUserId == Applicate.MyAccount.userId;
            //    if (EmojiCodeDictionary.GetEmojiDataIsMine().ContainsKey(newStr[i].Replace("[", "").Replace("]", "")))
            //        richTextBox.Rtf = richTextBox.Rtf.Replace(newStr[i], EmojiCodeDictionary.GetEmojiRtfByCode(newStr[i], isMin));
            //}
           
            string[] rtfs = richTextBox.Rtf.Split(']');
            Parallel.For(0, rtfs.Length, (index, loopState) =>
            {
                if (string.IsNullOrEmpty(rtfs[index]) || rtfs[index].IndexOf("[") < 0)
                    loopState.Break();
                //匹配符合规则的表情code
                MatchCollection matchs = Regex.Matches(rtfs[index] + "]", @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                if (matchs.Count > 0)
                {
                    string emoji_rtf = EmojiCodeDictionary.GetEmojiRtfByCode(matchs[0].Value, isMin);
                    if (!string.IsNullOrEmpty(emoji_rtf))
                    {
                        isParallel = true;
                        rtfs[index] = (rtfs[index] + "]").Replace(matchs[0].Value, emoji_rtf);
                    }
                }
            });

            if(isParallel)
            {
                string new_rtf = string.Empty;
                for (int i = 0; i < rtfs.Length; i++)
                {
                    new_rtf += rtfs[i];
                }
                richTextBox.Rtf = new_rtf;
            }

            


            //把链接改为超链接
            MatchCollection matchs_link = Regex.Matches(richTextBox.Text, @"^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            foreach(Match match in matchs_link)
            {
                int str_index = richTextBox.Text.IndexOf(match.Value);  //查找匹配超链接格式的索引位置
                richTextBox.SelectionStart = str_index;     //设置复选文本框的光标位置
                richTextBox.SelectionLength = match.Value.Length;   //设置选中的字符数量
                richTextBox.SelectedText = "";      //去除文本中原本的超链接字符
                richTextBox.InsertLink(match.Value);    //插入超链接格式和文本
            }

            string result = richTextBox.Rtf;
            richTextBox.Dispose();
            return result;
        }
        #endregion
    }
}
