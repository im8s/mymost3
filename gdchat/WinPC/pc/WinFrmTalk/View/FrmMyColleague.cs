using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WinFrmTalk.Model;

namespace WinFrmTalk
{
    public partial class FrmMyColleague : FrmBase
    {
        public FrmMyColleague()
        {
            InitializeComponent();
            this.Icon = Icon.FromHandle(Properties.Resources.Icon64.Handle);//加载icon图标
            lblNodeName.Text = "";
            httpData();
        }

        private MyColleague myColleague = null;
     //   private bool state = true;

        private void httpData()
        {
            DownloadString item = new DownloadString()
            {
                Url = Applicate.URLDATA.data.apiUrl + "org/company/getByUserId",
                CallBackControl = this,
                Type = DownLoadFileType.String
            };
            item.AppendHttpParameter("access_token", Applicate.Access_Token)
                .AppendHttpParameter("userId", Applicate.MyAccount.userId);
            HttpDownloader.DownloadString(item, new List<Action<DownloadString>>{
                (res) =>
                {
                    myColleague = JsonConvert.DeserializeObject<MyColleague>(res.ResultText);//数据泛型解析
                    
                    foreach (ItemData itemData in myColleague.data)
                    {
                        //公司层
                        TreeNode tn1=new TreeNode(itemData.departments[0].departName);
                        tn1.Name = itemData.departments[0].id;
                        tn1.Tag = itemData.departments[0];
                        tvwColleague.Nodes.Add(tn1);
                        foreach (DepartmentsItem itemDataDepartment1 in itemData.departments)
                        {
                            //部门层
                            TreeNode tn2=new TreeNode();
                            if (itemDataDepartment1.parentId==itemData.departments[0].id)
                            {
                                tn2.Text=itemDataDepartment1.departName;
                                tn2.Name = itemDataDepartment1.id;
                                tn2.Tag = itemDataDepartment1;
                                tn1.Nodes.Add(tn2);
                                //员工层
                                //foreach (employeesItem employeesItem in itemDataDepartment.employees)
                                //{
                                //    TreeNode tn3=new TreeNode(employeesItem.nickname);
                                //    tn2.Nodes.Add(tn3);
                                //}
                                foreach (DepartmentsItem itemDataDepartment2 in itemData.departments)
                                {
                                    if (itemDataDepartment1.id==itemDataDepartment2.parentId)
                                    {
                                        TreeNode tn2_1=new TreeNode(itemDataDepartment2.departName);
                                        tn2_1.Name = itemDataDepartment2.id;
                                        tn2.Nodes.Add(tn2_1);
                                    }
                                }
                            }
                        }
                    }
                }

            });

        }
        private TreeNode Clicknode = null;
        private ColleagueItem SelectItem = null;
        private object createUserId;
        /// <summary>
        /// 点击节点事件
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void newTreeView1_NodeMouseClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            Clicknode = e.Node;
            cmsCompany.Items[0].Enabled = true;
            cmsCompany.Items[1].Enabled = true;
            cmsCompany.Items[3].Enabled = true;
            cmsDepartment.Enabled = true;
            if (e.Button == MouseButtons.Right)
            {
                tvwColleague.SelectedNode = e.Node;
                if (e.Node.Level <= 0)
                {
                    if (e.Node.Tag is DepartmentsItem)
                    {
                        if (((DepartmentsItem)e.Node.Tag).createUserId.ToString() != Applicate.MyAccount.userId)
                        {
                            cmsCompany.Items[0].Enabled = false;
                            cmsCompany.Items[1].Enabled = false;
                            cmsCompany.Items[3].Enabled = false;
                            cmsCompany.Items[2].Enabled = true;
                        }
                    }
                    e.Node.ContextMenuStrip = cmsCompany;
                }

                if (e.Node.Level > 0)
                {
                    if (e.Node.Tag is DepartmentsItem)
                    {
                        if (((DepartmentsItem)e.Node.Tag).createUserId.ToString() != Applicate.MyAccount.userId)
                        {
                            cmsDepartment.Enabled = false;

                        }
                    }
                    e.Node.ContextMenuStrip = cmsDepartment;
                }
                return;
            }

