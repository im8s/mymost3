﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WinFrmTalk.View
{
    public partial class FrmGroupChat : Form
    {
        public FrmGroupChat()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
        }
    }
}
