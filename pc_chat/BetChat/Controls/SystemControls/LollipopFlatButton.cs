using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;

public class LollipopFlatButton : Control
{

    #region  Variables

    Timer AnimationTimer = new Timer { Interval = 1 };

    FontManager font = new FontManager();
    StringFormat SF = new StringFormat();
    Rectangle R;

    new bool Focus = false;

    int xx;
    int yy;

    float SizeAnimation = 0;
    float SizeIncNum;

    string fontcolor = "#0AD007";

    Color EnabledBGColor;
    Color EnabledBorderColor;
    Color StringColor;

    Color DisabledStringColor = ColorTranslator.FromHtml("#0ADDD7");

    #endregion
    #region  Properties

    [Category("Appearance")]
    public string FontColor
    {
        get { return fontcolor; }
        set
        {
            fontcolor = value;
            Invalidate();
        }
    }

    [Browsable(true)]
    public override Font Font
    {
        get { return base.Font; }
        set { base.Font = value; }
    }

    [Browsable(false)]
    public new Color ForeColor
    {
        get { return base.ForeColor; }
        set { base.ForeColor = value; }
    }

    #endregion
    #region  Events

    protected override void OnMouseEnter(EventArgs e)
    {
        base.OnMouseEnter(e);

        EnabledBGColor = Color.FromArgb(30, StringColor);
        EnabledBorderColor = Color.FromArgb(20, StringColor);
        Refresh();
    }
    protected override void OnMouseLeave(EventArgs e)
    {
        base.OnMouseLeave(e);

        EnabledBGColor = Color.Transparent;
        EnabledBorderColor = Color.Transparent;
        Refresh();
    }
    protected override void OnMouseDown(MouseEventArgs e)
    {
        base.OnMouseDown(e);

        //EnabledBGColor = Color.FromArgb(30, StringColor);
        Refresh();

        xx = e.X;
        yy = e.Y;

        Focus = true;
        AnimationTimer.Start();
        Invalidate();
    }

    protected override void OnMouseUp(MouseEventArgs e)
    {
        base.OnMouseUp(e);
        Focus = false;
        return;
        //AnimationTimer.Start();
        //Invalidate();
    }

    protected override void OnTextChanged(System.EventArgs e)
    {
        base.OnTextChanged(e);
        Invalidate();
    }
    protected override void OnSizeChanged(EventArgs e)
    {
        base.OnSizeChanged(e);
        R = new Rectangle(0, 0, Width, Height);
    }

    #endregion

    public LollipopFlatButton()
    {
        this.Cursor = Cursors.Hand;

        SetStyle((ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.SupportsTransparentBackColor | ControlStyles.UserPaint), true);
        DoubleBuffered = true;

        Size = new Size(143, 41);
        BackColor = Color.Transparent;

        SF.Alignment = StringAlignment.Center;
        SF.LineAlignment = StringAlignment.Center;

        AnimationTimer.Tick += new EventHandler(AnimationTick);
    }

    protected override void OnResize(EventArgs e)
    {
        base.OnResize(e);
        SizeIncNum = Width / 30;
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);

        var G = e.Graphics;
        G.SmoothingMode = SmoothingMode.HighQuality;
        G.Clear(Parent.BackColor);

        StringColor = ColorTranslator.FromHtml(fontcolor);

        var BG = DrawHelper.CreateRoundRect(1, 1, Width - 3, Height - 3, 1);
        Region region = new Region(BG);

        G.FillPath(new SolidBrush(Enabled ? EnabledBGColor : Color.White), BG);
        G.DrawPath(new Pen(Enabled ? EnabledBorderColor : Color.White), BG);

        G.SetClip(region, CombineMode.Replace);

        //The Ripple Effect
        G.FillEllipse(new SolidBrush(Color.FromArgb(30, StringColor)), xx - (SizeAnimation / 2), yy - (SizeAnimation / 2), SizeAnimation, SizeAnimation);
        //font.Roboto_Medium10
        G.DrawString(Text, this.Font, new SolidBrush(Enabled ? StringColor : DisabledStringColor), R, SF);
    }

    protected void AnimationTick(object sender, EventArgs e)
    {
        if (Focus)
        {
            if (SizeAnimation < Width + 250)
            {
                SizeAnimation += SizeIncNum;
                this.Invalidate();
            }
        }
        else
        {
            if (SizeAnimation > 0)
            {
                SizeAnimation = 0;
                this.Invalidate();
            }
        }
    }
}