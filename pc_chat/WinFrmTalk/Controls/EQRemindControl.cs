using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WinFrmTalk.Model;

namespace WinFrmTalk.Controls
{
    public class EQRemindControl : EQBaseControl
    {
        public EQRemindControl(string strJson) : base(strJson)
        {
            isShowRedPoint = false;
            isRemindMessage = true;
        }

        public EQRemindControl(MessageObject messageObject) : base(messageObject)
        {
            isShowRedPoint = false;
            isRemindMessage = true;
        }

        public override void Calc_PanelWidth(Control control)
        {
            BubbleHeight = control.Height;
            BubbleWidth = control.Width;
        }

        public override Control ContentControl()
        {
            Label label = new Label();

            //int row_count = 0;  //总行数
            //使用fileSize记录字符串的长度
            int width = 0;
            int height = 17;
            //如果没有记录则需要计算长度
            if (width <= 0 || height <= 0)
            {
                Size size = EQControlManager.CalculateWidthAndHeight_Remind(messageObject);
                width = size.Width;
                height = size.Height;
            }

            //height += 4;    //提高上下边距
            Bitmap bitmap = new Bitmap(width + 5, height);
            Graphics bitmapGraphics = Graphics.FromImage(bitmap);
            bitmapGraphics.Clear(Color.WhiteSmoke);
            bitmapGraphics.SmoothingMode = SmoothingMode.AntiAlias;

            Rectangle rectangle = new Rectangle(0, 0, width + 3, height - 2);
            Color color = Color.FromArgb(218, 218, 218);
            LinearGradientBrush myLinearGradientBrush = new LinearGradientBrush(rectangle, color, color, LinearGradientMode.Vertical);
            bitmapGraphics.FillPath(myLinearGradientBrush, DrawRoundRect(rectangle.X, rectangle.Y, rectangle.Width, rectangle.Height, 10));
            bitmapGraphics.Dispose();
            
            label.Text = messageObject.content;
            label.Image = bitmap;
            label.AutoSize = false;
            label.Size = new Size(width + 5, height);
            label.Location = new Point(5, 5);
            label.TextAlign = ContentAlignment.MiddleCenter;
            label.Font = new Font(Applicate.SetFont, 9F, FontStyle.Bold, GraphicsUnit.Point, 134);
            label.UseMnemonic = false;
            if (messageObject.type == kWCMessageType.RoomIsVerify)
                label.ForeColor = Color.Blue;
            else
                label.ForeColor = Color.White;
            //设置最大值和换行
            label.MaximumSize = new Size(310, height);
            return label;
        }
        
        //绘制圆角
        private static GraphicsPath DrawRoundRect(int x, int y, int width, int height, int radius)
        {
            //四边圆角
            GraphicsPath gp = new GraphicsPath();
            gp.AddArc(x, y, radius, radius, 180, 90);
            gp.AddArc(width - radius, y, radius, radius, 270, 90);
            gp.AddArc(width - radius, height - radius, radius, radius, 0, 90);
            gp.AddArc(x, height - radius, radius, radius, 90, 90);
            gp.CloseAllFigures();
            return gp;
        }
    }
}
