using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Newtonsoft.Json.Linq;
using System.IO;

namespace WinFrmTalk.Controls.CustomControls
{
    public partial class ImageTextMany : UserControl
    {
        private int pos_y = 140;
        public ImageTextMany()
        {
            InitializeComponent();
        }

        #region 设置图文
        public void SetImageText(string content_json)
        {
            if (string.IsNullOrEmpty(content_json))
                return;

            JArray jSONArray = JArray.Parse(content_json);
            if (jSONArray.Count > 0)
            {
                foreach (var child in jSONArray.Children())
                {
                    string url = child.Value<string>("url");
                    if (string.IsNullOrEmpty(this.lblTitle.Text))
                    {
                        //解析json
                        this.lblTitle.Text = child.Value<string>("title");
                        ImageLoader.Instance.Load(child["img"].ToString()).NoCache().Into((image, path) =>
                        {
                            if (string.IsNullOrEmpty(path) || !File.Exists(path))
                                return;
                            this.picImg.BackgroundImage = image;
                        });

                        //添加点击事件
                        pan_content.MouseClick += (sender, e) =>
                        {
                            if (e.Button == MouseButtons.Left)
                            {
                                if (!string.IsNullOrEmpty(url))
                                    System.Diagnostics.Process.Start(url);
                            }
                        };
                        foreach (Control crl in pan_content.Controls)
                            crl.MouseClick += (sender, e) =>
                            {
                                if (e.Button == MouseButtons.Left)
                                {
                                    if (!string.IsNullOrEmpty(url))
                                        System.Diagnostics.Process.Start(url);
                                }
                            };
                    }
                    else
                    {
                        ImageTextCrl imageTextCrl = new ImageTextCrl();
                        //解析json
                        imageTextCrl.lblTitle.Text = child.Value<string>("title");
                        ImageLoader.Instance.Load(child["img"].ToString()).NoCache().Into((image, path) =>
                        {
                            if (string.IsNullOrEmpty(path) || !File.Exists(path))
                                return;
                            imageTextCrl.picImg.BackgroundImage = image;
                        });
                        this.Height += imageTextCrl.Height;
                        imageTextCrl.Location = new Point(0, pos_y);
                        this.Controls.Add(imageTextCrl);
                        pos_y += imageTextCrl.Height;

                        //添加点击事件
                        pan_content.MouseClick += (sender, e) =>
                        {
                            if (e.Button == MouseButtons.Left)
                            {
                                if (!string.IsNullOrEmpty(url))
                                    System.Diagnostics.Process.Start(url);
                            }
                        };
                        foreach (Control crl in imageTextCrl.Controls)
                            crl.MouseClick += (sender, e) =>
                            {
                                if (e.Button == MouseButtons.Left)
                                {
                                    if (!string.IsNullOrEmpty(url))
                                        System.Diagnostics.Process.Start(url);
                                }
                            };
                    }
                }
            }
        }
        #endregion
    }
}
