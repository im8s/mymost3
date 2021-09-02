using RichTextBoxLinks;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Controls.CustomControls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{

    public class CollectionAdapter : IBaseAdapter
    {
        List<Collections> mDatas = new List<Collections>();
        //List<MessageObject> message = new List<MessageObject>();
        private UserCollection UserCollection;
        public void SetMaengForm(UserCollection collection)
        {
            this.UserCollection = collection;
        }
        public override int GetItemCount()
        {
            return mDatas.Count;
        }


        public override Control OnCreateControl(int index)
        {
            UserCollectionItem item = new UserCollectionItem();
            //  item.Anchor = AnchorStyles.Left | AnchorStyles.Right;
            item.ComeFrom = "来自：" + UIUtils.LimitTextLength(Applicate.MyAccount.nickname, 4, true);//收藏来自哪？
            item.Time = TimeUtils.FromatTime(mDatas[index].createTime, "yy/MM/dd");//收藏时间
            item.Name = mDatas[index].emojiId;
            item.type = mDatas[index].type;//收藏类型
            item.CollectContent = mDatas[index].collectContent;//收藏内容
            EQShowInfoPanelAlpha eQShowInfo = new EQShowInfoPanelAlpha();

            eQShowInfo.Size = item.panel.Size;
            eQShowInfo.Location = item.panel.Location;
            eQShowInfo.BringToFront();
            item.panel.Controls.Add(eQShowInfo);
            switch (item.type)
            {
                //图片
                case "1":
                    item.Tag = mDatas[index].msg;
                    string[] strarr = mDatas[index].msg.Split(',');
                    //图片加文字
                    if (!string.IsNullOrEmpty(mDatas[index].collectContent))
                    {
                        Label piclabel = new Label();
                        piclabel.Font = new Font(Applicate.SetFont, 9f);
                        piclabel.Text = UIUtils.LimitTextLength(mDatas[index].collectContent, 78, true);
                        piclabel.Tag = mDatas[index].collectContent;
                        piclabel.Location = new Point(135, 5);
                        piclabel.AutoSize = false;
                        piclabel.Size = new Size(200, 70);
                        piclabel.MouseDown += UserCollection.Item_MouseDown;
                        item.panel.Controls.Add(piclabel);


                        PictureBox pic = new PictureBox();
                        pic.SizeMode = PictureBoxSizeMode.AutoSize;

                        pic.Anchor = AnchorStyles.Left;
                        pic.Size = new Size(70, 70);
                        pic.Location = new Point(60, (item.Height - pic.Height) / 2);
                        eQShowInfo.Name = strarr[0];
                        ImageLoader.Instance.Load(strarr[0]).Into((picc, path) =>
                        {
                            pic.Image = UIUtils.ImageScale(picc);
                        });

                        eQShowInfo.MouseDown += ShowImageLook;
                        pic.BackColor = Color.Transparent;
                        item.panel.Controls.Add(pic);

                    }
                    ///全部是图片
                    if (string.IsNullOrEmpty(mDatas[index].collectContent))
                    {
                        for (int i = 0; i < (strarr.Length > 3 ? 3 : strarr.Length); i++)
                        {
                            PictureBox pic = new PictureBox();
                            pic.Anchor = AnchorStyles.Left;
                            pic.SizeMode = PictureBoxSizeMode.StretchImage;
                            pic.Size = new Size(70, 70);
                            pic.Location = new Point(((70 + 10) * i) + 60, (item.Height - pic.Height) / 2);
                            eQShowInfo.Name = strarr[i];
                            // pic.Image = Image.FromFile(strarr[i]);
                            ImageLoader.Instance.Load(strarr[i]).Into((picc, path) =>
                            {
                                pic.Image = Image.FromFile(path);
                            });
                            item.panel.Controls.Add(pic);
                            pic.MouseDown += (e,k)=> {
                                Console.WriteLine("dsfasdj ");
                            };
                        }
                    }

                    eQShowInfo.MouseDown += ShowImageLook;
                    item.Controls.Add(item.panel);
                    // listWhole.Add(item);
                    //  listImage.Add(item);
                    break;
                //视频
                case "2":
                    PictureBox picVideo = new PictureBox();
                    picVideo.Anchor = AnchorStyles.Left;
                    picVideo.SizeMode = PictureBoxSizeMode.StretchImage;
                    picVideo.Size = new Size(70, 70);
                    picVideo.Location = new Point(60, (item.Height - picVideo.Height) / 2);
                    picVideo.Tag = mDatas[index].url;
                    LodingUtils loding = new LodingUtils();
                    loding.size = new Size(10, 10);
                    loding.parent = picVideo;
                    loding.BgColor = Color.Transparent;
                    loding.start();
                    ThubImageLoader.Instance.Load(picVideo.Tag.ToString(), picVideo, (sucess) =>
                    {
                        //关闭等待符
                        var result = picVideo.Controls.Find("loding", true);
                        if (result.Length > 0 && result[0] is USELoding lodings)
                        {
                            lodings.Dispose();
                            Helpers.ClearMemory();
                        }
                    });
                    eQShowInfo.MouseDown += (sen, eve) =>
                    {
                        if (eve.Button == MouseButtons.Left)
                        {
                            FrmVideoFlash frm = FrmVideoFlash.CreateInstrance();
                           
                            frm.VidoShowList(new MessageObject() { content = picVideo.Tag.ToString(), fileName = picVideo.Tag.ToString(), fileSize = long.Parse(mDatas[index].fileSize), type = kWCMessageType.Image });
                            frm.isCollect = true;
                            frm.Show();
                        }
                    };
                    picVideo.MouseDown += UserCollection.Item_MouseDown;
                    item.Tag = picVideo.Tag;
                    item.panel.Controls.Add(picVideo);
                    item.Controls.Add(item.panel);
                    //  listWhole.Add(item);
                    //   listVideo.Add(item);
                    UserCollection.HideLodingDialog();
                    break;
                //文件
                case "3":
                    FilePanelLeft filePanel = new FilePanelLeft();
                    filePanel.lab_fileName.Text = FileUtils.GetFileName(mDatas[index].Filename);
                    filePanel.lab_fileSize.Text = UIUtils.FromatFileSize(long.Parse(mDatas[index].fileSize));
                    filePanel.Location = new Point(60, (item.Height - filePanel.Height) / 2);
                    filePanel.lab_lineLime.Width = 0;
                    eQShowInfo.Click += (sen, eve) =>
                    {
                        try
                        {
                            //打开文件
                            System.Diagnostics.Process.Start(mDatas[index].Filename);
                        }
                        catch (Exception)
                        {
                            HttpUtils.Instance.ShowTip("不能打开此类型文件");
                        }
                    };
                    filePanel.MouseDown += UserCollection.Item_MouseDown;
                    item.Tag = filePanel.lab_fileName.Text;
                    item.panel.Controls.Add(filePanel);
                    item.Time = TimeUtils.FromatTime(mDatas[index].createTime, "yy/MM/dd");
                    // listWhole.Add(item);
                    // listfile.Add(item);
                    break;
                //语音
                case "4":

                    Label label = new Label();
                    label.Font = new Font(Applicate.SetFont, 9f);
                    label.Size = new Size(280, 30);
                    label.TextAlign = ContentAlignment.MiddleLeft;
                    label.Location = new Point(60, (item.Height - label.Height) / 2);


                    //   label.BackColor = Color.Transparent;
                    label.BorderStyle = BorderStyle.None;
                    //  label.ScrollBars = RichTextBoxScrollBars.None;
                    //  label.ReadOnly = true;

                    // 防止换行
                    // label.Multiline = true;
                    label.BringToFront();

                    label.Text = "[语音]";

                    item.Tag = mDatas[index].collectContent;
                    //  UserCollection.Calc_PanelWidth(label);//这行代码会导致字体变成默认的宋体

                    //   label.ContentsResized += UserCollection.Label_ContentsResized;
                    label.MouseDown += UserCollection.Item_MouseDown;
                    item.panel.Controls.Add(label);
                    item.Time = TimeUtils.FromatTime(mDatas[index].createTime, "yy/MM/dd");
                    break;
                //文本表情
                case "5":

                    RichTextBoxEx richText = new RichTextBoxEx();
                    richText.Font = new Font(Applicate.SetFont, 9f);
                    richText.Size = new Size(280, 30);
                    // label.TextAlign = ContentAlignment.MiddleLeft;
                    richText.Location = new Point(60, (item.Height - richText.Height) / 2);



                    // richText.BackColor = Color.WhiteSmoke;
                    richText.BorderStyle = BorderStyle.None;
                    richText.ScrollBars = RichTextBoxScrollBars.None;
                    richText.ReadOnly = true;

                    // 防止换行
                    richText.Multiline = true;
                    // richText.BringToFront();

                    richText.Text = mDatas[index].collectContent;

                    item.Tag = mDatas[index].collectContent;


                    eQShowInfo.MouseDown += (sen, eve) =>
                    {
                        if (eve.Button == MouseButtons.Left)
                        {
                            FrmSeeText frmSeeText = new FrmSeeText();
                            frmSeeText.iscollect = false;

                            frmSeeText.Longtext = item.Tag.ToString();
                            frmSeeText.Show();

                        }
                    };
                    UserCollection.Calc_PanelWidth(richText);//这行代码会导致字体变成默认的宋体

                    //  richText.ContentsResized += UserCollection.Label_ContentsResized;
                    richText.MouseDown += UserCollection.Item_MouseDown;

                    item.panel.Controls.Add(richText);
                    item.Time = TimeUtils.FromatTime(mDatas[index].createTime, "yy/MM/dd");

                    //   listWhole.Add(item);
                    //  listText.Add(item);
                    break;
                //表情
                case "6":

                    break;
                //SDK分享的链接
                case "7":

                    break;
                default:

                    break;
            }
            eQShowInfo.MouseDown += UserCollection.Item_MouseDown;
            item.MouseDown += UserCollection.Item_MouseDown;
            return item;
        }




        public void ShowImageLook(object sender, MouseEventArgs eve)
        {

            if (eve.Button == MouseButtons.Left)
            {
                EQShowInfoPanelAlpha picture = sender as EQShowInfoPanelAlpha;

                List<MessageObject> message = new List<MessageObject>();

             
                for (int j = 0; j < mDatas.Count; j++)
                {
                    var item = mDatas[j];
                    if ("1".Equals(item.type))
                    {
                        if (item.collectType == 1)
                        {
                            string[] strarr = item.msg.Split(',');
                            for (int i = 0; i < (strarr.Length > 3 ? 3 : strarr.Length); i++)
                            {
                                message.Add(new MessageObject() { content = strarr[i], fileName = item.Filename, fileSize = Convert.ToInt64(item.fileLength), type = kWCMessageType.Image });
                            }
                        }
                        else
                        {
                            message.Add(new MessageObject() { content = item.msg, fileName = item.Filename, fileSize = Convert.ToInt64(item.fileLength), type = kWCMessageType.Image });
                        }
                    }
                }

                int index = -1;
                for (int i = 0; i < message.Count; i++)
                {
                    if (message[i].content.Equals(picture.Name))
                    {
                        index = i;
                    }
                }

                FrmLookImage frm = new FrmLookImage();
                frm.ShowImageList(message, index);
                frm.Show();
            }
        }


        public override int OnMeasureHeight(int index)
        {
            return 80;
        }

        public override void RemoveData(int index)
        {
            mDatas.RemoveAt(index);
        }
        /// <summary>
        /// bangd
        /// </summary>
        /// <param name="data"></param>
        public void BindDatas(List<Collections> data)
        {

            mDatas = data;
        }

        internal int GetMessageIdByIndex(string name)
        {
            for (int i = mDatas.Count - 1; i > -1; i--)
            {
                if (mDatas[i].emojiId == name)
                {
                    return i;
                }
            }

            return -1;
        }
    }
}
