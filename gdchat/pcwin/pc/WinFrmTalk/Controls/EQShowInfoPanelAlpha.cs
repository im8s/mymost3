using System.Drawing;

namespace WinFrmTalk.Controls
{
    public class EQShowInfoPanelAlpha :EQPanelEx
    {
        public EQShowInfoPanelAlpha()
        {

        }

        protected override void OnDraw()
        {
            int width = this.Width;
            int height = this.Height;
            Rectangle recModel = new Rectangle(0, 0, width, height);
            if (this.BackgroundImage != null)
            {
                this.graphics.DrawImage(this.BackgroundImage, recModel);
            }
            else if (this.ForeColor != Color.Transparent)
            {
                this.graphics.Clear(this.ForeColor);
            }
            else if (this.BackColor != Color.Transparent)
            {
                this.graphics.Clear(this.BackColor);
            }
        }
    }
}
