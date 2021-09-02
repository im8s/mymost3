using Newtonsoft.Json;
using RichTextBoxLinks;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
using System.Windows.Forms;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Dictionarys;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQReplyControl : EQBaseControl
    {
        private int emoji_count = 0;

        public EQReplyControl(string strJson) : base(strJson)
        {
            isShowRedPoint = false;
            isRemindMessage = false;
        }

        public EQReplyControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = false;
            isRemindMessage = false;
        }

        //聊天气泡底色
        //private Color bg_color = JXBaseControl.bg_color;

        RichTextBox replyTextBox = new RichTextBox() { Size = new Size(260, 40) };
        RichTextBox richTextBox = new RichTextBox() { Size = new Size(260, 40) };
        public override Control ContentControl()
        {
            //已经计算过气泡宽高
            //if (messageObject.BubbleWidth > 0)
            //{
            //    BubbleWidth = messageObject.BubbleWidth;
            //    BubbleHeight = messageObject.BubbleHeight;
            //    //自适应大小
            //    replyTextBox.ContentsResized += RichTextBox_ContentsResized;
            //    richTextBox.ContentsResized += RichTextBox_ContentsResized;
            //}
            ////自适应大小
            //else
            //{
                Dictionary<string, Size> dic = EQControlManager.CalculateWidthAndHeight_Reply(messageObject);
                replyTextBox.Size = dic["replyTextBox"];
                richTextBox.Size = dic["richTextBox"];
            //}

            #region 回复
            var replyMsg = JsonConvert.DeserializeObject<MessageObject>(messageObject.objectId);
            //显示的对方发送的内容
            if (replyMsg.isEncrypt == 1)
            {
                DES.DecryptMessage(replyMsg);

            }

            string from_content = EQControlManager.ChangeContentByType(replyMsg);
            //转emoji
            replyTextBox.Text = replyMsg.fromUserName + ": " + from_content;
            Calc_PanelWidth(replyTextBox);

            replyTextBox.WordWrap = true;
            replyTextBox.ReadOnly = true;
            replyTextBox.BackColor = bg_color;
            replyTextBox.BorderStyle = BorderStyle.None;
            replyTextBox.ScrollBars = RichTextBoxScrollBars.None;
            replyTextBox.BringToFront();
            replyTextBox.KeyDown += RichTextBox_KeyDown;
            replyTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            replyTextBox.Location = new Point(5, 0);
            replyTextBox.Font = new Font(Applicate.SetFont, 10F);
            replyTextBox.ForeColor = Color.Gray;
            //richTextBox.ShortcutsEnabled = false;   //屏蔽快捷键

            replyTextBox.ScrollBars = RichTextBoxScrollBars.None;
            #endregion

            #region 阅后即焚
            if (messageObject.isReadDel == 1 && messageObject.fromUserId != Applicate.MyAccount.userId)
            {
                richTextBox.Size = new Size(59, 25);
                int ri_width = richTextBox.Width, ri_height = richTextBox.Height;
                int re_width = replyTextBox.Width, re_height = replyTextBox.Height;
                messageObject.BubbleWidth = (ri_width > re_width ? ri_width : re_width) + 5;
                messageObject.BubbleHeight = re_height + 11 + ri_height + 5;

                richTextBox.ForeColor = Color.Red;
                richTextBox.Text = "点击查看";
                richTextBox.MouseDown += RichTextBox_MouseDown;
            }
            #endregion
            else
            {
                richTextBox.Text = messageObject.content + " ";
            }

            //转emoji
            //richTextBox.Text = messageObject.content;
            Calc_PanelWidth(richTextBox);

            richTextBox.WordWrap = true;
            richTextBox.ReadOnly = true;
            richTextBox.BackColor = bg_color;
            richTextBox.BorderStyle = BorderStyle.None;
            richTextBox.ScrollBars = RichTextBoxScrollBars.None;
            richTextBox.BringToFront();
            richTextBox.KeyDown += RichTextBox_KeyDown;
            richTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left;
            richTextBox.Location = new Point(5, replyTextBox.Height + 11);
            richTextBox.Font = new Font(Applicate.SetFont, 10F);
            richTextBox.Tag = messageObject.content;
            //richTextBox.ShortcutsEnabled = false;   //屏蔽快捷键

            richTextBox.ScrollBars = RichTextBoxScrollBars.None;
            //richTextBox.ContentsResized += new ContentsResizedEventHandler(richTextBox1_ContentsResized);
            //修改@颜色
            EQControlManager.GroupAtModifyColor(richTextBox);

            //添加到panel
            Panel replyPanel = new Panel();
            replyPanel.Controls.Add(replyTextBox);
            replyPanel.Controls.Add(richTextBox);

            //BubbleWidth = (richTextBox.Width > replyTextBox.Width ? richTextBox.Width : replyTextBox.Width);
            //BubbleHeight = richTextBox.Location.Y + richTextBox.Height + 5;
            BubbleWidth = messageObject.BubbleWidth;
            BubbleHeight = messageObject.BubbleHeight;
            #region 分割线
            Label lblLine = new Label();
            lblLine.BackColor = /*isOneSelf ? Color.White :*/ Color.FromArgb(220, 220, 220);
            lblLine.Location = new Point(0, replyTextBox.Height + 5);
            lblLine.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            lblLine.Size = new Size(BubbleWidth, 1);
            #endregion
            replyPanel.Size = new Size(BubbleWidth, BubbleHeight);
            replyPanel.BackColor = bg_color;
            replyPanel.Controls.Add(lblLine);

            return replyPanel;
        }

        #region 在文本框进行键盘的快捷键操作
        private void RichTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (sender is RichTextBoxEx richTextBox)
            {
                if (e.Control && e.KeyCode == Keys.C)
                {
                    string tag = richTextBox.Tag.ToString();
                    if (richTextBox.Parent.Parent is EQBaseControl talk_panel)
                    {
                        Thread myThread = new Thread(() =>
                        {
                            using (RichTextBoxEx rtbTest = new RichTextBoxEx())
                            {
                                //黏贴板的rtf
                                string rtf = Clipboard.GetDataObject().GetData(DataFormats.Rtf).ToString();
                                //匹配符合规则的表情code
                                MatchCollection matchs = Regex.Matches(tag, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
                                //MessageObject msg = MessageObjectDataDictionary.GetMsg(talk_panel.Name.Replace("talk_panel_", ""));
                                MessageObject msg = this.messageObject;
                                if (msg != null)
                                {
                                    bool isMinMsg = msg.fromUserId == Applicate.MyAccount.userId;
                                    foreach (Match match in matchs)
                                        rtf = rtf.Replace(EmojiCodeDictionary.GetEmojiRtfByCode(match.Value, isMinMsg), match.Value);
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
                int oldWidth = messageObject.BubbleWidth;
                int oldHeight = messageObject.BubbleHeight;
                //richTextBox.Size = new Size(260, 40);
                //EQControlManager.CalculateWidthAndHeight_Text(messageObject);

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
                if (crl.Controls["talk_panel_" + msg.messageId] is EQReplyControl talk_panel)
                {
                    //调整UI
                    Size bg_size = new Size();
                    BubbleWidth = msg.BubbleWidth;
                    BubbleHeight = msg.BubbleHeight;
                    Image bg_bubble = MakeTalkBubble(msg.fromUserId == Applicate.MyAccount.userId, ref bg_size);
                    richTextBox.Parent.Parent.BackgroundImage = bg_bubble;     //richTextBox.Parent: imagePanel
                    richTextBox.Parent.Size = new Size(richTextBox.Parent.Width + diff_width, richTextBox.Parent.Height + diff_height);
                    richTextBox.Parent.Parent.Size = new Size(richTextBox.Parent.Parent.Width + diff_width, bg_size.Height + 5);
                    talk_panel.Size = new Size(talk_panel.Width + diff_width, talk_panel.Height + diff_height);

                    var result = talk_panel.Controls.Find("lab_readDeleted", true);
                    if (result.Length > 0 && result[0] is Label lab_readDeleted && lab_readDeleted.Image != null)
                    {
                        lab_readDeleted.Location = new Point(lab_readDeleted.Location.X + diff_width, lab_readDeleted.Location.Y);
                        //获取该消息的总秒数
                        int second = LocalDataUtils.GetIntData(Applicate.MyAccount.userId + "_ReadDelTime_" + msg.messageId);
                        if (second < 1)
                            second = (int)Math.Round((decimal)richTextBox.Height / 30) * 10;
                        //开启计时
                        DrawisReadDel(lab_readDeleted, second);

                        //发送已读
                        ShiKuManager.SendReadMessage(msg.GetFriend(), msg);

                        richTextBox.MouseDown -= RichTextBox_MouseDown;
                    }
                }
            }
        }
        #endregion

        //记录最大行宽
        private float max_width = 0;
        private bool isFull = false;
        private void RichTextBox_ContentsResized(object sender, ContentsResizedEventArgs e)
        {
            if (sender is RichTextBox richTextBox)
            {
                if (richTextBox.Text.Length < 1 && emoji_count < 1)
                    return;

                if (BubbleWidth < 260)
                {
                    //分割每一行
                    string[] str_row = richTextBox.Text.Split(new string[] { "\n" }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string item in str_row)
                    {
                        int item_width = GetWidthByStr(item, richTextBox.Rtf);
                        if (item_width > max_width)
                            max_width = item_width;
                        //到达了最大宽度
                        if (max_width >= 260)
                        {
                            max_width = 260;
                            break;
                        }
                    }
                    if (max_width < 1)
                        return;
                    //如果文字宽度不足260
                    if (max_width < 260)
                        BubbleWidth = (int)max_width;
                    else
                        BubbleWidth = e.NewRectangle.Width + 5;
                }
                BubbleHeight = e.NewRectangle.Height;
                //if (BubbleWidth > 260)
                //    isFull = true;
                //if (isFull)
                //    richTextBox.Size = new Size(richTextBox.Width, BubbleHeight);
                //else
                    richTextBox.Size = new Size(BubbleWidth, BubbleHeight);
            }
        }

        private int GetWidthByStr(string item, string rtf)
        {
            if (string.IsNullOrEmpty(item))
                return 0;

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
                    item = item.Replace(item_value, "");
            }

            //获取行文字所占的大小
            SizeF sizeF = EQControlManager.GetStringTheSize(item, new Font(Applicate.SetFont, 10F));

            //特殊符号表情
            matchs = Regex.Matches(rtf, @"\\u-[0-9a-zA-Z]+\?", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            int emojiSymbol = matchs.Count / 2;

            //总宽度（emoji表情符号计算长度欠缺3个像素）
            int item_width = item_emojiCount * 26 + (int)sizeF.Width + emojiSymbol * 4;
            return item_width;
        }

        private void richTextBox1_ContentsResized(object sender, ContentsResizedEventArgs e)
        {
            //RichTextBoxPrintCtrl richTextBox1 = (RichTextBoxPrintCtrl)sender;
            richTextBox.Height = e.NewRectangle.Height;
        }

        /// <summary>
        /// 计算显示框高度和宽度，英文字体和中文以及标点、数字的宽度各不相同，需计算
        /// </summary>
        /// <param name="control">气泡内的控件</param>
        public override void Calc_PanelWidth(Control control)
        {
            if (!(control is RichTextBox richContent))
                return;

            //临时建立一个容器装入内容
            //using (RichTextBox canv_Rich = control as RichTextBox)
            //{
                RichTextBox canv_Rich = control as RichTextBox;
                //先取全部Text的值
                canv_Rich.Text = richContent.Text;
                //把code转为emoji
                canv_Rich.Rtf = GetEmoji(canv_Rich.Text, bg_color);

                richContent.Rtf = canv_Rich.Rtf;
            //}
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
            MatchCollection matchs = Regex.Matches(richTextBox.Text, @"\[[a-z_-]*\]", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            emoji_count = matchs.Count;
            string[] newStr = new string[matchs.Count];
            //不用做记录的变量
            int index = 0;
            foreach (Match item in matchs)
            {
                newStr[index] = item.Groups[0].Value;
                index++;
            }

            //循环替换code为表情图片
            for (int i = 0; i < newStr.Length; i++)
            {
                bool isMin = messageObject.FromId == Applicate.MyAccount.userId;
                if (EmojiCodeDictionary.GetEmojiDataIsMine().ContainsKey(newStr[i].Replace("[", "").Replace("]", "")))
                    richTextBox.Rtf = richTextBox.Rtf.Replace(newStr[i], EmojiCodeDictionary.GetEmojiRtfByCode(newStr[i], isMin));
            }


            //把链接改为超链接
            matchs = Regex.Matches(richTextBox.Text, @"^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$", RegexOptions.IgnoreCase | RegexOptions.Singleline);
            foreach (Match match in matchs)
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