           LogUtils.Log(e.Node.Name);
            pnlMyColleague.ClearTabel();
            List<Control> lisitem = new List<Control>();
            foreach (var dataDepartment in myColleague.data)
            {
                foreach (var department in dataDepartment.departments)
                {
                    if (e.Node.Level > 0 && e.Node.FirstNode == null)
                    {


                        if (e.Node.Name == department.parentId)
                        {
                            TreeNode tn2_1 = new TreeNode(department.departName);
                            tn2_1.Name = department.id;
                            e.Node.Nodes.Add(tn2_1);
                        }

                    }
                    if (department.id == e.Node.Name)
                    {
                        LodingUtils loding = new LodingUtils();
                        loding.parent = pnlMyColleague;
                        loding.start();
                        foreach (var employee in department.employees)
                        {

                            ColleagueItem item = new ColleagueItem();
                            Friend friend = new Friend();
                            item.createUserId = department.createUserId;
                            item.UserID = employee.userId;
                            friend.NickName = employee.nickname;
                            friend.UserId = employee.userId;
                            item.FriendData = friend;
                            item.Position = employee.position;
                            item.Tag = employee;
                            item.pic_head.isDrawRound = true;
                            ImageLoader.Instance.DisplayAvatar(employee.userId, item.pic_head);
                            this.createUserId = department.createUserId;
                            item.RightMenu((coll) =>
                            {
                                tsmReplaceDepar.DropDownItems.Clear();
                                foreach (var itemData in myColleague.data)
                                {
                                    if (e.Node.Level > 0)
                                    {
                                        if (((DepartmentsItem)Clicknode.Tag).companyId == itemData.id)
                                        {
                                            foreach (DepartmentsItem itemDataDepartment1 in itemData.departments)
                                            {
                                                if (itemDataDepartment1.parentId == itemData.departments[0].id && itemDataDepartment1.id != Clicknode.Name)
                                                {
                                                    ToolStripMenuItem toolStrip = new ToolStripMenuItem(itemDataDepartment1.departName);
                                                    toolStrip.Name = itemDataDepartment1.id;
                                                    toolStrip.Tag = itemDataDepartment1;
                                                    toolStrip.Click += ToolStrip_Click;
                                                    tsmReplaceDepar.DropDownItems.Add(toolStrip);
                                                }

                                            }
                                        }

                                    }

                                    if (SelectItem != null)
                                    {
                                        SelectItem.IsSelected = false;
                                        SelectItem.ContextMenuStrip = null;
                                    }

                                    this.SelectItem = coll;
                                    SelectItem.IsSelected = true;
                                }
                            });
                            item.MouseDown += Item_MouseDown;
                            lisitem.Add(item);
                        }
                        List<Control> views = new List<Control>();
                        for (int i = 0; i < 20; i++)
                        {
                            //验证是否有该index
                            if (i < lisitem.Count)
                                views.Add(lisitem[i]);
                        }
                        pnlMyColleague.AddViewsToPanel(views);
                        loding.stop();

                        pnlMyColleague.AddScollerBouttom((index) =>
                        {
                            views = new List<Control>();
                            for (int i = 0; i < 10; i++)
                            {
                                int num = i + ((index - (20 / 10) - 1) * 10) + 20;
                                if (num < lisitem.Count)
                                    views.Add(lisitem[num]);
                            }
                            pnlMyColleague.AddViewsToPanel(views);
                           LogUtils.Log(index.ToString());
                        }, 20, 10);
                    }

                }
            }

            lblNodeName.Text = "";
            TreeNode treeNodeCount = e.Node.Parent;
            for (int i = 0; i < e.Node.Level; i++)
            {
                if (treeNodeCount != null)
                {
                    lblNodeName.Text = treeNodeCount.Text + ">" + lblNodeName.Text;
                    treeNodeCount = treeNodeCount.Parent;
                }
            }

