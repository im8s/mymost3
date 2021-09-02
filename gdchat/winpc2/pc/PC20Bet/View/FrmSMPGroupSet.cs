using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.View
{
    public partial class FrmSMPGroupSet : FrmSuspension
    {
        public Friend room { get; set; }
        //private static FrmSMPGroupSet frmSMPGroupSet;       //唯一实例
        //private static readonly object looker = new object();       //确保线程的同步，同一时间不能同时访问
        public FrmSMPGroupSet()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            this.IsClose = true;
            this.Is_DropShadow = false;
            this.Radius = 0;
        }

        /// <summary>
        /// 定义公有方法提供一个全局访问点,同时你也可以定义公有属性来提供全局访问点
        /// </summary>
        /// <returns></returns>
        //public static FrmSMPGroupSet GetFrmSMPGroupSet()
        //{
        //    // 当第一个线程运行到这里时，此时会对locker对象 "加锁"，
        //    // 当第二个线程运行该方法时，首先检测到locker对象为"加锁"状态，该线程就会挂起等待第一个线程解锁
        //    // lock语句运行完之后（即线程运行完之后）会对该对象"解锁"
        //    // 双重锁定只需要一句判断就可以了
        //    if (frmSMPGroupSet == null)
        //    {
        //        lock (looker)
        //        {
        //            // 如果类的实例不存在则创建，否则直接返回
        //            if (frmSMPGroupSet == null)
        //            {
        //                frmSMPGroupSet = new FrmSMPGroupSet();
        //            }
        //        }
        //    }
        //    return frmSMPGroupSet;
        //}

        private void FrmSMPGroupSet_Load(object sender, EventArgs e)
        {
            useGroupSet1.BackColor = Color.White;
            useGroupSet1.SetRoomData(room);
            useGroupSet1.FillData();
        }

     

        private void FrmSMPGroupSet_Deactivate(object sender, EventArgs e)
        {
            Messenger.Default.Unregister(this);//反注册
        }
    }
}
