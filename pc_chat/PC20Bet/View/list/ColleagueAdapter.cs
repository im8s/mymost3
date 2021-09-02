using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Controls;
using WinFrmTalk.Model;

namespace WinFrmTalk.View.list
{
    public class ColleagueAdapter : IBaseAdapter
    {
        public List<employeesItem> employees = new List<employeesItem>();
        public DepartmentsItem department = new DepartmentsItem();
        private UserMyColleague UserCollection;
        public void SetMaengForm(UserMyColleague collection)
        {
            this.UserCollection = collection;
        }
        /// <summary>
        /// 返回item的高度
        /// </summary>
        /// <returns></returns>
        public override int GetItemCount()
        {
            return employees.Count;
        }
        /// <summary>
        /// 绑定数据
        /// </summary>
        /// <param name="data"></param>
        public void BindDatas(List<employeesItem> data,DepartmentsItem departments)
        {
            employees = data;
            department = departments;
        }
        /// <summary>
        /// 创建item
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public override Control OnCreateControl(int index)
        {
                ColleagueItem item = new ColleagueItem();
               // item.Anchor = AnchorStyles.Left | AnchorStyles.Right;
                item.Width = 500;
                Friend friend = new Friend();
                item.createUserId = department.createUserId;
                item.UserID = employees[index].userId;
                friend.NickName = employees[index].nickname;
                friend.UserId =  employees[index].userId;
                item.FriendData = friend;
                item.Position = employees[index].position;
                item.Tag =  employees[index];
                item.DoubleClick += (sen, eve) =>
                {
                    if (friend.UserId != Applicate.MyAccount.userId)
                    {
                        UserCollection. SendAction?.Invoke(friend);
                    }
                };

                item.pic_head.isDrawRound = true;
                ImageLoader.Instance.DisplayAvatar(employees[index].userId, item.pic_head);
               UserCollection.createUserId = department.createUserId;
                item.RightMenu((coll) =>
                {
                    UserCollection.tsmReplaceDepar.DropDownItems.Clear();//创建时获取到的部门数据并绑定到右键菜单，会导致部门数据更新后右键菜单的数据无法实时
                    foreach (var itemData in UserCollection.myColleague.data)
                    {
                        if (UserCollection.tvwColleague.SelectedNode.Level > 0)
                        {
                            if (((DepartmentsItem)UserCollection.Clicknode.Tag).companyId == itemData.id)
                            {
                                foreach (DepartmentsItem itemDataDepartment1 in itemData.departments)
                                {
                                    if (( itemDataDepartment1.id != UserCollection.Clicknode.Name)&& (itemDataDepartment1.id!= itemData.departments[0].id))//加入部门而没有子部门，除掉公司
                                    {
                                        ToolStripMenuItem toolStrip = new ToolStripMenuItem(itemDataDepartment1.departName);
                                        toolStrip.Name = itemDataDepartment1.id;
                                        toolStrip.Tag = itemDataDepartment1;
                                        toolStrip.Click += UserCollection.ToolStrip_Click;
                                        UserCollection.tsmReplaceDepar.DropDownItems.Add(toolStrip);
                                    }

                                }
                            }

                        }

                        if (UserCollection.SelectItem != null)
                        {
                            UserCollection.SelectItem.IsSelected = false;
                            UserCollection.SelectItem.ContextMenuStrip = null;
                        }

                        UserCollection.SelectItem = coll;
                        UserCollection.SelectItem.IsSelected = true;
                    }
                });
                item.MouseDown += UserCollection.Item_MouseDown;
            return item;
            
            //  throw new NotImplementedException();
        }

        /// <summary>
        /// 返回高度
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public override int OnMeasureHeight(int index)
        {
            return 50;
        }

        /// <summary>
        /// 移除数据
        /// </summary>
        /// <param name="index"></param>
        public override void RemoveData(int index)
        {
            employees.RemoveAt(index);
        }
        
       
    }
}