            lblNodeName.Text += e.Node.Text;
        }
        /// <summary>
        /// 成员右键菜单
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Item_MouseDown(object sender, MouseEventArgs e)
        {
            cmsStaff.Items[1].Enabled = true;
            cmsStaff.Items[2].Enabled = true;
            cmsStaff.Items[3].Enabled = true;
            if (e.Button == MouseButtons.Right)
            {
                if (this.createUserId.ToString() != Applicate.MyAccount.userId)
                {
                    if (SelectItem.UserID == Applicate.MyAccount.userId)
                    {
                        cmsStaff.Items[1].Enabled = false;
                        cmsStaff.Items[3].Enabled = false;
                    }

                    if (SelectItem.UserID != Applicate.MyAccount.userId)
                    {
                        cmsStaff.Items[1].Enabled = false;
                        cmsStaff.Items[2].Enabled = false;
                        cmsStaff.Items[3].Enabled = false;
                    }
                }

                SelectItem.ContextMenuStrip = cmsStaff;
            }


        }
        /// <summary>
        /// 创建公司
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCreate_Click(object sender, EventArgs e)
        {
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.Location = new Point(this.Location.X + (this.Width - frm.Width) / 2, this.Location.Y + (this.Height - frm.Height) / 2);
            frm.ColleagueName((data) =>
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/company/create")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("companyName", data)
                    .AddParams("createUserId", Applicate.MyAccount.userId)
                    .Build().Execute((suss, resultData) =>
                    {
                        frm.Close();
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("创建成功");
                        }
                        else
                        {
                            MessageBox.Show("创建失败");
                        }
                    });
            });

            frm.ShowDialog();
        }
        #region 公司层右键菜单
        /// <summary>
        /// 创建部门
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void AddDepartment_Click(object sender, EventArgs e)
        {
            //弹窗编辑
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.Location = new Point(this.Location.X + (this.Width - frm.Width) / 2, this.Location.Y + (this.Height - frm.Height) / 2);
            frm.ColleagueName((data) =>
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/department/create")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("companyId", ((DepartmentsItem)Clicknode.Tag).companyId)
                    .AddParams("parentId", Clicknode.Name)
                    .AddParams("departName", data)
                    .AddParams("createUserId", Applicate.MyAccount.userId)
                    .Build().Execute((suss, resultData) =>
                    {
                        frm.Close();
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("创建成功");
                        }
                    });
            });

            frm.ShowDialog();

        }
        /// <summary>
        /// 修改公司名称
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void EditCompany_Click(object sender, EventArgs e)
        {
            //弹窗编辑
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.NameEdit = Clicknode.Text;
            frm.Location = new Point(this.Location.X + (this.Width - frm.Width) / 2, this.Location.Y + (this.Height - frm.Height) / 2);
            frm.ColleagueName((data) =>
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/company/modify")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("companyId", Clicknode.Name)
                    .AddParams("companyName", data)
                    .Build()
                    .Execute((suss, resultData) =>
                    {
                        frm.Close();
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("修改成功");
                        }
                        else
                        {
                            MessageBox.Show("修改失败");
                        }
                    });
            });

            frm.ShowDialog();
        }
        /// <summary>
        /// 退出公司
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void QuitCompany_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("确认退出此公司", "系统提示", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation);
            if (result == DialogResult.Yes)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/company/quit")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("companyId", Clicknode.Name)
                    .AddParams("userId", Applicate.MyAccount.userId)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("退出成功");
                        }
                        else
                        {
                            MessageBox.Show("退出失败");
                        }
                    });
            }
        }
        /// <summary>
        /// 删除公司
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DeleteCompany_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("确认删除此公司", "系统提示", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation);
            if (result == DialogResult.Yes)
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/company/delete")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("companyId", Clicknode.Name)
                    .AddParams("userId", Applicate.MyAccount.userId)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("删除成功");
                        }
                        else
                        {
                            MessageBox.Show("删除失败");
                        }
                    });
            }
        }
        #endregion
        #region 部门层右键菜单
        /// <summary>
        /// 添加子部门
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void AddSubdivisions_Click(object sender, EventArgs e)
        {
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.Location = new Point(this.Location.X + (this.Width - frm.Width) / 2, this.Location.Y + (this.Height - frm.Height) / 2);
            frm.ColleagueName((data) =>
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/department/create")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("companyId", ((DepartmentsItem)Clicknode.Tag).companyId)
                    .AddParams("parentId", Clicknode.Name)
                    .AddParams("departName", data)
                    .AddParams("createUserId", Applicate.MyAccount.userId)
                    .Build().Execute((suss, resultData) =>
                    {
                        frm.Close();
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("创建成功");
                        }
                        else
                        {
                            MessageBox.Show("创建失败");
                        }
                    });
            });

            frm.ShowDialog();
        }

        /// <summary>
        /// 添加成员
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void AddMember_Click(object sender, EventArgs e)
        {
            FrmFriendSelect frm = new FrmFriendSelect();
            frm.LoadFriendsData();
            frm.AddConfrmListener((UserFriends) =>
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("[");
                foreach (var itemValue in UserFriends.Values)
                {
                    sb.Append("\"" + itemValue.UserId + "\",");
                }

                sb.Remove(sb.Length - 1, 1);
                sb.Append("]");
               LogUtils.Log(sb.ToString());
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/employee/add")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("userId", sb.ToString()) //需要添加的用户id，json字符串
                    .AddParams("companyId", ((DepartmentsItem)Clicknode.Tag).companyId)
                    .AddParams("departmentId", Clicknode.Name)
                    .AddParams("role", "1")
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("添加成功");
                        }
                        else
                        {
                            MessageBox.Show("添加失败");
                        }
                    });
            });
        }

        /// <summary>
        /// 修改部门名称
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void EditDepartmentName_Click(object sender, EventArgs e)
        {
            //弹窗编辑
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.NameEdit = Clicknode.Text;
            frm.Location = new Point(this.Location.X + (this.Width - frm.Width) / 2, this.Location.Y + (this.Height - frm.Height) / 2);
            frm.ColleagueName((data) =>
            {


                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/department/modify")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("departmentId", Clicknode.Name)
                    .AddParams("dpartmentName", data)
                    .Build().Execute((suss, resultData) =>
                    {
                        frm.Close();
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("修改成功");
                        }
                        else
                        {
                            MessageBox.Show("修改失败");
                        }
                    });
            });

            frm.ShowDialog();
        }
        /// <summary>
        /// 删除部门
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DeleteDepartment_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("确认删除此部门", "系统提示", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation);
            if (result == DialogResult.Yes)
            {

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/department/delete")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("departmentId", Clicknode.Name)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("删除成功");
                        }
                        else
                        {
                            MessageBox.Show("删除失败");
                        }
                    });
            }
        }
        #endregion

        #region 员工层右键菜单
        /// <summary>
        /// 好友详情
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmDetails_Click(object sender, EventArgs e)
        {

            FrmFriendsBasic frm = new FrmFriendsBasic();
            frm.ShowUserInfoById(SelectItem.UserID);
        }
        /// <summary>
        /// 更换部门
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ToolStrip_Click(object sender, EventArgs e)
        {
            ToolStripItem tool = ((ToolStripMenuItem)sender);
            HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/employee/modifyDpart")
                .AddParams("access_token", Applicate.Access_Token)
                .AddParams("userId", SelectItem.UserID)
                .AddParams("companyId", ((DepartmentsItem)tool.Tag).companyId)
                .AddParams("newDepartmentId", tool.Name)
                .Build().Execute((suss, resultdata) =>
                {
                    if (suss)
                    {
                        pnlMyColleague.ClearTabel();
                        tvwColleague.Nodes.Clear();
                        httpData();
                        MessageBox.Show("更换成功");
                    }
                    else
                    {
                        MessageBox.Show("更换失败");
                    }
                });
        }
        /// <summary>
        /// 修改职位
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmEditPosition_Click(object sender, EventArgs e)
        {
            //弹窗编辑
            FrmMyColleagueEidt frm = new FrmMyColleagueEidt();
            frm.NameEdit = SelectItem.Position;
            frm.Location = new Point(this.Location.X + (this.Width - frm.Width) / 2, this.Location.Y + (this.Height - frm.Height) / 2);
            frm.ColleagueName((data) =>
            {
                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/employee/modifyPosition")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("userId", SelectItem.UserID)
                    .AddParams("companyId", ((employeesItem)SelectItem.Tag).companyId)
                    .AddParams("position", data)
                    .Build().Execute((suss, resultData) =>
                    {
                        frm.Close();
                        if (suss)
                        {
                            pnlMyColleague.ClearTabel();
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("修改成功");
                        }
                        else
                        {
                            MessageBox.Show("修改失败");
                        }
                    });
            });
            frm.ShowDialog();
        }
        /// <summary>
        /// 删除员工
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void tsmDeleteStaff_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("确认删除此员工", "系统提示", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation);
            if (result == DialogResult.Yes)
            {

                HttpUtils.Instance.Get().Url(Applicate.URLDATA.data.apiUrl + "org/employee/delete")
                    .AddParams("access_token", Applicate.Access_Token)
                    .AddParams("userIds", "[\"" + SelectItem.UserID + "\"]")
                    .AddParams("departmentId", ((employeesItem)SelectItem.Tag).departmentId)
                    .Build().Execute((suss, data) =>
                    {
                        if (suss)
                        {
                            pnlMyColleague.ClearTabel();
                            tvwColleague.Nodes.Clear();
                            httpData();
                            MessageBox.Show("删除成功");
                        }
                        else
                        {
                            MessageBox.Show("删除失败");
                        }
                    });
            }
        }

        #endregion

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void lblNodeName_Click(object sender, EventArgs e)
        {

        }
    }
}
