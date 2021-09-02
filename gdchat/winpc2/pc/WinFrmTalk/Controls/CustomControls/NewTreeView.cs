using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WinFrmTalk.Properties;

namespace WinFrmTalk
{
    public class NewTreeView : TreeView
    {
        //双缓冲
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000;
                return cp;
            }
        }
        Color backColor = Color.WhiteSmoke;
        Font foreFont = new Font(Applicate.SetFont, 9F, FontStyle.Bold);

        Brush foreBrush = new SolidBrush(Color.FromArgb(81, 81, 81));
        Brush recBrush = new SolidBrush(Color.FromArgb(82, 218, 163));
        Brush recSelectedBrush = new SolidBrush(Color.FromArgb(248, 248, 255));

        Pen recPen = new Pen(new SolidBrush(Color.FromArgb(226, 226, 226)));
        Pen recHoverPen = new Pen(new SolidBrush(Color.FromArgb(82, 218, 163)));
        Pen linePen = new Pen(Color.FromArgb(226, 226, 226), 1);

        Image icon;

        public NewTreeView()
        {
            this.DrawMode = TreeViewDrawMode.OwnerDrawText;
            this.ItemHeight = 30;//节点行高          
            this.BackColor = Color.WhiteSmoke;
            this.ShowLines = true;
            this.HotTracking = true;
            this.Indent = 20;//节点X值缩进量
            this.Scrollable = true;
            this.BorderStyle = BorderStyle.None;
            this.Font = foreFont;
        }

        protected override void OnDrawNode(DrawTreeNodeEventArgs e)
        {
            //if (e.Node.Level == 0)//根节点
            //{
            if (!e.Node.IsExpanded)//根节点未展开
            {
                icon = Resources.ec;
            }
            else//根节点展开
            {
                icon = Resources.ex;
            }
            //刷新背景色防止字体图标重绘叠加
            e.Graphics.FillRectangle(new SolidBrush(backColor), e.Bounds);
            //if (e.Node.FirstNode != null)
            // {
            //重绘图标，一级节点X值默认为23，padding-left为6,17 = 23 - 6
            e.Graphics.DrawImage(icon, e.Node.Bounds.X - 17, e.Node.Bounds.Y + 8, 10, 10);
            //}
            //重绘字体
            e.Graphics.DrawString(e.Node.Text, foreFont, foreBrush, e.Node.Bounds.Left, e.Node.Bounds.Top + 5);
            if (e.Node.IsSelected && e.Node.Level > 0)//二级节点被选中
            {
                Rectangle box = new Rectangle(e.Bounds.Left, e.Bounds.Top + 4, e.Bounds.Width, e.Bounds.Height - 12);
                e.Graphics.FillRectangle(recBrush, box);
                //if (e.Node.FirstNode != null)
                //{
                //重绘图标，一级节点X值默认为23，padding-left为6,17 = 23 - 6
                e.Graphics.DrawImage(icon, e.Node.Bounds.X - 17, e.Node.Bounds.Y + 8, 10, 10);
                //}
                e.Graphics.DrawString(e.Node.Text, foreFont, recSelectedBrush, e.Node.Bounds.Left, e.Node.Bounds.Top + 5);
            }
            //}
            if (e.Node.IsSelected && e.Node.Level <= 0)
            {
                Rectangle box = new Rectangle(e.Bounds.Left, e.Bounds.Top + 4, e.Bounds.Width, e.Bounds.Height - 12);
                e.Graphics.FillRectangle(recBrush, box);
               LogUtils.Log(e.Node.ToString());
                //重绘图标，一级节点X值默认为23，padding-left为6,17 = 23 - 6
                e.Graphics.DrawImage(icon, e.Node.Bounds.X - 17, e.Node.Bounds.Y + 8, 10, 10);
                e.Graphics.DrawString(e.Node.Text, foreFont, recSelectedBrush, e.Node.Bounds.Left, e.Node.Bounds.Top + 5);
            }

        }
       

        protected override void OnMouseClick(MouseEventArgs e)
        {
            base.OnMouseClick(e);
            TreeNode tn = this.GetNodeAt(e.Location);
            
            if (0 != tn.Level)//点击一级节点不使二级节点的选中效果消失
            {
                this.SelectedNode = tn;
               
            }

            //图标中心点向右的区域也能单击折叠与展开
            Rectangle bounds = new Rectangle(0, tn.Bounds.Y,  tn.Bounds.Width+tn.Bounds.X, tn.Bounds.Height);
            Graphics g = this.CreateGraphics();

            if (tn != null && bounds.Contains(e.Location) == false)
            {
               LogUtils.Log(tn.IsSelected.ToString());
                if (tn.IsExpanded == false)
                    tn.Expand();
                else
                    tn.Collapse();
            }
        }

        TreeNode currentNode = null;
       protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);
            TreeNode tn = this.GetNodeAt(e.Location);
            Graphics g = this.CreateGraphics();
            if (currentNode != tn)
            {
                //绘制当前节点的hover背景
                if (null != tn)
                {
                    OnDrawNode(new DrawTreeNodeEventArgs(g, tn, new Rectangle(0, tn.Bounds.Y, this.Width - 4, tn.Bounds.Height), TreeNodeStates.Hot));
                }

                //取消之前hover的节点背景
                if (null != currentNode)
                {
                    OnDrawNode(new DrawTreeNodeEventArgs(g, currentNode, new Rectangle(0, currentNode.Bounds.Y, this.Width - 4, currentNode.Bounds.Height), TreeNodeStates.Default));
                }
            }
            currentNode = tn;
            g.Dispose();//释放Graphics资源
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            base.OnMouseLeave(e);
            //移出控件时取消Hover背景
            if (currentNode != null)
            {
                Graphics g = this.CreateGraphics();
                OnDrawNode(new DrawTreeNodeEventArgs(g, currentNode, new Rectangle(0, currentNode.Bounds.Y, this.Width - 4, currentNode.Bounds.Height), TreeNodeStates.Default));

                currentNode = null;//同一个节点Leave后Move有Hover效果            
            }
        }

        

      protected override void OnMouseDoubleClick(MouseEventArgs e)
        {
            base.OnMouseDoubleClick(e);
            TreeNode tn = this.GetNodeAt(e.Location);
            ////图标中心点向右的区域双击折叠与展开
            Rectangle bounds = new Rectangle(tn.Bounds.Left - 10, tn.Bounds.Y, tn.Bounds.Width - 10, tn.Bounds.Height);
            Graphics g = this.CreateGraphics();
            g.DrawRectangle(new Pen(Color.Black), bounds);
            if (tn != null && bounds.Contains(e.Location) == false)
            {
                if (tn.IsExpanded == false)
                    tn.Expand();
                else
                    tn.Collapse();
            }
        }
    }
}
